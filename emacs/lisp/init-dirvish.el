;;; init-dirvish.el --- Dirvish (enhanced Dired) configuration

(defun my/dirvish-side-toggle ()
  "Show Dirvish Side when hidden, or hide it when visible."
  (interactive)
  (require 'dirvish-side)
  (let ((window (dirvish-side--session-visible-p)))
    (if window
        (with-selected-window window
          (dirvish-side))
      (dirvish-side))))

(defun my/dirvish-side-disable-line-numbers ()
  "Disable line numbers in Dirvish Side."
  (when-let ((session (dirvish-curr)))
    (when (eq (dv-type session) 'side)
      (display-line-numbers-mode -1))))

(use-package nerd-icons)

(use-package dirvish
  :init
  (dirvish-override-dired-mode)

  :bind
  ("C-c d" . my/dirvish-side)

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
  (defun my/dirvish-side-window ()
    "Return the visible Dirvish sidebar window, or nil."
    (cl-find-if
     (lambda (window)
       (with-current-buffer (window-buffer window)
         (derived-mode-p 'dirvish-side-mode)))
     (window-list)))

  (defun my/dirvish-side ()
    "Open, focus, or close the Dirvish sidebar.

If the sidebar is closed, open and focus it.
If it is visible but unfocused, focus it.
If it is already focused, close it."
    (interactive)
    (let ((sidebar-window (my/dirvish-side-window)))
      (cond
       ;; Sidebar is currently focused: close it.
       ((eq (selected-window) sidebar-window)
        (dirvish-side))

       ;; Sidebar exists but another window is focused.
       (sidebar-window
        (select-window sidebar-window))

       ;; Sidebar is closed: open and focus it.
       (t
        (dirvish-side)
        (when-let ((new-window (my/dirvish-side-window)))
          (select-window new-window))))))

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

  :config
  (add-hook 'dirvish-setup-hook
            #'my/dirvish-disable-line-numbers)

  (with-eval-after-load 'evil
    ;; Start Dirvish in Evil normal state.
    (evil-set-initial-state 'dirvish-mode 'normal)
    (evil-set-initial-state 'dirvish-side-mode 'normal)

    ;; Regular Dirvish buffers.
    (evil-define-key 'normal dirvish-mode-map
      (kbd "j")   #'dired-next-line
      (kbd "k")   #'dired-previous-line
      (kbd "h")   #'dired-up-directory
      (kbd "l")   #'dired-find-file
      (kbd "RET") #'dired-find-file
      (kbd "TAB") #'dirvish-subtree-toggle
      (kbd "zM")  #'my/dirvish-collapse-all

      (kbd "g r") #'revert-buffer

      (kbd "m")   #'dired-mark
      (kbd "u")   #'dired-unmark
      (kbd "U")   #'dired-unmark-all-marks
      (kbd "C")   #'dired-do-copy
      (kbd "R")   #'dired-do-rename
      (kbd "D")   #'dired-do-delete
      (kbd "+")   #'dired-create-directory
      (kbd "q")   #'quit-window)

    ;; Dirvish sidebar buffers.
    (evil-define-key 'normal dirvish-side-mode-map
      (kbd "j")   #'dired-next-line
      (kbd "k")   #'dired-previous-line
      (kbd "h")   #'dired-up-directory
      (kbd "l")   #'dired-find-file
      (kbd "RET") #'dired-find-file
      (kbd "TAB") #'dirvish-subtree-toggle
      (kbd "zM")  #'my/dirvish-collapse-all

      (kbd "g r") #'revert-buffer

      (kbd "m")   #'dired-mark
      (kbd "u")   #'dired-unmark
      (kbd "U")   #'dired-unmark-all-marks
      (kbd "C")   #'dired-do-copy
      (kbd "R")   #'dired-do-rename
      (kbd "D")   #'dired-do-delete
      (kbd "+")   #'dired-create-directory
      (kbd "q")   #'quit-window)))

(provide 'init-dirvish)
;;; init-dirvish.el ends here
