;;; init-evil.el --- Evil mode (vim emulation) and related packages

;;; Undo system (must be configured before evil loads)
(use-package undo-fu
  :config
  (setq evil-undo-system 'undo-fu))

(use-package undo-fu-session
  :init
  (undo-fu-session-global-mode)
  :config
  (setq undo-fu-session-incompatible-files '("/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'")))

(use-package vundo
  :bind ("C-x u" . vundo)
  :config
  (setq vundo-glyph-alist vundo-unicode-symbols)
  (with-eval-after-load 'vundo
    (define-key vundo-mode-map (kbd "l") #'vundo-forward)
    (define-key vundo-mode-map (kbd "h") #'vundo-backward)
    (define-key vundo-mode-map (kbd "j") #'vundo-next)
    (define-key vundo-mode-map (kbd "k") #'vundo-previous)
    (define-key vundo-mode-map (kbd "q") #'vundo-quit)))

;;; Evil core
(use-package evil
  :init
  (setq evil-want-keybinding nil)
  (setq evil-search-module 'isearch)
  :config
  (evil-mode 1)

  ;; Keybindings
  (define-key evil-normal-state-map (kbd "U") 'vundo)
  (define-key evil-normal-state-map (kbd "SPC") 'avy-goto-char-2)

  ;; Org-mode specific evil keys
  (evil-define-key 'normal org-mode-map (kbd "<tab>") #'org-cycle)
  (evil-define-key 'normal org-mode-map (kbd "TAB") #'org-cycle)

  ;; Shell buffers (async-shell-command, M-x shell) start in normal mode
  (evil-set-initial-state 'shell-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init '(magit dired wdired ibuffer)))

;;; Dirvish keeps Dired commands, with Vim-style navigation
(with-eval-after-load 'evil
  (with-eval-after-load 'dirvish
    (evil-define-key 'normal dirvish-mode-map
      (kbd "h") #'dired-up-directory
      (kbd "l") #'dired-find-file
      (kbd "RET") #'dired-find-file
      (kbd "q") #'dirvish-quit
      (kbd "?") #'dirvish-dispatch
      (kbd "TAB") #'dirvish-subtree-toggle)))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package evil-commentary
  :config
  (evil-commentary-mode))

;;; Search with Anzu (needs evil-anzu bridge)
(use-package evil-anzu
  :after (evil anzu))

(provide 'init-evil)
;;; init-evil.el ends here
