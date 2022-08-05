;;; project-maven.el --- project.el support for maven-based projects -*- lexical-binding: t; -*-

;; Copyright (C) 2022 Jani Juhani Sinervo

;; Author: Jani Juhani Sinervo <jani@sinervo.fi>
;; Created: 05 Aug 2022
;; Version: 1.0
;; Package-Requires: ((project "0.8") (cl-lib "1.0"))
;; Keywords: project, java

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides a project.el backend for dealing with Maven-based projects.

;;; Code:
(require 'cl-lib)
(require 'project)

(cl-defmethod project-root ((project (head maven)))
  "Find the root of the PROJECT based in Maven's pom.xml."
  (cadr project))

(defun project-maven-try (dir)
  "Try to find the first dominating pom.xml relative to DIR."
  (let ((project-dir (locate-dominating-file dir "pom.xml")))
    (when project-dir
      (list 'maven project-dir))))

;;;###autoload
(add-to-list 'project-find-functions #'project-maven-try)

(provide 'project-maven)
;;; project-maven.el ends here
