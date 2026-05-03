;;; init-python.el --- Python tree-sitter, shell, and custom utilities

(require 'python)

;;; Tree-sitter grammar sources
(use-package treesit
  :ensure nil
  :config
  (setq treesit-language-source-alist
        '((python "https://github.com/tree-sitter/tree-sitter-python")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
          (go "https://github.com/tree-sitter/tree-sitter-go")
          (html "https://github.com/tree-sitter/tree-sitter-html")
          (css "https://github.com/tree-sitter/tree-sitter-css")
          (json "https://github.com/tree-sitter/tree-sitter-json"))))

;;; Python mode configuration
(use-package python
  :ensure nil
  :custom
  (python-indent-offset 4)
  (python-indent-guess-indent-offset nil)
  (indent-tabs-mode nil)
  :init
  ;; Remap python-mode to python-ts-mode
  (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))
  :bind (:map python-base-mode-map
              ("<f5>" . my-python-run))
  :config
  (defun my-python-run ()
    "Save and run the current python file."
    (interactive)
    (when (derived-mode-p 'python-base-mode)
      (save-buffer)
      (let ((py (or (executable-find "python3")
                    (executable-find "python")
                    "python3")))
        (compile (format "%s %s" py (shell-quote-argument (buffer-file-name)))))))

  (add-hook 'python-mode-hook #'superword-mode)
  (electric-indent-local-mode 1))

;;; Custom Python utilities

(defun my/set-python-interpreter ()
  "Search for venvs, prompt user, isolate process."
  (interactive)
  (let* ((project-root (if (bound-and-true-p projectile-mode)
                           (projectile-project-root)
                         (file-name-directory (buffer-file-name))))
         (venv-candidates '(".venv" "venv" "env" ".env"))
         (found-interpreters '()))
    (dolist (dir venv-candidates)
      (let ((exe-path (expand-file-name
                       (if (eq system-type 'windows-nt)
                           (concat dir "/Scripts/ipython.exe")
                         (concat dir "/bin/ipython"))
                       project-root)))
        (when (file-exists-p exe-path)
          (push exe-path found-interpreters))))
    (let ((chosen-interpreter
           (cond
            ((> (length found-interpreters) 0)
             (completing-read (format "Interpreter for %s: " (file-name-nondirectory (directory-file-name project-root)))
                              (append found-interpreters '("System Default (ipython)"))))
            (t
             (message "No virtualenv found. Using system default.")
             "System Default (ipython)"))))
      (if (string= chosen-interpreter "System Default (ipython)")
          (progn
            (setq-local python-shell-interpreter "ipython")
            (setq-local python-shell-virtualenv-root nil))
        (progn
          (setq-local python-shell-interpreter chosen-interpreter)
          (setq-local python-shell-virtualenv-root
                      (file-name-directory (directory-file-name (file-name-directory chosen-interpreter))))))
      (setq-local python-shell-interpreter-args "-i --simple-prompt --classic")
      (setq-local python-shell-completion-native-enable nil)
      (setq-local comint-process-echoes t)
      (let ((proj-name (file-name-nondirectory (directory-file-name project-root))))
        (setq-local python-shell-buffer-name (format "Python[%s]" proj-name)))
      (message "Ready. REPL: *%s* (Native Completion Disabled)" python-shell-buffer-name))))

(defun my/python-send-current-line ()
  "Send the current physical line to the Python process."
  (interactive)
  (save-excursion
    (let ((start (line-beginning-position))
          (end (line-end-position)))
      (python-shell-send-region start end)
      (python-shell-send-string "\n")
      (message "Sent line."))))

(defun my/python-get-cell-bounds ()
  "Return a cons cell (start . end) of the current '# %%' delimited block."
  (save-excursion
    (let ((start (point-min))
          (end (point-max)))
      (if (re-search-backward "^# %%" nil t)
          (setq start (match-end 0))
        (goto-char (point-min)))
      (goto-char (if (> start (point)) start (point)))
      (if (re-search-forward "^# %%" nil t)
          (setq end (match-beginning 0))
        (setq end (point-max)))
      (cons start end))))

(defun my/python-send-cell ()
  "Identify the current '# %%' block and send it to the Python shell."
  (interactive)
  (let* ((bounds (my/python-get-cell-bounds))
         (start (car bounds))
         (end (cdr bounds)))
    (if (= start end)
        (message "Empty cell")
      (python-shell-send-region start end)
      (message "Sent cell."))))

(defun my/python-send-buffer ()
  "Send the entire buffer to the Python shell."
  (interactive)
  (python-shell-send-buffer)
  (message "Sent buffer."))

(defun my/run-python-keep-focus ()
  "Run Python. Keep focus in code buffers; switch to shell otherwise."
  (interactive)
  (if (derived-mode-p 'prog-mode)
      (save-selected-window
        (call-interactively 'run-python))
    (call-interactively 'run-python)))

;;; Keybindings

(with-eval-after-load 'python
  (define-key python-mode-map (kbd "C-c C-p") 'my/run-python-keep-focus)
  (define-key python-mode-map (kbd "C-c l") 'my/python-send-current-line)
  (define-key python-mode-map (kbd "C-c b") 'my/python-send-cell)
  (define-key python-mode-map (kbd "C-c a") 'my/python-send-buffer))

(with-eval-after-load 'evil
  (with-eval-after-load 'python
    (evil-define-key 'normal python-mode-map
      (kbd "<leader>l") 'my/python-send-current-line
      (kbd "<leader>b") 'my/python-send-cell
      (kbd "<leader>a") 'my/python-send-buffer)))

(provide 'init-python)
;;; init-python.el ends here
