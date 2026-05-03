;;; init-daily-log.el --- Daily activity logging with Org capture and calendar view

;; Design
;; ──────
;; Activities (workout, reading, medication, diet, etc.) are logged as
;; level-4 headlines under a date-tree in ~/org/daily-log.org:
;;
;;   * 2026
;;   ** 2026-05 May
;;   *** 2026-05-03 Sunday
;;   **** Workout
;;   **** Reading :30min
;;   **** Medication :10min at 1pm
;;
;; Each activity is defined in `my/daily-log-activities' with a name,
;; single-letter code, and face (background color for the calendar/table).
;;
;; Two complementary views are provided:
;;
;; Calendar view (C-c v) — per-activity month grid
;;   Shows one activity at a time. Day numbers are color-coded when
;;   the activity occurred. Today is highlighted. Good for answering
;;   "how often did I do X this month?"
;;
;; Table view (C-c t) — per-day cross-activity scrollable table
;;   Shows all activities as columns, one row per day. Letters mark
;;   occurrence, dots mark absence. Scrollable with n/p (30-day jumps)
;;   and +/- (range). Good for answering "what did I do on date Y?"
;;   RET on a date opens daily-log.org at that day's subtree, folded
;;   to show only that entry.
;;
;; Capture (C-c d) — files a new entry under today's datetree heading.
;;   Prompts for activity, optionally type detail after the name.

;; How it works
;; ────────────
;; Parsing: `my/daily-log--parse-dates' scans the org file for a single
;; activity across all dates. `my/daily-log--parse-all' builds a
;; date→activities hash table for the cross-activity table.
;;
;; Calendar: `my/daily-log--render' builds a monospace grid of the
;; target month. Activity days get a background-colored face; today
;; gets a neutral highlight. n/p navigate months, g switches activity.
;;
;; Table: `my/daily-log--render-table' generates rows for a sliding
;; window of `range-days' days starting from `start-date'. Summary
;; counts are computed independently over the trailing range. n/p
;; shift the window by 30 days, +/- cycle the range (30/60/90/180/365).
;;
;; Both views use `special-mode' + `evil-set-initial-state' to 'emacs
;; so that single-letter keys (n/p/q/c/g/t/v) pass through to our
;; keymap instead of being intercepted by Evil.

(require 'cl-lib)
(require 'calendar)

;;; Activity definitions
(defvar my/daily-log-activities
  '(("Workout"    "W" my/daily-log-face-workout)
    ("Reading"    "R" my/daily-log-face-reading)
    ("Medication" "M" my/daily-log-face-medication)
    ("Diet"       "D" my/daily-log-face-diet))
  "List of activities: (name letter face).")

;;; Faces
(defface my/daily-log-face-workout
  '((t :background "#f0c0c0" :foreground "#600" :weight bold))
  "Face for Workout in daily log calendar.")

(defface my/daily-log-face-reading
  '((t :background "#c0d0f0" :foreground "#004" :weight bold))
  "Face for Reading in daily log calendar.")

(defface my/daily-log-face-medication
  '((t :background "#c0f0c0" :foreground "#060" :weight bold))
  "Face for Medication in daily log calendar.")

(defface my/daily-log-face-diet
  '((t :background "#f0e0c0" :foreground "#640" :weight bold))
  "Face for Diet in daily log calendar.")

(defface my/daily-log-face-today
  '((t :background "#e0e0e0" :weight bold))
  "Face for today's cell in daily log calendar.")

;;; Capture template
(with-eval-after-load 'org
  (require 'org-capture)
  (add-to-list 'org-capture-templates
               '("d" "Daily log" entry (file+datetree "~/org/daily-log.org")
                 "* %^{Activity|Workout|Reading|Medication|Diet} %?")))

;;; Calendar view

(defvar my/daily-log--buffer-name "*Daily Log*")
(defvar my/daily-log--data-file "~/org/daily-log.org")

(defun my/daily-log--parse-dates (activity)
  "Return list of date strings YYYY-MM-DD that have ACTIVITY logged."
  (let ((pattern (concat "^\\*\\*\\*\\* " (regexp-quote activity) "\\( \\|$\\)"))
        dates)
    (when (file-exists-p my/daily-log--data-file)
      (with-temp-buffer
        (insert-file-contents my/daily-log--data-file)
        (goto-char (point-min))
        (while (re-search-forward pattern nil t)
          (save-excursion
            (when (re-search-backward "^\\*\\*\\* \\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\)" nil t)
              (cl-pushnew (match-string 1) dates :test #'string=))))))
    (nreverse dates)))

(defun my/daily-log--count-in-range (dates range-days)
  "Count how many DATES fall within RANGE-DAYS before today."
  (let* ((now (current-time))
         (cutoff (time-subtract now (days-to-time (1- range-days))))
         (cutoff-str (format-time-string "%Y-%m-%d" cutoff))
         (count 0))
    (dolist (d dates)
      (when (not (string< d cutoff-str))
        (setq count (1+ count))))
    count))

(defun my/daily-log--activity-by-letter (letter)
  "Return the activity name for LETTER."
  (cl-find-if (lambda (a) (string= (nth 1 a) letter)) my/daily-log-activities))

(defun my/daily-log--activity-by-name (name)
  "Return the activity entry for NAME."
  (cl-find-if (lambda (a) (string= (nth 0 a) name)) my/daily-log-activities))

(defun my/daily-log--parse-all ()
  "Return hash table: date string (YYYY-MM-DD) -> list of activity names."
  (let ((table (make-hash-table :test #'equal))
        (names (mapcar #'car my/daily-log-activities)))
    (when (file-exists-p my/daily-log--data-file)
      (with-temp-buffer
        (org-mode)
        (insert-file-contents my/daily-log--data-file)
        (goto-char (point-min))
        (while (re-search-forward "^\\*\\*\\* \\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\)" nil t)
          (let ((date (match-string 1))
                (date-end (save-excursion (org-end-of-subtree)))
                (activities nil))
            (while (re-search-forward "^\\*\\*\\*\\* \\(.+\\)$" date-end t)
              (let ((heading (match-string 1)))
                (dolist (name names)
                  (when (string-prefix-p name heading)
                    (push name activities)))))
            (when activities
              (puthash date (nreverse activities) table))))))
    table))

(defun my/daily-log--render-table (start-date range-days &optional buffer)
  "Render a scrollable per-day cross-activity table.
START-DATE is a time value for the first row.
RANGE-DAYS is how many days to show (and summary range)."
  (let* ((all-data (my/daily-log--parse-all))
         (names (mapcar #'car my/daily-log-activities))
         (letters (mapcar #'cadr my/daily-log-activities))
         (faces (mapcar #'caddr my/daily-log-activities))
         (today-str (format-time-string "%Y-%m-%d"))
         (counts (make-vector (length names) 0))
         (rows nil))
    ;; Compute per-activity counts over trailing range (independent of window)
    (dotimes (d range-days)
      (let* ((date-key (format-time-string
                        "%Y-%m-%d"
                        (time-subtract (current-time) (days-to-time d))))
             (acts (gethash date-key all-data)))
        (dotimes (i (length names))
          (when (member (nth i names) acts)
            (aset counts i (1+ (aref counts i)))))))
    ;; Build list of dates from start-date for range-days (table rows)
    (dotimes (d range-days)
      (let* ((date-ts (time-add start-date (days-to-time d)))
             (date-key (format-time-string "%Y-%m-%d" date-ts))
             (date-display (format-time-string "%Y-%m-%d %a" date-ts))
             (acts (gethash date-key all-data)))
        (push (list date-key date-display (or acts '())) rows)))
    (setq rows (nreverse rows))
    ;; Render
    (with-current-buffer (or buffer (get-buffer-create "*Daily Log Table*"))
      (let ((inhibit-read-only t))
        (erase-buffer)
        ;; --- Legend ---
        (dolist (entry my/daily-log-activities)
          (insert (propertize (format " %s=%s " (nth 1 entry) (nth 0 entry))
                              'face `(:inherit ,(nth 2 entry) :weight bold))))
        (insert "\n")
        ;; --- Summary count line ---
        (insert (format "Showing %d days from %s.  Summary (last %d days):"
                        range-days
                        (format-time-string "%Y-%m-%d" start-date)
                        range-days))
        (dotimes (i (length names))
          (insert (propertize (format "  %s:%d" (nth i letters) (aref counts i))
                              'face `(:inherit ,(nth i faces)))))
        (insert "\n")
        (insert (make-string 78 ?─) "\n\n")
        ;; --- Table header ---
        (insert (format "  %-14s " "Date"))
        (dotimes (i (length names))
          (insert (propertize (format " %s " (nth i letters))
                              'face `(:inherit ,(nth i faces) :weight bold))))
        (insert "\n")
        (insert (format "  %s" (make-string 14 ?─)))
        (dotimes (_ (length names))
          (insert (make-string 3 ?─)))
        (insert "\n")
        ;; --- Table rows ---
        (dolist (entry rows)
          (let* ((date-key (nth 0 entry))
                 (date-display (nth 1 entry))
                 (acts (nth 2 entry))
                 (is-today (string= date-key today-str)))
            (insert (if is-today
                        (propertize (format "  %-14s " date-display)
                                    'face 'my/daily-log-face-today)
                      (format "  %-14s " date-display)))
            (dotimes (i (length names))
              (let ((act-name (nth i names))
                    (letter (nth i letters))
                    (face (nth i faces)))
                (if (member act-name acts)
                    (insert (propertize (format " %s " letter) 'face face))
                  (insert " . "))))
            (insert "\n")))
        ;; --- Help line ---
        (insert (format "\n%s\n"
                        (make-string 78 ?─)))
        (insert (propertize "q=quit  n/p=scroll 30d  +/- =range  v=calendar  c=capture"
                            'face 'shadow))
        (insert "\n"))
      ;; Set up buffer state — mode first (it kills locals), then set vars
      (my/daily-log-table-mode)
      (setq-local my/daily-log--start-date start-date)
      (setq-local my/daily-log--range-days range-days)
      (setq buffer-read-only t)
      (goto-char (point-min))
      (when (re-search-forward (format "^  %s" (regexp-quote today-str)) nil t)
        (goto-char (line-beginning-position)))
      (current-buffer))))

(defun my/daily-log--render (activity month year range-days &optional buffer)
  "Render the daily log calendar for ACTIVITY in MONTH/YEAR."
  (let* ((dates (my/daily-log--parse-dates activity))
         (entry (my/daily-log--activity-by-name activity))
         (letter (nth 1 entry))
         (face (nth 2 entry))
         (today-str (format-time-string "%Y-%m-%d"))
         (today-decoded (decode-time))
         (today-day (decoded-time-day today-decoded))
         (today-month (decoded-time-month today-decoded))
         (today-year (decoded-time-year today-decoded))
         ;; First day of target month
         (first-ts (encode-time (list 0 0 0 1 month year)))
         (first-decoded (decode-time first-ts))
         (first-dow (decoded-time-weekday first-decoded)) ; 0=Sun..6=Sat
         (start-offset (if (= first-dow 0) 6 (1- first-dow))) ; Mon=0..Sun=6
         ;; Days in month
         (days-in-month (calendar-last-day-of-month month year))
         ;; Summary count
         (summary-count (my/daily-log--count-in-range dates range-days))
         ;; Build date set for fast lookup
         (date-set (make-hash-table :test #'equal)))
    ;; Populate date set
    (dolist (d dates) (puthash d t date-set))
    ;; Render
    (with-current-buffer (or buffer (get-buffer-create my/daily-log--buffer-name))
      (let ((inhibit-read-only t))
        (erase-buffer)
        ;; --- Summary header ---
        (insert (format "Activity: %s        Range: last %d days        Count: %d / %d\n"
                        (propertize activity 'face `(:inherit ,face :weight bold))
                        range-days summary-count range-days))
        (insert (format "%s\n" (make-string 70 ?─)))
        ;; --- Month header ---
        (insert (format "\n%22s %d\n\n"
                        (format-time-string "%B" first-ts) year))
        ;; --- Day header ---
        (dolist (day '("Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun"))
          (insert (propertize (format "%4s" day) 'face 'bold)))
        (insert "\n")
        ;; --- Calendar grid ---
        ;; Fill leading blanks
        (dotimes (_ start-offset) (insert "   ."))
        ;; Fill days
        (dotimes (d days-in-month)
          (let* ((day (1+ d))
                 (date-str (format "%04d-%02d-%02d" year month day))
                 (has-activity (gethash date-str date-set))
                 (is-today (and (= day today-day)
                                (= month today-month)
                                (= year today-year)))
                 (cell-str (format "%-2d" day))
                 (face-attr (cond
                             ((and is-today has-activity) face)
                             (is-today 'my/daily-log-face-today)
                             (has-activity face)
                             (t nil))))
            ;; Newline at week boundary
            (when (and (> day 1) (= (mod (+ d start-offset) 7) 0))
              (insert "\n"))
            (if face-attr
                (insert " " (propertize cell-str 'face face-attr) " ")
              (insert " " cell-str " "))))
        (insert "\n\n")
        ;; --- Help line ---
        (insert (propertize "q=quit  n/p=month  +/- =range  g=change activity  c=capture"
                            'face 'shadow))
        (insert "\n"))
      ;; Set up buffer state — mode first (it kills locals), then set vars
      (my/daily-log-mode)
      (setq-local my/daily-log--activity activity)
      (setq-local my/daily-log--month month)
      (setq-local my/daily-log--year year)
      (setq-local my/daily-log--range-days range-days)
      (setq buffer-read-only t)
      (goto-char (point-min))
      (current-buffer))))

(defvar my/daily-log-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "n") #'my/daily-log-next-month)
    (define-key map (kbd "p") #'my/daily-log-prev-month)
    (define-key map (kbd "+") #'my/daily-log-inc-range)
    (define-key map (kbd "-") #'my/daily-log-dec-range)
    (define-key map (kbd "g") #'my/daily-log-refresh)
    (define-key map (kbd "t") #'my/daily-log-switch-to-table)
    (define-key map (kbd "RET") #'my/daily-log-calendar-visit-date)
    (define-key map (kbd "c") #'my/daily-log-capture)
    (define-key map (kbd "q") #'quit-window)
    map)
  "Keymap for daily log calendar view.")

(define-derived-mode my/daily-log-mode special-mode "DailyLog"
  "Major mode for viewing daily activity log calendar.
\\{my/daily-log-mode-map}")

;; Keep Evil from intercepting n/p/q etc. in this buffer
(with-eval-after-load 'evil
  (evil-set-initial-state 'my/daily-log-mode 'emacs))

(defvar-local my/daily-log--activity nil)
(defvar-local my/daily-log--month nil)
(defvar-local my/daily-log--year nil)
(defvar-local my/daily-log--range-days nil)
(defvar my/daily-log--range-values '(30 60 90 180 365))

(defun my/daily-log--closest-range-index ()
  "Return index of closest range value >= current range-days, or last index."
  (or (cl-position-if (lambda (v) (>= v my/daily-log--range-days))
                      my/daily-log--range-values)
      (1- (length my/daily-log--range-values))))

(defun my/daily-log--days-in-current-month ()
  "Return number of days in the currently displayed month."
  (calendar-last-day-of-month my/daily-log--month my/daily-log--year))

;;; Commands

(defun my/daily-log (activity month year range-days)
  "Open the daily log calendar view.
ACTIVITY: string name of activity (prompt if interactive).
MONTH, YEAR: target month (defaults to current).
RANGE-DAYS: summary range in days."
  (interactive
   (let* ((activity (completing-read "Activity: "
                                     (mapcar #'car my/daily-log-activities)
                                     nil t nil nil "Workout"))
          (now (decode-time))
          (month (decoded-time-month now))
          (year (decoded-time-year now)))
     (list activity month year
           (calendar-last-day-of-month month year))))
  (pop-to-buffer (my/daily-log--render activity month year range-days)))

(defun my/daily-log-next-month ()
  "Move to the next month."
  (interactive)
  (let ((month my/daily-log--month)
        (year my/daily-log--year))
    (if (= month 12)
        (setq month 1 year (1+ year))
      (setq month (1+ month)))
    (my/daily-log--render my/daily-log--activity month year
                          my/daily-log--range-days (current-buffer))))

(defun my/daily-log-prev-month ()
  "Move to the previous month."
  (interactive)
  (let ((month my/daily-log--month)
        (year my/daily-log--year))
    (if (= month 1)
        (setq month 12 year (1- year))
      (setq month (1- month)))
    (my/daily-log--render my/daily-log--activity month year
                          my/daily-log--range-days (current-buffer))))

(defun my/daily-log-inc-range ()
  "Increase the summary date range."
  (interactive)
  (let* ((idx (my/daily-log--closest-range-index))
         (new-idx (min (1+ idx) (1- (length my/daily-log--range-values)))))
    (setq my/daily-log--range-days (nth new-idx my/daily-log--range-values))
    (my/daily-log--render my/daily-log--activity my/daily-log--month
                          my/daily-log--year my/daily-log--range-days
                          (current-buffer))))

(defun my/daily-log-dec-range ()
  "Decrease the summary date range."
  (interactive)
  (let* ((idx (my/daily-log--closest-range-index))
         (new-idx (max (1- idx) 0)))
    (setq my/daily-log--range-days (nth new-idx my/daily-log--range-values))
    (my/daily-log--render my/daily-log--activity my/daily-log--month
                          my/daily-log--year my/daily-log--range-days
                          (current-buffer))))

(defun my/daily-log-refresh ()
  "Refresh the view (prompt for different activity)."
  (interactive)
  (let ((activity (completing-read "Activity: "
                                   (mapcar #'car my/daily-log-activities)
                                   nil t nil nil my/daily-log--activity)))
    (my/daily-log--render activity my/daily-log--month
                          my/daily-log--year my/daily-log--range-days
                          (current-buffer))))

(defun my/daily-log-capture ()
  "Run daily log capture from the calendar view."
  (interactive)
  (org-capture nil "d"))

(defun my/daily-log--goto-date (date)
  "Show DATE details in a bottom side window without moving focus."
  (let ((org-buf (find-file-noselect my/daily-log--data-file))
        (detail-buf (get-buffer-create "*Daily Log Detail*"))
        (items nil))
    (with-current-buffer org-buf
      (save-excursion
        (goto-char (point-min))
        (when (re-search-forward (format "^\\*\\*\\* %s" (regexp-quote date)) nil t)
          (let ((subtree-end (save-excursion (org-end-of-subtree) (point))))
            (forward-line 1)
            (while (< (point) subtree-end)
              (when (looking-at "^\\*\\*\\*\\* \\(.+\\)$")
                (push (match-string 1) items))
              (forward-line 1))))))
    (when items
      (setq items (nreverse items))
      (with-current-buffer detail-buf
        (let ((inhibit-read-only t))
          (erase-buffer)
          (insert (propertize (format "%s\n" date) 'face 'bold) "\n")
          (dolist (item items)
            (insert (format "  %s\n" item)))
          (setq buffer-read-only t)
          (goto-char (point-min))))
      (display-buffer detail-buf
                      '((display-buffer-in-side-window)
                        (side . bottom)
                        (window-height . fit-window-to-buffer))))))

(defun my/daily-log--goto-date-expanded (date)
  "Open daily-log.org, expand DATE subtree, put it at top of window."
  (let* ((buf (find-file-noselect my/daily-log--data-file))
         (win (get-buffer-window buf)))
    (unless win
      (setq win (display-buffer buf
                                '((display-buffer-in-side-window)
                                  (side . bottom)
                                  (window-height . 0.4)))))
    (with-current-buffer buf
      (goto-char (point-min))
      ;; Navigate to first heading, skipping any #+ keywords or blank lines
      (org-next-visible-heading 1)
      (org-fold-hide-subtree)
      (goto-char (point-min))
      (when (re-search-forward (format "^\\*\\*\\* %s" (regexp-quote date)) nil t)
        (goto-char (line-beginning-position))
        (org-fold-show-entry)       ;; reveal heading + ancestors (year, month)
        (org-fold-show-subtree)     ;; expand children (activities)
        (set-window-start win (point))
        (set-window-point win (point))))))

(defun my/daily-log-table-visit-date ()
  "Open the date under cursor with expanded subtree (table view)."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (when (looking-at "  \\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\)")
      (my/daily-log--goto-date-expanded (match-string 1)))))

(defun my/daily-log-calendar-visit-date ()
  "Open the date under cursor (calendar view)."
  (interactive)
  (let ((word (thing-at-point 'word)))
    (when (and word (string-match "\\`[0-9]+\\'" word))
      (let* ((day (string-to-number word))
             (date (format "%04d-%02d-%02d"
                           my/daily-log--year
                           my/daily-log--month
                           day)))
        (my/daily-log--goto-date date)))))

(defun my/daily-log-switch-to-table ()
  "Switch from calendar view to table view."
  (interactive)
  (let ((start (encode-time (list 0 0 0 1 my/daily-log--month my/daily-log--year))))
    (my/daily-log--render-table start my/daily-log--range-days (current-buffer))))

;;; Table view

(defvar-local my/daily-log--start-date nil
  "Start date (time value) for the table view window.")

(defvar my/daily-log-table-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "n") #'my/daily-log-table-scroll-forward)
    (define-key map (kbd "p") #'my/daily-log-table-scroll-backward)
    (define-key map (kbd "+") #'my/daily-log-table-inc-range)
    (define-key map (kbd "-") #'my/daily-log-table-dec-range)
    (define-key map (kbd "v") #'my/daily-log-switch-to-calendar)
    (define-key map (kbd "RET") #'my/daily-log-table-visit-date)
    (define-key map (kbd "c") #'my/daily-log-capture)
    (define-key map (kbd "q") #'quit-window)
    map)
  "Keymap for daily log table view.")

(define-derived-mode my/daily-log-table-mode special-mode "DailyLogTable"
  "Major mode for viewing daily activity log table.
\\{my/daily-log-table-mode-map}")

(with-eval-after-load 'evil
  (evil-set-initial-state 'my/daily-log-table-mode 'emacs))

(defun my/daily-log-table (range-days)
  "Open the daily log table view (all activities, one row per day).
Default window: current month, then +/- to expand."
  (interactive
   (let* ((now (decode-time))
          (month (decoded-time-month now))
          (year (decoded-time-year now)))
     (list (calendar-last-day-of-month month year))))
  (let* ((now (decode-time))
         (start (encode-time (list 0 0 0 1 (decoded-time-month now)
                                   (decoded-time-year now)))))
    (pop-to-buffer (my/daily-log--render-table start range-days))))

(defun my/daily-log-switch-to-calendar ()
  "Switch from table view to calendar view."
  (interactive)
  (let ((start-decoded (decode-time my/daily-log--start-date)))
    (my/daily-log--render (nth 0 (car my/daily-log-activities))
                          (decoded-time-month start-decoded)
                          (decoded-time-year start-decoded)
                          my/daily-log--range-days (current-buffer))))

(defun my/daily-log-table-scroll-forward ()
  "Scroll the table window forward by 30 days."
  (interactive)
  (let ((new-start (time-add my/daily-log--start-date (days-to-time 30))))
    (my/daily-log--render-table new-start my/daily-log--range-days
                                (current-buffer))))

(defun my/daily-log-table-scroll-backward ()
  "Scroll the table window backward by 30 days."
  (interactive)
  (let ((new-start (time-subtract my/daily-log--start-date (days-to-time 30))))
    (my/daily-log--render-table new-start my/daily-log--range-days
                                (current-buffer))))

(defun my/daily-log-table-inc-range ()
  "Increase the range (more rows + larger summary window)."
  (interactive)
  (let* ((idx (my/daily-log--closest-range-index))
         (new-idx (min (1+ idx) (1- (length my/daily-log--range-values)))))
    (setq my/daily-log--range-days (nth new-idx my/daily-log--range-values))
    (my/daily-log--render-table my/daily-log--start-date
                                my/daily-log--range-days (current-buffer))))

(defun my/daily-log-table-dec-range ()
  "Decrease the range (fewer rows + smaller summary window)."
  (interactive)
  (let* ((idx (my/daily-log--closest-range-index))
         (new-idx (max (1- idx) 0)))
    (setq my/daily-log--range-days (nth new-idx my/daily-log--range-values))
    (my/daily-log--render-table my/daily-log--start-date
                                my/daily-log--range-days (current-buffer))))

;;; Global keybindings
(global-set-key (kbd "C-c d") (lambda () (interactive) (org-capture nil "d")))
(global-set-key (kbd "C-c v") #'my/daily-log)
(global-set-key (kbd "C-c t") #'my/daily-log-table)

(provide 'init-daily-log)
;;; init-daily-log.el ends here
