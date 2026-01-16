;;; ==============================
;;; 1. PACKAGE MANAGER BOOTSTRAP
;;; ==============================
(require 'package)

;; Use HTTPS for security
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Bootstrap 'use-package' if it isn't installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)

;; Automatically download packages if they are missing
(setq use-package-always-ensure t)

(use-package exec-path-from-shell
  :ensure t
  :if (memq window-system '(mac ns))
  :config
  (exec-path-from-shell-initialize))

;;; ==============================
;;; 2. GENERAL EMACS SETTINGS
;;; ==============================
(use-package emacs
  :ensure nil ;; 'emacs' is built-in, so don't try to download it
  :init
  ;; Backup settings
  (setq backup-directory-alist `(("." . "~/.emacs.d/.saves")))
  (setq delete-old-versions t
        kept-new-versions 4   ;; Fixed typo: was kept-new-version
        kept-old-versions 2   ;; Fixed typo: was kept-old-version
        version-control t)
  
  ;; Save/UI settings
  (setq auto-save-default nil)
  (setq auto-save-interval 10000)
  (setq case-fold-search t)
  (setq visible-bell nil)
  (setq ring-bell-function 'ignore)
  (setq inhibit-splash-screen t)
  (setq scroll-conservatively 101)
  (setq org-confirm-babel-evaluate nil)
  
  ;; Visuals
  (setq-default fill-column 80)
  (setq display-fill-column-indicator-column 80)
  (setq blink-matching-paren 'jump
        blink-matching-delay .2)
  (setq auto-save-visited-interval 60)
  (setq auto-save-no-message t)

  :config
  ;;(add-to-list 'default-frame-alist '(height . 120))
  (add-to-list 'default-frame-alist '(width . 95))
  (blink-cursor-mode 0)
  (global-hl-line-mode -1)
  (auto-save-visited-mode 1)
  
  (menu-bar-mode 1)
  (tool-bar-mode -1)
  (show-paren-mode t)
  (global-eldoc-mode -1)
  (electric-pair-mode 1)
  (electric-indent-mode 1)
  (global-display-line-numbers-mode t)
  (global-auto-revert-mode 1)
  
  ;; Hooks
  (add-hook 'prog-mode-hook 'display-fill-column-indicator-mode)
  
  (add-hook 'python-mode-hook (lambda ()
				;; Python mandates spaces, not tabs. 
				;; Setting this to 't' creates syntax errors in modern Python.
				(setq indent-tabs-mode nil) 
				(setq python-indent 4) 
				(setq python-indent-offset 4)
				(setq tab-width 4)))

  (defun my-python-run ()
    "Save and run the current python file (clean version)."
    (interactive)
    (when (eq major-mode 'python-mode)
      (save-buffer)
      ;; Just run python. The "Compilation started..." header 
      ;; will act as your separator.
      (compile (format "python3 %s" (shell-quote-argument (buffer-file-name))))))

  (with-eval-after-load 'python
    (define-key python-mode-map (kbd "<f5>") 'my-python-run))
  
  )


;;; ==============================
;;; 3. UNDO SYSTEM
;;; ==============================
;; Load this before Evil so Evil can link into it
(use-package undo-tree
  :diminish
  :init
  (setq undo-tree-auto-save-history t)
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo")))
  :config
  (global-undo-tree-mode))


;;; ==============================
;;; 4. EVIL MODE (VIM EMULATION)
;;; ==============================
(use-package evil
  :init
  (setq evil-want-keybinding nil)
  ;; (setq evil-emacs-state-cursor '("black" box)
  ;;       evil-normal-state-cursor '("purple" box)
  ;;       evil-visual-state-cursor '("orange" box)
  ;;       evil-insert-state-cursor '("magenta" bar))
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-tree)
  
  ;; Keybindings
  (define-key evil-normal-state-map (kbd "SPC") 'avy-goto-char-2)
  (evil-define-key 'normal org-mode-map (kbd "<tab>") #'org-cycle)
  (evil-define-key 'normal org-mode-map (kbd "TAB") #'org-cycle))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init '(magit dired ibuffer)))

;;; ==============================
;;; 5. UI & MODELINE
;;; ==============================
(use-package telephone-line
  :ensure t
  :init
  (setq telephone-line-primary-left-separator 'telephone-line-identity-left
        telephone-line-secondary-left-separator 'telephone-line-identity-hollow-left
        telephone-line-primary-right-separator 'telephone-line-identity-right
        telephone-line-secondary-right-separator 'telephone-line-identity-hollow-right)
  (setq telephone-line-height 20) ;; Optional: Makes the bar slightly thinner/sleeker

  (setq telephone-line-lhs
        '((evil   . (telephone-line-evil-tag-segment))
          (accent . (telephone-line-vc-segment))  ;; Git Branch
          (nil    . (telephone-line-buffer-segment))))

  (setq telephone-line-rhs
        '((nil    . (telephone-line-misc-info-segment)) ;; encoding/errors
          (accent . (telephone-line-major-mode-segment))
          (evil   . (telephone-line-airline-position-segment))))
  :config
  (telephone-line-evil-config)
  (telephone-line-mode 1))

;;; ==============================
;;; 6. AUTOCOMPLETE (COMPANY)
;;; ==============================
(use-package company
  :diminish
  :init
  (setq company-tooltip-idle-delay 10
	company-tooltip-minimum 4
	company-tooltip-minimum-width 40
	company-idle-delay .3
	company-show-numbers t
	company-echo-delay 0
	company-format-margin-function #'company-text-icons-margin)
  :config
  (global-company-mode))

;;; ==============================
;;; 7. NAVIGATION & SEARCH (IVY)
;;; ==============================
(use-package recentf
  :init
  (setq recentf-max-saved-items 150)
  :config
  (recentf-mode 1)
  (run-at-time nil (* 25 60) 'recentf-save-list))

(use-package ivy
  :diminish
  :init
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-height 15)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode 1) ;; Ensure ivy-mode is actually on
  (global-set-key (kbd "C-c C-r") 'ivy-resume)
  (global-set-key (kbd "C-x b") 'ivy-switch-buffer))

(use-package counsel
  :diminish
  :after ivy
  :config
  (counsel-mode 1)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "C-x C-r") 'counsel-recentf) ;; Moved from recentf block to here
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-h f") 'counsel-describe-function)
  (global-set-key (kbd "C-h v") 'counsel-describe-variable)
  (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history))

(use-package swiper
  :diminish
  :after ivy
  :config
  (global-set-key "\C-s" 'swiper))


;;; ==============================
;;; 8. UTILITIES
;;; ==============================

(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map)))

(use-package tramp
  :ensure nil
  :config
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

(use-package anzu
  :diminish
  :config
  (global-anzu-mode +1))

(use-package aggressive-indent
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'aggressive-indent-mode))

(use-package diminish)

(add-to-list 'load-path "~/.emacs.d/lisp/")
(require 'my-python)


