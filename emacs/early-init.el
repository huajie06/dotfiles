;;; early-init.el --- Settings that run before the GUI initializes

;; Suppress the startup screen and open *scratch* buffer
(setq inhibit-startup-screen t)
(setq initial-buffer-choice t)
;; Belt-and-suspenders: ensure *scratch* is shown even if something
;; during init overrides the initial buffer choice
(add-hook 'emacs-startup-hook
          (lambda () (switch-to-buffer "*scratch*")))

;; Frame geometry — set before the first frame is created
(add-to-list 'default-frame-alist '(width . 95))

;; UI chrome — disable before GUI paints to avoid flicker
(menu-bar-mode 1)
(tool-bar-mode -1)
(blink-cursor-mode 0)

;; Scrolling
(setq scroll-conservatively 101)

;; Silent bell
(setq visible-bell nil)
(setq ring-bell-function 'ignore)

;; Load theme early to avoid flash of default theme
(load-theme 'modus-operandi t)

(provide 'early-init)
;;; early-init.el ends here
