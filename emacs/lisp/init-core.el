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

  ;; Matching
  (setq blink-matching-paren 'jump
        blink-matching-delay .2)

  ;; Fill column indicator
  (setq-default fill-column 80)
  (setq display-fill-column-indicator-column 80)

  :config
  ;; Keep the default font family, but use a larger size.
  (when (eq system-type 'darwin)
    (set-face-attribute 'default nil :height 200))

  ;; GUI Emacs on Linux may not inherit the interactive shell PATH.
  (let ((local-bin (expand-file-name "~/.local/bin")))
    (when (file-directory-p local-bin)
      (add-to-list 'exec-path local-bin)
      (setenv "PATH" (concat local-bin path-separator (getenv "PATH")))))

  (auto-save-visited-mode 1)
  (global-hl-line-mode -1)
  (show-paren-mode t)
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
  (add-hook 'before-save-hook 'delete-trailing-whitespace)
  (add-hook 'prog-mode-hook 'display-fill-column-indicator-mode))

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
