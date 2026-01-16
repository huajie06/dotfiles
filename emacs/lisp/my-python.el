(defun my/set-python-interpreter ()
  "Search for venvs, prompt user, isolate process, and FIX THE NOISE."
  (interactive)
  ;; 1. Identify Project Root
  (let* ((project-root (if (bound-and-true-p projectile-mode)
                           (projectile-project-root)
                         (file-name-directory (buffer-file-name))))
         (venv-candidates '(".venv" "venv" "env" ".env"))
         (found-interpreters '()))

    ;; Search for valid IPython executables
    (dolist (dir venv-candidates)
      (let ((exe-path (expand-file-name (concat dir "/bin/ipython") project-root)))
        (when (file-exists-p exe-path)
          (push exe-path found-interpreters))))

    ;; 2. Prompt the user
    (let ((chosen-interpreter
           (cond
            ((> (length found-interpreters) 0)
             (completing-read (format "Interpreter for %s: " (file-name-nondirectory (directory-file-name project-root)))
                              (append found-interpreters '("System Default (ipython)"))))
            (t 
             (message "No virtualenv found. Using system default.")
             "System Default (ipython)"))))

      ;; 3. Set the interpreter
      (if (string= chosen-interpreter "System Default (ipython)")
          (progn
            (setq-local python-shell-interpreter "ipython")
            (setq-local python-shell-virtualenv-root nil))
        (progn
          (setq-local python-shell-interpreter chosen-interpreter)
          (setq-local python-shell-virtualenv-root 
                      (file-name-directory (directory-file-name (file-name-directory chosen-interpreter))))))

      ;; 4. --- THE NOISE FIXES ---
      
      ;; Force simple prompting
      (setq-local python-shell-interpreter-args "-i --simple-prompt --classic")
      
      ;; Disable the native completion handshake (THE CULPRIT)
      (setq-local python-shell-completion-native-enable nil)
      
      ;; Tell Emacs not to wait for echoes
      (setq-local comint-process-echoes t)

      ;; 5. Project Isolation
      (let ((proj-name (file-name-nondirectory (directory-file-name project-root))))
        (setq-local python-shell-buffer-name (format "Python[%s]" proj-name)))
      
      (message "Ready. REPL: *%s* (Native Completion Disabled)" python-shell-buffer-name))))
;;; my-python.el --- Custom Python Data Science Workflow

(require 'python)

;; -----------------------------------------------------------------------------
;; 1. Send Current Line
;; -----------------------------------------------------------------------------
(defun my/python-send-current-line ()
  "Send the current physical line to the Python process, regardless of cursor position."
  (interactive)
  (save-excursion
    (let ((start (line-beginning-position))
          (end (line-end-position)))
      (python-shell-send-region start end)
      ;; We send a newline ensuring the shell accepts the input immediately
      ;; (Optional: keeps the shell from waiting for more input)
      (python-shell-send-string "\n") 
      (message "Sent line."))))

;; -----------------------------------------------------------------------------
;; 2. Send Code Block (Cell)
;;    Looks for "# %%" delimiters, similar to VS Code / Jupyter
;; -----------------------------------------------------------------------------
(defun my/python-get-cell-bounds ()
  "Return a cons cell (start . end) of the current code block."
  (save-excursion
    (let ((start (point-min))
          (end (point-max)))
      
      ;; Search backward for the start of the cell (# %%)
      (if (re-search-backward "^# %%" nil t)
          (setq start (match-end 0)) ;; Start sending *after* the delimiter
        (goto-char (point-min)))     ;; Or start at file beginning

      ;; Move forward to search for the end of the cell
      (goto-char (if (> start (point)) start (point)))
      
      (if (re-search-forward "^# %%" nil t)
          (setq end (match-beginning 0)) ;; End sending *before* the next delimiter
        (setq end (point-max)))          ;; Or end at file end
      
      (cons start end))))

(defun my/python-send-cell ()
  "Identify the current '# %%' block and send it to the Python shell."
  (interactive)
  (let* ((bounds (my/python-get-cell-bounds))
         (start (car bounds))
         (end (cdr bounds)))
    ;; Check if the cell is empty or just whitespace
    (if (= start end)
        (message "Empty cell")
      (python-shell-send-region start end)
      (message "Sent cell."))))

;; -----------------------------------------------------------------------------
;; 3. Send Entire File
;; -----------------------------------------------------------------------------
(defun my/python-send-buffer ()
  "Send the entire buffer to the Python shell."
  (interactive)
  (python-shell-send-buffer)
  (message "Sent buffer."))

;; -----------------------------------------------------------------------------
;; Keybindings
;; -----------------------------------------------------------------------------

;; Standard Emacs bindings (C-c ...)
(with-eval-after-load 'python
  (define-key python-mode-map (kbd "C-c l") 'my/python-send-current-line)
  (define-key python-mode-map (kbd "C-c b") 'my/python-send-cell)
  (define-key python-mode-map (kbd "C-c a") 'my/python-send-buffer))

;; OPTIONAL: Evil-mode bindings (Leader keys)
;; Since you use evil, you might prefer these.
;; Uncomment the block below if you use 'evil-leader' or 'general.el'
;; Or just use 'evil-define-key' here:

(with-eval-after-load 'evil
  (with-eval-after-load 'python
    (evil-define-key 'normal python-mode-map
      (kbd "<leader>l") 'my/python-send-current-line
      (kbd "<leader>b") 'my/python-send-cell
      (kbd "<leader>a") 'my/python-send-buffer)))

(provide 'my-python)
;;; my-python.el ends here
