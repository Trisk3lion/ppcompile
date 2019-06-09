;;; ppcompile.el --- Ping-pong compile projects on remote machines -*- lexical-binding: t -*-

;; Author: Guangwang Huang
;; Maintainer: Guangwang Huang
;; Version: 0.1
;; Package-Requires: ()
;; Homepage: homepage
;; Keywords: tools


;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.


;;; Commentary:

;;

;;; Code:

; depends on rsync ssh expect
; host port user passwd srcdir dstdir compile-command

(require 'compile)

(defgroup ppcompile nil
  "Run a ping pong compilation to build remotely and fix errors locally."
  :group 'tools)

(defcustom ppcompile-ssh-host nil
  "Host of remote machine, used in rsync'ing and compiling."
  ; TODO add :type
  :group 'ppcompile)

(defcustom ppcompile-ssh-port 22
  "Port of remote machine."
  :group 'ppcompile)

(defcustom ppcompile-ssh-user nil
  "User for remote compilations."
  :group 'ppcompile)

;;; XXX rsync depends on ssh
(defcustom ppcompile-rsync-args '("--exclude=*.o"
 "--exclude=*.log"
 "--exclude=*.so"
 "--exclude=unittest_main"
 "--exclude=.git*"
 "--exclude=.ccls-cache*"
 "--exclude=.cquery_cached_index*"
 "--exclude=.vscode*"
 "--exclude=.svn*"
 "--exclude=tags"
 "--exclude=cscope.*") ; TODO define a exclude variable
  "Arguments to `rsync' command to sync project to remote host."
  :group 'ppcompile)

(defcustom ppcompile-rsync-src-dir nil
  "Source directory to rsync files from."
  :group 'ppcompile)

(defcustom ppcompile-rsync-dst-dir nil
  "Destination directory to rsync files into."
  :group 'ppcompile)

(defcustom ppcompile-compile-command nil
  "Compile command to build the project on the remote machine."
  :group 'ppcompile)

(defcustom ppcompile-path-map-list nil
  "A list of cons'es tells how to map remote paths to local paths."
  :group 'ppcompile)

(defun ppcompile--rsync ()
  "Rsync files from local machine to remote one."
  (let (rsync-args command full-dst)
    (setq rsync-args "-avz") ; TODO add
    (setq full-dst (format "%s@%s:%s"
                           ppcompile-ssh-user
                           ppcompile-ssh-host
                           ppcompile-rsync-dst-dir))
    (setq command (format "rsync -e 'ssh -p %d' %s %s %s"
                          ppcompile-ssh-port
                          rsync-args
                          ppcompile-rsync-src-dir
                          full-dst)) ; TODO rsync bin path
    (shell-command-to-string command)))

(defun ppcompile--compile ()
  "Compile projects remotely and map paths in the output."
  (let* (;(compilation-filter-hook compilation-filter-hook)
         compile-command)
    (save-some-buffers)
    (setq compile-command (format "ssh -p %d %s@%s %s" ; TODO add a variable for ssh path
                                  ppcompile-ssh-port
                                  ppcompile-ssh-user
                                  ppcompile-ssh-host
                                  ppcompile-compile-command))
    ; (message "compile command: %s" compile-command)
    (add-hook 'compilation-filter-hook #'ppcompile--convert-path)
                                        ;(compilation-start compile-command t) ; password may be needed
    (compile compile-command t) ; it seems comint doesn't invoke 'compilation-filter-hook
    ))

;;; TODO check compilation-filter-hook
(defun ppcompile--convert-path ()
  "Convert paths matching SRC to DST in current buffer."
  (message "XXX convert path...")
  (with-current-buffer compilation-last-buffer
    (save-restriction
      (narrow-to-region compilation-filter-start (point))
      (goto-char (point-min))
      (dolist (map ppcompile-path-map-list)
        (while (search-forward (car map) nil t)
          (message "XXX convert %s to %s" (car map) (cdr map))
          (replace-match (cdr map)))))))

(provide 'ppcompile)

;;; ppcompile.el ends here