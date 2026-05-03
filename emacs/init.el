;;; init.el --- Emacs configuration loader

;; Determine the directory where this file resides
(defconst my-config-path
  (file-name-directory (or load-file-name buffer-file-name)))

;; Mimic native early-init.el loading (not auto-loaded since this
;; file lives in the repo, not ~/.emacs.d/)
(load (expand-file-name "early-init" my-config-path))

;; Add the lisp/ subdirectory to the load-path
(defconst my-lisp-path
  (expand-file-name "lisp" my-config-path))

(add-to-list 'load-path my-lisp-path)

;; Load modules in dependency order
(require 'init-core)       ;; package bootstrap, general Emacs settings
(require 'init-ui)         ;; doom-modeline
(require 'init-tools)      ;; magit, projectile, tramp, anzu, ibuffer
(require 'init-completion) ;; corfu, cape, vertico, consult, embark
(require 'init-evil)       ;; evil, evil-collection, evil-surround
(require 'init-python)     ;; python + tree-sitter
(require 'init-org)        ;; org-mode

(provide 'init)
;;; init.el ends here
