;;; init-completion.el --- Corfu, Cape, Vertico, Consult, Embark stack

;;; Corfu — in-buffer completion popup
(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 2)
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
  ;; Evil integration — defer until evil is loaded
  (with-eval-after-load 'evil
    (evil-make-overriding-map corfu-map 'insert)
    (advice-add #'corfu--setup :after (lambda (&rest _) (evil-normalize-keymaps)))
    (advice-add #'corfu--teardown :after (lambda (&rest _) (evil-normalize-keymaps)))))

;;; Cape — completion-at-point backends
(use-package cape
  :init
  (setq cape-dabbrev-check-other-buffers t)
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-keyword))

;;; Vertico — vertical minibuffer completion
(use-package vertico
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

(use-package vertico-repeat
  :ensure nil
  :after vertico
  :bind ("C-c C-r" . vertico-repeat))

;;; Orderless — flexible matching style
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;;; Marginalia — rich annotations in minibuffer
(use-package marginalia
  :init
  (marginalia-mode))

;;; Consult — enhanced commands
(use-package consult
  :bind (("C-s" . consult-line)
         ("C-x b" . consult-buffer)
         ("C-x C-r" . consult-recent-file)
         ("M-y" . consult-yank-pop)
         ("M-g g" . consult-goto-line)
         ("C-c r" . consult-ripgrep)
         :map minibuffer-local-map
         ("C-r" . consult-history))
  :config
  (setq consult-preview-key 'any))

;;; Embark — contextual actions
(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings)))

(use-package embark-consult
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(provide 'init-completion)
;;; init-completion.el ends here
