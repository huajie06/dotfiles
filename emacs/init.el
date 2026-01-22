;; 1. Get the directory where THIS file (init.el) resides.
;;    If this file is loaded, use load-file-name.
;;    If we are evaluating the buffer directly, use buffer-file-name.
(defconst my-config-path
  (file-name-directory (or load-file-name buffer-file-name)))

;; 2. Construct the full path to the 'lisp' folder relative to this file
(defconst my-lisp-path
  (expand-file-name "lisp" my-config-path))

;; 3. Add that path to the load-path
(add-to-list 'load-path my-lisp-path)


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
  (global-set-key (kbd "<f12>") 'toggle-truncate-lines)


  ;; Hooks
  (add-hook 'before-save-hook 'delete-trailing-whitespace)
  (add-hook 'prog-mode-hook 'display-fill-column-indicator-mode))

;;; ==============================
;;; python setup
;;; ==============================
;; 1. Grammar Management (Keep this as is, but removed the :mode line)
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

;; 2. Python Configuration
(use-package python
  :ensure nil
  :custom
  (python-indent-offset 4)
  (python-indent-guess-indent-offset nil)
  (indent-tabs-mode nil)

  ;; BEST PRACTICE: Use remapping instead of hardcoding file extensions.
  ;; This tells Emacs: "Whenever you would load python-mode, load python-ts-mode instead."
  ;; if i cannot compile python-grammar, comment off init
  :init
  (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))

  ;; Bind keys to the SHARED map so they work in both modes
  :bind (:map python-base-mode-map
              ("<f5>" . my-python-run))
  :config
  (defun my-python-run ()
    "Save and run the current python file."
    (interactive)
    ;; FIX: Check 'python-base-mode' (the parent), NOT 'python-mode'.
    ;; 'python-ts-mode' does NOT inherit from 'python-mode', so your old check failed here.
    (when (derived-mode-p 'python-base-mode)
      (save-buffer)
      (compile (format "python3 %s" (shell-quote-argument (buffer-file-name))))))

  ;; Enable electric indent (newline auto-indents)
  (electric-indent-local-mode 1))

;;; ==============================
;;; 3. UNDO SYSTEM
;;; ==============================

;; 1. The Undo Backend (The "Engine")
;; This enables the "u" and "C-r" keys in Evil to work without undo-tree.
(use-package undo-fu
  :ensure t
  :config
  ;; CRITICAL: Tell Evil to use undo-fu instead of undo-tree
  (setq evil-undo-system 'undo-fu))

;; 2. Persistent History (The "Save File")
;; This replaces the "history file" part of undo-tree.
;; It is much more robust and rarely corrupts files.
(use-package undo-fu-session
  :ensure t
  :init
  (undo-fu-session-global-mode)
  :config
  (setq undo-fu-session-incompatible-files '("/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'")))

;; 3. The Visualizer (The UI)
;; This replaces the "C-x u" visual tree.
(use-package vundo
  :ensure t
  :bind ("C-x u" . vundo)
  :config
  ;; Optional: Use nicer symbols for the tree
  (setq vundo-glyph-alist vundo-unicode-symbols)

  ;; Make vundo feel like Vim!
  ;; By default, vundo uses f/b/n/p. Let's use h/j/k/l.
  (with-eval-after-load 'vundo
    (define-key vundo-mode-map (kbd "l") #'vundo-forward)
    (define-key vundo-mode-map (kbd "h") #'vundo-backward)
    (define-key vundo-mode-map (kbd "j") #'vundo-next)
    (define-key vundo-mode-map (kbd "k") #'vundo-previous)
    (define-key vundo-mode-map (kbd "q") #'vundo-quit)))

;;; ==============================
;;; 4. EVIL MODE (VIM EMULATION)
;;; ==============================
(use-package evil
  :init
  (setq evil-want-keybinding nil)
  (setq evil-search-module 'isearch)
  :config
  (evil-mode 1)
  ;; (setq isearch-lazy-count t)
  ;; (setq isearch-lazy-highlight t)
  ;; (setq lazy-highlight-cleanup nil)
  ;; (setq lazy-highlight-initial-delay 0)

  ;; (setq lazy-count-prefix-format nil)
  ;; (setq lazy-count-suffix-format " [%s/%s]")

  ;; Add this to your general Evil config
  ;;(define-key evil-motion-state-map (kbd "/") 'consult-line)
  (define-key evil-normal-state-map (kbd "U") 'vundo)

  ;; Keybindings
  (define-key evil-normal-state-map (kbd "SPC") 'avy-goto-char-2)
  (evil-define-key 'normal org-mode-map (kbd "<tab>") #'org-cycle)
  (evil-define-key 'normal org-mode-map (kbd "TAB") #'org-cycle))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init '(magit dired wdired ibuffer)))

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
  (setq telephone-line-height 20)

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
;;; 6. AUTOCOMPLETE
;;; ==============================
;; 1. CORFU (The UI)
;; Your existing config is good. I kept it identical.
(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.3)
  (corfu-auto-prefix 3)
  (corfu-cycle t)
  (corfu-quit-no-match 'separator)
  :init
  (global-corfu-mode)
  :bind (:map corfu-map
              ("RET" . nil)
              ("TAB" . corfu-insert)
              ("<tab>" . corfu-insert)
              ("C-n" . corfu-next)
              ("C-p" . corfu-previous))
  :config
  ;; Fix for Evil: Ensure corfu-map has priority
  (evil-make-overriding-map corfu-map 'insert)

  (advice-add #'corfu--setup :after (lambda (&rest _) (evil-normalize-keymaps)))
  (advice-add #'corfu--teardown :after (lambda (&rest _) (evil-normalize-keymaps))))

;; 2. CAPE (The Backends)
(use-package cape
  :ensure t
  :init
  ;; ---------------------------------------------------------
  ;; A. Define your custom wrappers
  ;; ---------------------------------------------------------
  (defun my/cape-dabbrev-silent ()
    "A wrapper for dabbrev that suppresses the annotation label."
    (cape-capf-properties #'cape-dabbrev :annotation-function (lambda (_) nil)))

  ;; ---------------------------------------------------------
  ;; B. Global Defaults (For LOCAL files)
  ;; ---------------------------------------------------------
  ;; Note: I removed the duplicate 'cape-dabbrev' line you had.
  ;; You only need your silent wrapper.
  (add-to-list 'completion-at-point-functions #'cape-file)            ; File paths (Great locally)
  (add-to-list 'completion-at-point-functions #'cape-keyword)         ; Language keywords
  (add-to-list 'completion-at-point-functions #'my/cape-dabbrev-silent) ; Words in buffer

  (setq cape-dabbrev-check-other-buffers t)

  :config
  ;; ---------------------------------------------------------
  ;; C. TRAMP Safety Hook (The Fix)
  ;; ---------------------------------------------------------
  (defun my/configure-remote-completion ()
    "Strip out unsafe backends and tune corfu for TRAMP buffers."
    (when (file-remote-p default-directory)
      ;; 1. Force the backend list to ONLY be safe text-based sources.
      ;;    We intentionally OMIT #'cape-file here to stop the recursion error.
      (setq-local completion-at-point-functions
                  (list #'my/cape-dabbrev-silent
                        #'cape-keyword))

      ;; 2. (Optional) Make Corfu slightly lazier on remote to prevent lag
      (setq-local corfu-auto-delay 0.5   ; Wait longer before popping up
                  corfu-auto-prefix 3))) ; Require 3 chars

  ;; Apply this hook to every file you open
  (add-hook 'find-file-hook #'my/configure-remote-completion))



;;; ==============================
;;; 7. NAVIGATION & SEARCH (MODERN STACK)
;;; ==============================
;; 1. PERSISTENCE (Crucial for sorting M-x by usage)
(use-package savehist
  :ensure nil ; Built-in
  :init
  (savehist-mode))

(use-package recentf
  :ensure nil ; Built-in
  :init
  (setq recentf-max-saved-items 150)
  :config
  (recentf-mode 1)
  (run-at-time nil (* 25 60) 'recentf-save-list))

;; 2. VERTICO (The UI)
(use-package vertico
  :ensure t
  :init
  (vertico-mode)
  :config
  (setq vertico-count 15)
  (setq vertico-resize t)
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)
              ("C-f" . vertico-exit)
              :map minibuffer-local-map
              ("M-h" . backward-kill-word)))

;; Restore "Resume" functionality
(use-package vertico-repeat
  :ensure nil ; Part of Vertico, do not download
  :after vertico
  :bind ("C-c C-r" . vertico-repeat))

;; 3. ORDERLESS (The fuzzy matching)
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; 4. MARGINALIA (Rich info in the list)
(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

;; 5. CONSULT (The Commands)
(use-package consult
  :ensure t
  :bind (("C-s" . consult-line)           ; Swiper replacement
         ("C-x b" . consult-buffer)       ; Switch buffer (includes recentf)
         ("C-x C-r" . consult-recent-file); Recent files specific
         ("M-y" . consult-yank-pop)       ; Kill-ring history
         ("M-g g" . consult-goto-line)    ; Goto line
         ("C-c r" . consult-ripgrep)      ; Recursive grep
         :map minibuffer-local-map
         ("C-r" . consult-history))       ; Minibuffer history
  :config
  (setq consult-preview-key 'any))

;; 6. EMBARK (Actions)
(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings)))

(use-package embark-consult
  :ensure t
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; 7. IBUFFER (Management) - Keep your existing setup!
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

  ;; 1. Define your groups
  (setq ibuffer-saved-filter-groups
        '(("default"
           ("Dired"    (mode . dired-mode))
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
                        (name . "^\\*Backtrace\\*$")))
           ;; "Default" contains anything that doesn't match above
           )))

  ;; 2. Force Ibuffer to use these groups on startup
  (add-hook 'ibuffer-mode-hook
            (lambda ()
              (ibuffer-switch-to-saved-filter-groups "default"))))


(use-package ibuffer-project
  :ensure t
  :hook
  (ibuffer-mode . (lambda ()
                    (setq ibuffer-filter-groups (ibuffer-project-generate-filter-groups))
                    (unless (eq ibuffer-sorting-mode 'project-file-relative)
                      (ibuffer-do-sort-by-project-file-relative)))))

;;; ==============================
;;; 8. UTILITIES
;;; ==============================

(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown")
  :bind (:map markdown-mode-map
              ("C-c C-e" . markdown-do)))

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status)
  :config
  ;; Optional: improved performance on Windows/macOS
  (setq magit-refresh-status-buffer nil))

(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map))

  :custom
  (setq projectile-indexing-method 'alien)
  (projectile-enable-caching t)

  (projectile-globally-ignored-directories
   '(".git" "node_modules" "dist" "build"
     "target" "vendor" ".idea" ".vscode"
     "venv" ".venv" "env" ".env" ".tox"
     "__pycache__" ".pytest_cache" ".mypy_cache" "htmlcov"
     "dist" "build" "site-packages"
     ))

  ;; 2. EXCLUDE EXTENSIONS
  ;; Ignore files with specific extensions (speed up search)
  (projectile-globally-ignored-file-suffixes
   '(".elc" ".pyc" ".o" ".class" ".jar" "pyo" "pyd"
     ".png" ".jpg" ".svg" ".db"))

  ;; 3. EXCLUDE SPECIFIC FILES
  ;; Ignore exact filenames
  (projectile-globally-ignored-files
   '("package-lock.json" "yarn.lock" ".DS_Store")))


(use-package consult-projectile
  :ensure t
  :after (consult projectile)
  :config
  (require 'consult-projectile))

(use-package tramp
  :ensure nil
  :config
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

(use-package anzu
  :ensure t
  :config
  (global-anzu-mode +1)
  (set-face-attribute 'anzu-mode-line nil
                      :foreground "purple" :weight 'bold))

(use-package evil-anzu
  :ensure t
  :after (evil anzu))

(use-package isearch
  :ensure nil ; Built-in
  :config
  ;; Show "3/15" in the modeline when searching
  (setq isearch-lazy-count t)

  ;; Optional: Don't wait for me to stop typing to count matches
  (setq isearch-lazy-highlight t))

(use-package aggressive-indent
  :ensure t
  :config
  (add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode))

(use-package diminish)

;;(add-to-list 'load-path "~/.emacs.d/lisp/")
(require 'my-python)
