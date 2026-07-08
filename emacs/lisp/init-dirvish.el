;;; init-dirvish.el --- Dirvish (enhanced Dired) configuration

(use-package nerd-icons)

(use-package dirvish
  :init
  (dirvish-override-dired-mode)

  :custom
  (dirvish-side-width 30)

  ;; Prevent delete-other-windows from removing the sidebar.
  (dirvish-side-window-parameters
   '((no-delete-other-windows . t)))

  ;; Keep the sidebar compact.
  (dirvish-attributes
   '(nerd-icons collapse))

  (dirvish-mode-line-format
   '(:left (sort symlink)
           :right (omit yank index)))

  :preface
  (require 'cl-lib)

  (defun my/dirvish-side-window-p (window)
    "Return non-nil if WINDOW is a visible Dirvish side window."
    (when (window-live-p window)
      (with-current-buffer (window-buffer window)
        (or
         ;; Normal case.
         (derived-mode-p 'dirvish-side-mode)

         ;; More robust fallback: check the Dirvish session type.
         ;; This helps when the buffer is still `dirvish-mode' but belongs
         ;; to a side session.
         (when-let ((session (and (fboundp 'dirvish-curr)
                                  (ignore-errors (dirvish-curr)))))
           (eq (dv-type session) 'side))))))

  (defun my/dirvish-side-window (&optional frame)
    "Return the visible Dirvish side window in FRAME, or nil."
    (cl-find-if
     #'my/dirvish-side-window-p
     (window-list frame 'no-minibuf)))

  (defun my/dirvish-side-windows-all-frames ()
    "Return all visible Dirvish side windows across all frames."
    (let (windows)
      (dolist (frame (frame-list))
        (dolist (window (window-list frame 'no-minibuf))
          (when (my/dirvish-side-window-p window)
            (push window windows))))
      windows))

  (defun my/dirvish-close-side-windows-other-frames ()
    "Close visible Dirvish side windows in frames other than the selected frame."
    (let ((current-frame (selected-frame)))
      (dolist (window (my/dirvish-side-windows-all-frames))
        (unless (eq (window-frame window) current-frame)
          (when (window-live-p window)
            (ignore-errors
              (delete-window window)))))))

  (defun my/dirvish-side ()
    "Toggle Dirvish side in the current frame.

If Dirvish side is visible in the current frame, close it.
If Dirvish side is visible in another frame, close that one first.
Then open Dirvish side in the current frame and focus it."
    (interactive)
    (require 'dirvish-side)
    (if-let ((window (my/dirvish-side-window (selected-frame))))
        ;; Important: do not call `dirvish-side' here.
        ;; `dirvish-side' would select the existing side window.
        (delete-window window)

      ;; If another frame has a visible Dirvish side window, close it first.
      ;; Otherwise plain `dirvish-side' may jump to that frame/window.
      (my/dirvish-close-side-windows-other-frames)

      ;; Now it is safe to open Dirvish side in the current frame.
      (dirvish-side)

      ;; Focus the newly opened side window in the current frame.
      (when-let ((window (my/dirvish-side-window (selected-frame))))
        (select-window window))))

  (defun my/dirvish-disable-line-numbers ()
    "Disable line numbers in Dirvish sidebar buffers."
    (when-let ((session (dirvish-curr)))
      (when (eq (dv-type session) 'side)
        (display-line-numbers-mode -1))))

  (defun my/dirvish-collapse-all ()
    "Collapse every expanded subtree in the current Dirvish buffer."
    (interactive)
    (let (expanded start-pos)
      (save-excursion
        (goto-char (point-max))
        (while (not (bobp))
          (when (dirvish-subtree--expanded-p)
            (push (point-marker) expanded))
          (forward-line -1)))
      (setq start-pos (point-marker))
      (dolist (pos expanded)
        (goto-char pos)
        (forward-line 1)
        (dirvish-subtree-remove))
      (goto-char start-pos)
      (set-marker start-pos nil)))

  (defun my/dirvish--split-and-open (split-fn)
    "Open file at point in a split, handling the Emacs side-window constraint.
SPLIT-FN is a function like `split-window-right' or `split-window-below'.
In side mode, the side window is temporarily removed to allow splitting,
then restored after opening the file."
    (let* ((file (dired-get-filename nil t)))
      (unless file (user-error "No file at point"))
      (if (file-directory-p file)
          (dired-find-file)
        (if-let* ((side-win (my/dirvish-side-window))
                  (side-dir (with-current-buffer (window-buffer side-win)
                              default-directory)))
            (progn
              (delete-window side-win)
              (let ((new-win (funcall split-fn)))
                (select-window new-win)
                (find-file file))
              (dirvish-side side-dir)
              (when-let ((file-win (get-buffer-window (find-file-noselect file) t)))
                (select-window file-win)))
          (let ((new-win (funcall split-fn)))
            (select-window new-win)
            (find-file file))))))

  (defun my/dirvish-find-file-vertical ()
    "Open file at point in a vertical split (file on the right)."
    (interactive)
    (my/dirvish--split-and-open #'split-window-right))

  (defun my/dirvish-find-file-horizontal ()
    "Open file at point in a horizontal split (file below)."
    (interactive)
    (my/dirvish--split-and-open #'split-window-below))

  :config
  (add-hook 'dirvish-setup-hook
            #'my/dirvish-disable-line-numbers)

  ;; config sort
  (if (and (eq system-type 'darwin)
           (executable-find "gls"))
      (progn
        (setq insert-directory-program "gls")
        (setq dired-listing-switches "-Alh --group-directories-first --sort=name"))
    (setq dired-listing-switches "-Alh --group-directories-first --sort=name"))

  (with-eval-after-load 'evil
    (evil-set-initial-state 'dirvish-mode 'normal)
    (evil-set-initial-state 'dirvish-side-mode 'normal)

    (evil-define-key 'normal dirvish-mode-map
      (kbd "h")   #'dired-up-directory
      (kbd "l")   #'dired-find-file
      (kbd "w")   #'dired-copy-filename-as-kill
      (kbd "y")   #'dired-copy-filename-as-kill
      (kbd "<tab>") #'dirvish-subtree-toggle
      (kbd "?")   #'dirvish-dispatch
      (kbd "zm")  #'my/dirvish-collapse-all
      (kbd "zM")  #'my/dirvish-collapse-all
      (kbd "gv")  #'my/dirvish-find-file-vertical
      (kbd "gs")  #'my/dirvish-find-file-horizontal)

    (evil-define-key 'normal dirvish-side-mode-map
      (kbd "h")   #'dired-up-directory
      (kbd "l")   #'dired-find-file
      (kbd "w")   #'dired-copy-filename-as-kill
      (kbd "y")   #'dired-copy-filename-as-kill
      (kbd "<tab>") #'dirvish-subtree-toggle
      (kbd "?")   #'dirvish-dispatch
      (kbd "zm")  #'my/dirvish-collapse-all
      (kbd "zM")  #'my/dirvish-collapse-all
      (kbd "gv")  #'my/dirvish-find-file-vertical
      (kbd "gs")  #'my/dirvish-find-file-horizontal)))

(global-set-key (kbd "C-c d") #'my/dirvish-side)

(provide 'init-dirvish)
;;; init-dirvish.el ends here
