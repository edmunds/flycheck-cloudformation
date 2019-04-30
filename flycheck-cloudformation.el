;;; flycheck-cloudformation.el --- summary -*- lexical-binding: t -*-

;; Author: Andrew Christianson
;; Maintainer: Andrew Christianson
;; Version: 0.1.0
;; Package-Requires: (flycheck)
;; Homepage:
;; Keywords: cloudformation AWS

;; This file is not part of GNU Emacs

;;; Commentary:

;; commentary

;;; Code:

(defun flycheck-cloudformation-avail-p ()
  "Check if cfn-init is intalled"
  (if (executable-find "cfn-lint") t nil))

;; infrastructure/s3-buckets.yaml:31:8:31:9:E0000:did not find expected key
(flycheck-define-checker cloudformation
  "This check runs the cloudformation linter against a template"
  :command ("cfn-lint" "-f" "parseable" source-inplace)
  :error-patterns
  ((error line-start
          (file-name) ":" line ":" column ":"
          (one-or-more (not (any ":"))) ":"
          (one-or-more (not (any ":"))) ":"
          (or "E" "F") (id (one-or-more (not (any ":")))) ":"
          (message)
          line-end)
   (warning line-start
            (file-name) ":" line ":" column ":"
            (one-or-more (not (any ":"))) ":"
            (one-or-more (not (any ":"))) ":"
            (or "W" "R") (id (one-or-more (not (any ":")))) ":"
            (message)
            line-end)
   (info line-start
         (file-name) ":" line ":" column ":"
         (one-or-more (not (any ":"))) ":"
         (one-or-more (not (any ":"))) ":"
         (or "C" "I") (id (one-or-more (not (any ":")))) ":"
         (message)
         line-end))
  :enabled (lambda () (flycheck-cloudformation-avail-p))
  :predicate (lambda ()
               (let ((buf (buffer-substring 1 (point-max))))
                 (cond
                  ((and (eq major-mode 'json-mode) (string-match "\"Resources\"[ ]+.:" buf)))
                  ((and (eq major-mode 'yaml-mode) (string-match "^Resources:" buf)))
                  )))
  :modes (json-mode yaml-mode))

(defun flycheck-cloudformation-setup ()
  "Setup flycheck for cloudformation"
  (interactive)
  (add-to-list 'flycheck-checkers 'cloudformation nil 'eq))

(provide 'flycheck-cloudformation)

;;; flycheck-cloudformation.el ends here
