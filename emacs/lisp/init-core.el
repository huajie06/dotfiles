;;; init-core.el --- Package bootstrap and general Emacs settings

;;; Package manager
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(require 'use-package)
(setq use-package-always-ensure t)

;; macOS PATH fix
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :config
  (exec-path-from-shell-initialize))

;;; General Emacs settings
(use-package emacs
  :init
  ;; Backups
  (setq backup-directory-alist `(("." . "~/.emacs.d/.saves")))
  (setq delete-old-versions t
        kept-new-versions 4
        kept-old-versions 2
        version-control t)

  ;; Save behavior
  (setq auto-save-default nil)
  (setq auto-save-visited-interval 60)
  (setq auto-save-no-message t)

  ;; Search
  (setq case-fold-search t)

  ;; Allow frame geometry restore to use exact pixel dimensions when possible.
  (setq frame-resize-pixelwise t)

  ;; Matching
  (setq blink-matching-paren 'jump
        blink-matching-delay .2)

  ;; Fill column indicator
  (setq-default fill-column 80)
  (setq display-fill-column-indicator-column 80)

  :config
  ;; Font: Fira Code 11pt, with system default fallback.
  ;; Symbol font: Symbols Nerd Font Mono, with fallback.
  (when (display-graphic-p)
    (let ((fira-family "Fira Code")
          (symbol-family "Symbols Nerd Font Mono")
          (size 110))
      (if (find-font (font-spec :family fira-family))
          (set-face-attribute 'default nil :family fira-family :height size)
        (set-face-attribute 'default nil :height size))
      (when (find-font (font-spec :family symbol-family))
        (set-fontset-font t 'symbol (font-spec :family symbol-family)))))

  ;; Persist GUI frame size across sessions.  Position is deliberately left to
  ;; the window manager: Wayland compositors such as KWin may ignore client
  ;; positioning requests.
  (defvar my/frame-geometry-file
    (locate-user-emacs-file "frame-geometry.el"))

  (defvar my/frame-geometry-default
    '(:columns 96 :rows 43))

  (defvar my/frame-geometry-save-on-exit nil
    "When non-nil, save the selected frame size as Emacs exits.")

  (defun my/frame-geometry--read ()
    "Read saved frame geometry from `my/frame-geometry-file'."
    (when (file-readable-p my/frame-geometry-file)
      (with-temp-buffer
        (insert-file-contents my/frame-geometry-file)
        (goto-char (point-min))
        (read (current-buffer)))))

  (defun my/frame-geometry--capture (&optional frame)
    "Capture FRAME's text-area size as a plist."
    (let ((frame (or frame (selected-frame))))
      (list :text-pixel-width (frame-text-width frame)
            :text-pixel-height (frame-text-height frame)
            :columns (frame-width frame)
            :rows (frame-height frame))))

  (defun my/frame-geometry--write (geometry)
    "Write GEOMETRY to `my/frame-geometry-file'."
    (make-directory (file-name-directory my/frame-geometry-file) t)
    (with-temp-file my/frame-geometry-file
      (insert ";; Saved by `my/save-frame-geometry'.\n")
      (prin1 geometry (current-buffer))
      (insert "\n")))

  ;; Frame geometry notes (KDE Plasma, KWin, Wayland, Emacs 30.2 PGTK):
  ;;
  ;; What we tried:
  ;; - `default-frame-alist' with a fixed column width.  This set only part of
  ;;   the desired geometry and conflicted with restoring an exact saved size.
  ;; - Saving columns/rows and outer pixel dimensions.  Font and decoration
  ;;   changes made those measurements produce inconsistent results.
  ;; - Saving the text area's pixel dimensions and applying them with
  ;;   `set-frame-size' in pixelwise mode.  This restores the size reliably and
  ;;   is the approach retained below.
  ;; - Restoring position immediately and again from delayed startup hooks,
  ;;   using absolute coordinates, monitor-relative ratios, workarea clamping,
  ;;   and a manual top offset.  Diagnostic logs showed KWin replacing the
  ;;   requested position (for example, (0 -80) became (1670 50)).
  ;;
  ;; Why position is not saved:
  ;; Wayland does not generally let a normal client choose its top-level window
  ;; position.  Under KWin, `set-frame-position' therefore cannot reliably
  ;; restore it, regardless of timing or coordinate calculations.
  ;;
  ;; Potential next steps if fixed placement becomes important:
  ;; 1. Add a KWin Window Rule for Emacs and set Position to "Remember" or
  ;;    "Apply Initially".  This is the preferred Wayland solution.
  ;; 2. Use an X11 session, where application-managed position restoration is
  ;;    available, then add position fields back to the saved plist.
  ;; 3. Revisit client-side positioning if a future Wayland/KWin protocol adds
  ;;    reliable support for normal top-level windows.
  (defun my/save-frame-geometry (&optional frame)
    "Save the selected GUI frame's size.

Despite the historical name, this intentionally does not save position.
See the frame geometry notes immediately above this function."
    (interactive)
    (when (display-graphic-p frame)
      (my/frame-geometry--write (my/frame-geometry--capture frame))
      (when (called-interactively-p 'interactive)
        (message "Saved frame geometry to %s" my/frame-geometry-file))))

  (defun my/restore-frame-geometry (&optional frame)
    "Restore the saved GUI frame size."
    (interactive)
    (when (display-graphic-p frame)
      (let* ((frame (or frame (selected-frame)))
             (geometry (or (my/frame-geometry--read)
                           my/frame-geometry-default))
             (pixel-width (plist-get geometry :text-pixel-width))
             (pixel-height (plist-get geometry :text-pixel-height))
             (columns (plist-get geometry :columns))
             (rows (plist-get geometry :rows)))
        (cond
         ((and pixel-width pixel-height)
          (set-frame-size frame
                          pixel-width pixel-height t))
         ((and columns rows)
          (set-frame-size frame columns rows)))
        (when (called-interactively-p 'interactive)
          (message "Restored frame size")))))

  (defun my/restore-frame-geometry-later (&optional frame)
    "Restore FRAME size after the window system has settled."
    (let ((frame (or frame (selected-frame))))
      (dolist (delay '(0.2 1.0))
        (run-with-timer
         delay nil
         (lambda (target-frame)
           (when (frame-live-p target-frame)
             (my/restore-frame-geometry target-frame)))
         frame))))

  ;; GUI Emacs on Linux may not inherit the interactive shell PATH.
  (let ((local-bin (expand-file-name "~/.local/bin")))
    (when (file-directory-p local-bin)
      (add-to-list 'exec-path local-bin)
      (setenv "PATH" (concat local-bin path-separator (getenv "PATH")))))

  (auto-save-visited-mode 1)
  (global-hl-line-mode -1)
  (show-paren-mode t)
  (menu-bar-mode -1)
  (global-eldoc-mode -1)
  (electric-pair-mode 1)
  (electric-indent-mode 1)
  ;; (setq display-line-numbers-type 'relative
  ;;       display-line-numbers-width 4
  ;;       display-line-numbers-grow-only t)
  (global-display-line-numbers-mode t)
  (global-auto-revert-mode 1)

  ;; Keybindings
  (global-set-key (kbd "<f12>") 'toggle-truncate-lines)

  ;; Hooks
  (add-hook 'prog-mode-hook 'display-fill-column-indicator-mode)

  ;; Restore after core UI settings have settled.  Delayed passes handle window
  ;; managers that resize the first frame during startup.
  (my/restore-frame-geometry)
  (add-hook 'window-setup-hook #'my/restore-frame-geometry)
  (add-hook 'window-setup-hook #'my/restore-frame-geometry-later)
  (add-hook 'after-make-frame-functions #'my/restore-frame-geometry-later)
  (add-hook 'kill-emacs-hook
            (lambda ()
              (when my/frame-geometry-save-on-exit
                (my/save-frame-geometry)))))

;;; ws-butler — smart trailing whitespace (only touches edited lines)
(use-package ws-butler
  :config
  (ws-butler-global-mode))

;;; which-key
(use-package which-key
  :init
  (which-key-mode))

;;; Search enhancements (built-in isearch config)
(use-package isearch
  :ensure nil
  :config
  (setq isearch-lazy-count t)
  (setq isearch-lazy-highlight t))

;;; Session persistence
(use-package savehist
  :ensure nil
  :init
  (savehist-mode))

(use-package recentf
  :ensure nil
  :init
  (setq recentf-max-saved-items 150)
  :config
  (recentf-mode 1)
  (run-at-time nil (* 25 60) 'recentf-save-list))

(provide 'init-core)
;;; init-core.el ends here
