;;; init-python.el --- Python tree-sitter, shell, and custom utilities  -*- lexical-binding: t -*-

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

(defun my/python-setup-completion ()
  "Use lightweight Python completion without a language server."
  (setq-local completion-at-point-functions
              (list #'python-completion-at-point
                    #'cape-keyword
                    #'cape-dabbrev
                    #'cape-file)))

(defun my/python-project-root ()
  "Return the current project root, or the current file's directory."
  (or (when (and (bound-and-true-p projectile-mode)
                 (fboundp 'projectile-project-root))
        (ignore-errors (projectile-project-root)))
      (when-let ((project (project-current)))
        (project-root project))
      (when-let ((file (buffer-file-name)))
        (file-name-directory file))))

(defun my/python-venv-executable (venv-dir)
  "Return the Python executable inside VENV-DIR."
  (expand-file-name
   (if (eq system-type 'windows-nt)
       "Scripts/python.exe"
     "bin/python")
   venv-dir))

(defun my/python-find-venv-python (project-root)
  "Return the first Python executable found in PROJECT-ROOT venvs."
  (seq-find #'file-executable-p
            (mapcar (lambda (dir)
                      (my/python-venv-executable
                       (expand-file-name dir project-root)))
                    '(".venv" "venv" "env" ".env"))))

(defun my/python-find-runner ()
  "Return the Python executable for running the current buffer."
  (or (when-let ((project-root (my/python-project-root)))
        (my/python-find-venv-python project-root))
      (seq-find #'file-executable-p '("/usr/bin/python3" "/usr/bin/python"))
      (executable-find "python3")
      (executable-find "python")
      "python3"))

(defun my-python-run ()
  "Save and run the current Python file with unbuffered output."
  (interactive)
  (unless (buffer-file-name)
    (user-error "Current buffer is not visiting a file"))
  (save-buffer)
  (let* ((py (my/python-find-runner))
         (fname (file-name-nondirectory (buffer-file-name)))
         (command (format "%s -u %s"
                          (shell-quote-argument py)
                          (shell-quote-argument (buffer-file-name)))))
    (async-shell-command command (format "*python-run %s*" fname))))

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
              ("<f3>" . my-python-run))
  :config
  (add-hook 'python-base-mode-hook #'superword-mode)
  (add-hook 'python-base-mode-hook #'my/python-setup-completion)

  (add-hook 'python-base-mode-hook
            (lambda ()
              (add-hook 'before-save-hook #'my/ruff-format nil 'make-local)))
  (electric-indent-local-mode 1))

;;; Python syntax checking with Ruff through Flymake
(use-package flymake-ruff
  :hook ((python-base-mode . flymake-ruff-load)
         (python-base-mode . flymake-mode)))

;;; Custom Python utilities

(defun my/ruff-format ()
  "Format the current buffer with ruff.
Formats in a temp buffer first, then copies back only on success."
  (interactive)
  (when-let ((ruff (executable-find "ruff")))
    (let ((orig (current-buffer))
          (start (point-min))
          (end (point-max)))
      (with-temp-buffer
        (insert-buffer-substring orig start end)
        (let ((exit (call-process-region (point-min) (point-max) ruff t t nil
                                         "format" "--quiet" "-")))
          (if (zerop exit)
              (let ((formatted (buffer-string)))
                (with-current-buffer orig
                  (delete-region start end)
                  (insert formatted)))
            (error "ruff format failed with exit code %d" exit)))))))

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

(defun my/python-version ()
  "Display the Python version that will be used by the shell."
  (interactive)
  (let* ((interp (or (and (boundp 'python-shell-interpreter) python-shell-interpreter)
                     "python3"))
         (version (shell-command-to-string (format "%s --version" interp))))
    (message "%s" (string-trim version))))

;;; Keybindings

(with-eval-after-load 'python
  (define-key python-base-mode-map (kbd "C-c C-p") 'my/run-python-keep-focus)
  (define-key python-base-mode-map (kbd "C-c l") 'my/python-send-current-line)
  (define-key python-base-mode-map (kbd "C-c b") 'my/python-send-cell)
  (define-key python-base-mode-map (kbd "C-c a") 'my/python-send-buffer))

(with-eval-after-load 'evil
  (with-eval-after-load 'python
    (evil-define-key 'normal python-base-mode-map
      (kbd "<leader>l") 'my/python-send-current-line
      (kbd "<leader>b") 'my/python-send-cell
      (kbd "<leader>a") 'my/python-send-buffer)))

(provide 'init-python)
;;; init-python.el ends here
