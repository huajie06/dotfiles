;;; init-org.el --- Modern Data Science & LeetCode Org Setup

;; 1. MAIN ORG CONFIGURATION
;; ----------------------------------------------------------------
(use-package org
  :bind
  (("C-c a" . org-agenda)
   ("C-c c" . org-capture))
  :hook
  (org-mode . turn-on-auto-fill)
  :config
  ;; Disable auto-pairing of < > in Org mode only
  (add-hook 'org-mode-hook (lambda () (modify-syntax-entry ?< ".")))

  ;; --- TEXT WRAPPING ---
  ;; Set the line length (80 is standard, 100 is wider)
  (setq-default fill-column 80)

  ;; --- VISUALS & UI ---
  (setq org-startup-indented t         ; Visual indentation
        org-image-actual-width 600     ; Resize inline images
        org-hide-emphasis-markers t    ; Hide *bold* /italic/ markers
        org-ellipsis " ▾")             ; Nicer folding symbol

  ;; --- DIRECTORIES ---
  (setq org-directory "~/org"
        org-agenda-files '("~/org/todos.org"
                           "~/org/projects.org"
                           "~/org/leetcode.org"))

  ;; --- CAPTURE TEMPLATES ---
  (setq org-capture-templates
        '(("t" "Todo" entry (file+headline "~/org/todos.org" "Inbox")
           "* TODO %?\n  %i\n  %a")
          ("n" "Note/Idea" entry (file+headline "~/org/notes.org" "Inbox")
           "* %?\n  %U\n  %i")
          ;; LeetCode with Auto-Clocking
          ("l" "LeetCode" entry (file+headline "~/org/leetcode.org" "Practice")
           "* TODO %^{Problem Name}
  :PROPERTIES:
  :Source: %^{Link}
  :Language: %^{Language}
  :END:
  :LOGBOOK:
  :END:

  %?

#+BEGIN_SRC %\\3
#+END_SRC"
           :clock-in t
           :clock-resume t)))

  ;; --- BABEL (CODE EXECUTION) ---
  (setq org-confirm-babel-evaluate nil      ; Don't ask for permission
        org-src-preserve-indentation t      ; Critical for Python
        org-src-fontify-natively t          ; Syntax highlighting
        org-src-tab-acts-natively t)        ; Tab works like code

  ;; Enable Languages
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (C . t)
     (shell . t)))

  ;; Hooks for Data Science (Images)
  (add-hook 'org-babel-after-execute-hook 'org-display-inline-images)

  ;; Safety for .dir-locals.el
  (put 'org-babel-python-command 'safe-local-variable 'stringp))

;; 2. ORG TEMPO (Start blocks with <py)
;; ----------------------------------------------------------------
(use-package org-tempo
  :ensure nil ; Part of Org, no need to install
  :after org
  :config
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("pys" . "src python :session *main* :results output")))

;; 3. ORG BULLETS (Visual Polish)
;; ----------------------------------------------------------------
(use-package org-bullets
  :ensure t
  :hook (org-mode . org-bullets-mode))

;; 4. ORG DOWNLOAD (Drag & Drop Images)
;; ----------------------------------------------------------------
;; Since you're doing data science/LeetCode, you'll want to paste screenshots.
(use-package org-download
  :ensure t
  :after org
  :hook (dired-mode . org-download-enable)
  :config
  (setq org-download-image-dir "~/org/images"))

(require 'org-clock)
(defun org-dblock-write:daily-summary (params)
  "Generates a single table with one row per day and a grand total."
  (let* ((block (plist-get params :block))
         (range (if block
                    (org-clock-special-range block nil
                                             (plist-get params :wstart)
                                             (plist-get params :mstart))
                  (list (org-time-string-to-time (plist-get params :tstart))
                        (org-time-string-to-time (plist-get params :tend)))))
         (start (car range))
         (end (cadr range))
         (current start)
         (grand-total 0) ;; Track total minutes here
         (rows nil))

    ;; Loop through each day
    (while (time-less-p current end)
      (let* ((next (time-add current (days-to-time 1))))
        (org-clock-sum current next)
        (let ((total org-clock-file-total-minutes))
          (when (> total 0)
            (setq grand-total (+ grand-total total)) ;; Accumulate
            (push (list (format-time-string "%Y-%m-%d" current)
                        (org-duration-from-minutes total))
                  rows)))
        (setq current next)))

    ;; Create table
    (insert "| Date | Time |\n")
    (insert "|--|--|\n")
    (dolist (row (nreverse rows))
      (insert (format "| %s | %s |\n" (nth 0 row) (nth 1 row))))

    ;; Add the Total Row
    (insert "|--|\n")
    (insert (format "| **Total** | **%s** |\n" (org-duration-from-minutes grand-total)))
    (org-table-align)))

(provide 'init-org)
