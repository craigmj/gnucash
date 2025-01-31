;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  html-fonts.scm
;;  html stuff for fonts/css
;;
;;  Copyright (c) 2001 Linux Developers Group, Inc. 
;;  Copyright (c) Phil Longstaff <plongstaff@rogers.com>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of
;; the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, contact:
;;
;; Free Software Foundation           Voice:  +1-617-542-5942
;; 51 Franklin Street, Fifth Floor    Fax:    +1-617-542-2652
;; Boston, MA  02110-1301,  USA       gnu@gnu.org
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(use-modules (gnucash gettext))

(define (string-strip s1 s2)
  (let ((idx (string-contains-ci s1 s2)))
    (string-append
     (string-take s1 idx)
     (string-drop s1 (+ idx (string-length s2))))))

;; Converts a font name to css style information
(define (font-name-to-style-info font-name)
  (let* ((font-style "")
         (font-weight "")
         (idx (string-index-right font-name #\space))
         (font-size (substring font-name (1+ idx) (string-length font-name)))
         (font-name (string-take font-name idx)))

    (when (string-contains-ci font-name " bold")
      (set! font-weight "font-weight: bold; ")
      (set! font-name (string-strip font-name " bold")))

    (cond
     ((string-contains-ci font-name " italic")
      (set! font-style "font-style: italic; ")
      (set! font-name (string-strip font-name " italic")))

     ((string-contains-ci font-name " oblique")
      (set! font-style "font-style: oblique; ")
      (set! font-name (string-strip font-name " oblique"))))

    (string-append "font-family: " font-name ", Sans-Serif; "
                   "font-size: " font-size "pt; "
                   font-style font-weight)))

;; Registers font options
(define (register-font-options options)
    (let*
        (
            (opt-register 
                (lambda (opt) (gnc:register-option options opt)))
            (font-family (gnc-get-default-report-font-family))
        )
        (opt-register
            (gnc:make-font-option
                (N_ "Fonts")
                (N_ "Title") "a" (N_ "Font info for the report title.")
                (string-append font-family " Bold 15")))
        (opt-register
            (gnc:make-font-option
                (N_ "Fonts")
                (N_ "Account link") "b" (N_ "Font info for account name.")
                (string-append font-family " Italic 10")))
        (opt-register
            (gnc:make-font-option
                (N_ "Fonts")
                (N_ "Number cell") "c" (N_ "Font info for regular number cells.")
                (string-append font-family " 10")))
        (opt-register
            (gnc:make-simple-boolean-option
                (N_ "Fonts")
                (N_ "Negative Values in Red") "d" (N_ "Display negative values in red.")
                #t))
        (opt-register
            (gnc:make-font-option
                (N_ "Fonts")
                (N_ "Number header") "e" (N_ "Font info for number headers.")
                (string-append font-family " 10")))
        (opt-register
            (gnc:make-font-option
                (N_ "Fonts")
                (N_ "Text cell") "f" (N_ "Font info for regular text cells.")
                (string-append font-family " 10")))
        (opt-register
            (gnc:make-font-option
                (N_ "Fonts")
                (N_ "Total number cell") "g" (N_ "Font info for number cells containing a total.")
                (string-append font-family " Bold 12")))
        (opt-register
            (gnc:make-font-option
                (N_ "Fonts")
                (N_ "Total label cell") "h" (N_ "Font info for cells containing total labels.")
                (string-append font-family " Bold 12")))
        (opt-register
            (gnc:make-font-option
                (N_ "Fonts")
                (N_ "Centered label cell") "i" (N_ "Font info for centered label cells.")
                (string-append font-family " Bold 12")))
    )
)

;; Adds CSS style information to an html document
(define (add-css-information-to-doc options ssdoc doc)
    (let*
        ((opt-val 
            (lambda (section name)
                (gnc:option-value (gnc:lookup-option options section name))))
        (negative-red? (opt-val "Fonts" "Negative Values in Red"))
        (alternate-row-color
         (gnc:color-option->html
          (gnc:lookup-option options
                     "Colors"
                     "Alternate Table Cell Color")))
        (title-font-info (font-name-to-style-info (opt-val "Fonts" "Title")))
        (account-link-font-info (font-name-to-style-info (opt-val "Fonts" "Account link")))
        (number-cell-font-info (font-name-to-style-info (opt-val "Fonts" "Number cell")))
        (number-header-font-info (font-name-to-style-info (opt-val "Fonts" "Number header")))
        (text-cell-font-info (font-name-to-style-info (opt-val "Fonts" "Text cell")))
        (total-number-cell-font-info (font-name-to-style-info (opt-val "Fonts" "Total number cell")))
        (total-label-cell-font-info (font-name-to-style-info (opt-val "Fonts" "Total label cell")))
        (centered-label-cell-font-info (font-name-to-style-info (opt-val "Fonts" "Centered label cell"))))

        (gnc:html-document-set-style-text!
            ssdoc
            (string-append
                "h3 { " title-font-info " }\n"
                "a { " account-link-font-info " }\n"
                "body, p, table, tr, td { vertical-align: top; " text-cell-font-info " }\n"
                "tr.alternate-row { background: " alternate-row-color " }\n"
                "tr { page-break-inside: avoid !important;}\n"
                "th.column-heading-left { text-align: left; " number-header-font-info " }\n"
                "th.column-heading-center { text-align: center; " number-header-font-info " }\n"
                "th.column-heading-right { text-align: right; " number-header-font-info " }\n"
                "td.neg { " (if negative-red? "color: red; " "") " }\n"
                "td.number-cell, td.total-number-cell { text-align: right; white-space: nowrap; }\n"
                "td.date-cell { white-space: nowrap; }\n"
                "td.anchor-cell { white-space: nowrap; " text-cell-font-info " }\n"
                "td.number-cell { " number-cell-font-info " }\n"
                "td.number-header { text-align: right; " number-header-font-info " }\n"
                "td.text-cell { " text-cell-font-info " }\n"
                "td.total-number-cell { " total-number-cell-font-info " }\n"
                "td.total-label-cell { " total-label-cell-font-info " }\n"
                "td.centered-label-cell { text-align: center; " centered-label-cell-font-info " }\n"
                (or (gnc:html-document-style-text doc) "")
            )
        )
    )
)
