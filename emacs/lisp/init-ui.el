;;; init-ui.el --- Modeline and UI polish

;; Theme
(load-theme 'modus-operandi-deuteranopia t)

;; Doom theme utilities (bold/italic enhancement, no doom theme loaded)
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-bar-width 4)
  (doom-modeline-buffer-file-name-style 'buffer-name)
  (doom-modeline-icon nil)
  (doom-modeline-major-mode-icon nil)
  (doom-modeline-file-time-icon nil)
  (doom-modeline-minor-modes nil)
  (doom-modeline-enable-word-count nil)
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-indent-info nil)
  (doom-modeline-project-detection 'auto)
  (doom-modeline-workspace-name t)
  (doom-modeline-env-version nil)
  (doom-modeline-position-line-format nil)
  (doom-modeline-position-column-format '("C%c"))
  (doom-modeline-position-column-line-format '("C%c")))

(provide 'init-ui)
;;; init-ui.el ends here
