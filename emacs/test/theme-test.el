(load-theme 'modus-operandi-deuteranopia t)

(defun my-telephone-line-sync-modus ()
  "Update telephone-line faces using current Modus palette."
  ;; Check if Modus is actually active/available to avoid errors if you switch themes
  (when (fboundp 'modus-themes-get-color-value)
    (let ((bg-active   (modus-themes-get-color-value 'bg-mode-line-active))
          (fg-active   (modus-themes-get-color-value 'fg-mode-line-active))
          (accent-bg   (modus-themes-get-color-value 'bg-cyan-subtle))
          (accent-fg   (modus-themes-get-color-value 'fg-main))
          (red-intense (modus-themes-get-color-value 'red-intense))
          (grn-intense (modus-themes-get-color-value 'green-intense))
          (blu-intense (modus-themes-get-color-value 'blue-intense)))

      ;; 1. Sync the 'accent' faces (only if the face has been generated)
      (when (facep 'telephone-line-accent-active)
        (set-face-attribute 'telephone-line-accent-active nil
                            :background accent-bg :foreground accent-fg))

      ;; 2. Sync the 'unnamed' faces (from the 'nil' segment)
      (when (facep 'telephone-line-unnamed-active)
        (set-face-attribute 'telephone-line-unnamed-active nil
                            :background bg-active :foreground fg-active)))))

