;;; init-tools.el --- Development tools: magit, projectile, tramp, anzu, ibuffer, etc.

;;; Magit
(use-package magit
  :bind ("C-x g" . magit-status)
  :config
  (setq magit-refresh-status-buffer nil))

;;; Projectile
(use-package projectile
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map))
  :custom
  (projectile-indexing-method 'alien)
  (projectile-enable-caching t)
  (projectile-globally-ignored-directories
   '(".git" "node_modules" "dist" "build"
     "target" "vendor" ".idea" ".vscode"
     "venv" ".venv" "env" ".env" ".tox"
     "__pycache__" ".pytest_cache" ".mypy_cache" "htmlcov"
     "dist" "build" "site-packages"))
  (projectile-globally-ignored-file-suffixes
   '(".elc" ".pyc" ".o" ".class" ".jar" "pyo" "pyd"
     ".png" ".jpg" ".svg" ".db"))
  (projectile-globally-ignored-files
   '("package-lock.json" "yarn.lock" ".DS_Store")))

(use-package consult-projectile
  :after (consult projectile)
  :config
  (require 'consult-projectile))

;;; TRAMP — remote file editing
(use-package tramp
  :ensure nil
  :config
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

;;; Markdown
(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown")
  :bind (:map markdown-mode-map
              ("C-c C-e" . markdown-do)))

;;; Anzu — search match count in modeline
(use-package anzu
  :config
  (global-anzu-mode +1)
  (set-face-attribute 'anzu-mode-line nil
                      :foreground "purple" :weight 'bold))

;;; hl-todo — highlight TODO-like keywords in comments
;; Default keywords: HOLD TODO NEXT THEM PROG OKAY DONT FAIL DONE
;;                    NOTE MAYBE KLUDGE HACK TEMP WIP FIXME DEBUG XXXX*
(use-package hl-todo
  :config
  (setq hl-todo-keyword-faces
        (append '(("FIXED" . "#4caf50"))
                hl-todo-keyword-faces))
  :hook ((python-base-mode) . hl-todo-mode))

;;; Aggressive indent — keep code correctly indented
(use-package aggressive-indent
  :config
  (add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode))

;;; Indent bars — visual indentation guides
(use-package indent-bars
  :custom
  (indent-bars-no-descend-lists 'skip)
  (indent-bars-treesit-support t)
  (indent-bars-treesit-ignore-blank-lines-types '("module"))
  (indent-bars-treesit-scope '((python function_definition class_definition for_statement
                                     if_statement with_statement while_statement)))
  :hook ((python-base-mode yaml-mode) . indent-bars-mode))

;;; Diminish — clean up minor mode lighters
(use-package diminish)

;;; Ibuffer — buffer list management
(use-package ibuffer
  :ensure nil
  :bind ("C-x C-b" . ibuffer)
  :custom
  (ibuffer-expert t)
  (ibuffer-display-summary nil)
  (ibuffer-use-other-window nil)
  (ibuffer-show-empty-filter-groups nil)
  (ibuffer-movement-cycle nil)
  :config
  (add-hook 'ibuffer-mode-hook #'ibuffer-auto-mode)

  (setq ibuffer-saved-filter-groups
        '(("default"
           ("Dired"    (or
                         (mode . dired-mode)
                         (mode . dirvish-mode)
                         (mode . dirvish-side-mode)))
           ("Org/Notes" (or
                         (mode . org-mode)
                         (mode . markdown-mode)
                         (mode . text-mode)))
           ("Code"      (or
                         (mode . python-mode)
                         (mode . python-ts-mode)
                         (mode . js-mode)
                         (mode . go-mode)
                         (mode . sh-mode)
                         (mode . web-mode)
                         (mode . css-mode)))
           ("Magit"    (name . "^magit"))
           ("Setup"    (mode . emacs-lisp-mode))
           ("Shells"   (or
                        (mode . eshell-mode)
                        (mode . shell-mode)
                        (mode . vterm-mode)))
           ("Emacs"    (or
                        (mode . emacs-lisp-compilation-mode)
                        (name . "^\\*scratch\\*$")
                        (name . "^\\*Messages\\*$")
                        (name . "^\\*Help\\*$")
                        (name . "^\\*Backtrace\\*$"))))))

  (add-hook 'ibuffer-mode-hook
            (lambda ()
              (ibuffer-switch-to-saved-filter-groups "default"))))

(use-package ibuffer-project
  :hook
  (ibuffer-mode . (lambda ()
                    (setq ibuffer-filter-groups (ibuffer-project-generate-filter-groups))
                    (unless (eq ibuffer-sorting-mode 'project-file-relative)
                      (ibuffer-do-sort-by-project-file-relative)))))

(provide 'init-tools)
;;; init-tools.el ends here
