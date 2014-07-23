;;; hg-timemachine.el --- Walk through hg revisions of a file

;; Copyright (C) 2014 Peter Stiernström

;; Author: Peter Stiernström <peter@stiernstrom.se>
;; Version: 1.3
;; URL: https://hghub.com/pidu/hg-timemachine
;; Package-Requires: ((cl-lib "0.5"))
;; Keywords: hg

;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Use hg-timemachine to browse historic versions of a file with p
;;; (previous) and n (next).

(require 'cl-lib)

;;; Code:

(defvar hg-timemachine-directory nil)
(defvar hg-timemachine-file nil)
(defvar hg-timemachine-revision nil)

(defun hg-timemachine--revisions ()
 "List hg revisions of current buffers file."
 (let ((default-directory hg-timemachine-directory))
  (process-lines "hg" "log" "--template" "{node|short}\\n" hg-timemachine-file)))

(defun hg-timemachine-show-current-revision ()
 "Show last (current) revision of file."
 (interactive)
 (hg-timemachine-show-revision (car (hg-timemachine--revisions))))

(defun hg-timemachine-show-previous-revision ()
 "Show previous revision of file."
 (interactive)
 (hg-timemachine-show-revision (cadr (member hg-timemachine-revision (hg-timemachine--revisions)))))

(defun hg-timemachine-show-next-revision ()
 "Show next revision of file."
 (interactive)
 (hg-timemachine-show-revision (cadr (member hg-timemachine-revision (reverse (hg-timemachine--revisions))))))

(defun hg-timemachine-show-revision (revision)
 "Show a REVISION (commit hash) of the current file."
 (when revision
  (let ((current-position (point)))
   (setq buffer-read-only nil)
   (erase-buffer)
   (let ((default-directory hg-timemachine-directory))
    (call-process "hg" nil t nil "cat" "-r" revision hg-timemachine-file))
   (setq buffer-read-only t)
   (set-buffer-modified-p nil)
   (let* ((revisions (hg-timemachine--revisions))
          (n-of-m (format "(%d/%d)" (- (length revisions) (cl-position revision revisions :test 'equal)) (length revisions))))
    (setq mode-line-format (list "Commit: " revision " -- %b -- " n-of-m " -- [%p]")))
   (setq hg-timemachine-revision revision)
   (goto-char current-position))))

(defun hg-timemachine-quit ()
 "Exit the timemachine."
 (interactive)
 (kill-buffer))

(defun hg-timemachine-kill-revision ()
 "Kill the current revisions commit hash."
 (interactive)
 (message hg-timemachine-revision)
 (kill-new hg-timemachine-revision))

(define-minor-mode hg-timemachine-mode
 "Mercurial Timemachine, feel the wings of history."
 :init-value nil
 :lighter " Timemachine"
 :keymap
 '(("p" . hg-timemachine-show-previous-revision)
   ("n" . hg-timemachine-show-next-revision)
   ("q" . hg-timemachine-quit)
   ("w" . hg-timemachine-kill-revision))
 :group 'hg-timemachine)

;;;###autoload
(defun hg-timemachine ()
 "Enable hg timemachine for file of current buffer."
 (interactive)
 (let ((hg-directory (file-name-as-directory (car (process-lines "hg" "root"))))
       (file-name (buffer-file-name))
       (timemachine-buffer (format "timemachine:%s" (buffer-name))))
  (with-current-buffer (get-buffer-create timemachine-buffer)
   (setq buffer-file-name file-name)
   (set-auto-mode)
   (hg-timemachine-mode)
   (set (make-local-variable 'hg-timemachine-directory) hg-directory)
   (set (make-local-variable 'hg-timemachine-file) file-name)
   (set (make-local-variable 'hg-timemachine-revision) nil)
   (hg-timemachine-show-current-revision)
   (switch-to-buffer timemachine-buffer))))

(provide 'hg-timemachine)

;;; hg-timemachine.el ends here
