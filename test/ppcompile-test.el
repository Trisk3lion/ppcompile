;;; ppcompile-test.el --- Tests for ppcompile

;; Copyright (C) 2015  Free Software Foundation, Inc.

;; Author: Guangwang Huang

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;

;;; Code:

(require 'ert)
(require 'ppcompile)

(ert-deftest test-authsource ()
  (let ((auth-sources '("./test/authinfo.txt"))
        (ppcompile-ssh-host "example.com")
        (ppcompile-ssh-port 1234)
        (ppcompile-ssh-user "foobar"))
    (should
     (string= "foo:BAR123!" (ppcompile-get-ssh-password)))))
