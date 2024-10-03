;;; sensible-modeline.el --- A sensible mode-line configuration for Emacs -*- lexical-binding: t; -*-

;; Copyright (C) 2019-2021  Eder Elorriaga

;; Author: Eder Elorriaga <gexplorer8@gmail.com>
;; URL: https://github.com/gexplorer/sensible-modeline
;; Keywords: mode-line faces
;; Version: 1.4
;; Package-Requires: ((emacs "26.1"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; A sensible mode-line configuration for Emacs.
;; To enable, put this code in your init file:
;; (require 'sensible-modeline)
;; (sensible-modeline-mode 1)
;; or
;; (use-package sensible-modeline
;;   :ensure t
;;   :hook (after-init . sensible-modeline-mode))
;;

;;; Code:

(require 'sensible-modeline-segments)

(defgroup sensible-modeline nil
  "A sensible mode line."
  :prefix "sensible-modeline-"
  :group 'mode-line)

(defvar sensible-modeline--default-mode-line mode-line-format
  "The former value of `mode-line-format'.")

;;
;; Options
;;

(defcustom sensible-modeline-segments
  '((
		 sensible-modeline-segment-status-indicator
     sensible-modeline-segment-buffer-name
     sensible-modeline-segment-vc
     ;; sensible-modeline-segment-position
		 )
    (
		 ;; sensible-modeline-segment-minor-modes
     ;; sensible-modeline-segment-input-method
     ;; sensible-modeline-segment-eol
     ;; sensible-modeline-segment-encoding
     ;; sensible-modeline-segment-misc-info
     ;; sensible-modeline-segment-process
     ;; sensible-modeline-segment-major-mode
		 ))
  "Sensible modeline segments."
  :type '(list (repeat :tag "Left aligned" function)
               (repeat :tag "Right aligned" function))
  :package-version '(sensible-modeline . "1.2"))

(defcustom sensible-modeline-padding '(0.20 . 0.25)
  "Default vertical space adjustment (in fraction of character height)"
  :type '(cons (float :tag "Top spacing")
               (float :tag "Bottom spacing"))
  :group 'sensible-modeline)

;;
;; Faces
;;

(defun sensible-modeline--invert-face (face &optional base)
  "Return a spec for FACE with foreground and background swapped.
If provided BASE is used to supply missing attributes."

  (let* ((base (or base 'default))
				 (fg (or (face-foreground face) (face-foreground base)))
				 (bg (or (face-background face) (face-background base))))
		`(:foreground ,bg :background ,fg)))

(defface sensible-modeline-space
  '((t))
  "Face for space used to alight the right segments in the mode-line.")

(defface sensible-modeline-unimportant
  '((t (:inherit (shadow))))
  "Face for less important mode-line elements.")

(defface sensible-modeline-status-modified
  `((t (:inherit 'isearch :foreground ,(face-background 'default))))
  "Face for the 'modified' indicator symbol in the mode-line.")

(defface sensible-modeline-status-info
  `((t ,(sensible-modeline--invert-face 'font-lock-string-face)))
  "Face for generic status indicators in the mode-line.")

(defface sensible-modeline-status-success
  '((t (:inherit (success))))
  "Face used for success status indicators in the mode-line.")

(defface sensible-modeline-status-warning
  '((t (:inherit (warning))))
  "Face for warning status indicators in the mode-line.")

(defface sensible-modeline-status-error
  '((t (:inherit (isearch-fail))))
  "Face for error status indicators in the mode-line.")

;;
;; Helpers
;;

(defun sensible-modeline--format (left-segments right-segments)
  "Return a string of `window-width' length containing LEFT-SEGMENTS and RIGHT-SEGMENTS, aligned respectively."
  (let* ((left (sensible-modeline--format-segments left-segments))
         (right (sensible-modeline--format-segments right-segments))
				 (reserve (length right)))
    (concat
     left
     (propertize " "
                 'display `((space :align-to (- right ,reserve)))
                 'face '(:inherit sensible-modeline-space))
     right)))

(defun sensible-modeline--format-segments (segments)
  "Return a string from a list of SEGMENTS."
  (format-mode-line (mapcar
                     (lambda (segment)
                       `(:eval (,segment)))
                     segments)))

(defvar sensible-modeline--mode-line
  '((:eval
     (sensible-modeline--format
      (car sensible-modeline-segments)
      (cadr sensible-modeline-segments)))))

;;;###autoload
(define-minor-mode sensible-modeline-mode
  "Minor mode to get a sensible mode line.

When called interactively, toggle
`sensible-modeline-mode'.  With prefix ARG, enable
`sensible-modeline--mode' if ARG is positive, otherwise
disable it.

When called from Lisp, enable `sensible-modeline-mode' if ARG is omitted,
nil or positive.  If ARG is `toggle', toggle `sensible-modeline-mode'.
Otherwise behave as if called interactively."
  :init-value nil
  :keymap nil
  :lighter ""
  :group 'sensible-modeline
  :global t
  (if sensible-modeline-mode
      ;; Set the new mode-line-format
      (setq-default mode-line-format '(:eval sensible-modeline--mode-line))
    ;; Restore the original mode-line format
    (setq-default mode-line-format sensible-modeline--default-mode-line)))

(provide 'sensible-modeline)
;;; sensible-modeline.el ends here
