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
(require 'dom)
(require 'project)

(defcustom project-maven-java-home nil
  "A custom JAVA_HOME value to execute `mvn' with."
  :type 'directory
  :group 'project-maven)

(cl-defmethod project-root ((project (head maven)))
  "Find the root of the PROJECT based in Maven's pom.xml."
  (cl-second project))

(cl-defmethod project-external-roots ((project (head maven)))
  "Find the external roots of the PROJECT based in Maven's pom.xml."
  (cl-third project))

(defun project-maven-try (dir)
  "Try to find the most dominant pom.xml relative to DIR."
  (let ((dominator (locate-dominating-file dir "pom.xml")))
    (when dominator
      (let* ((above (file-name-directory (directory-file-name dominator)))
	     (dominator2 (locate-dominating-file above "pom.xml")))
	(while dominator2
	  (setq dominator dominator2
		above (file-name-directory (directory-file-name dominator))
		dominator2 (locate-dominating-file above "pom.xml"))))
      (let ((default-directory dominator)
	    (external-roots nil)
	    (xml-file (make-temp-file "project-maven-effective-pom")))
	(if project-maven-java-home ; I wish there was a better way to do
	    (let ((process-environment (cons (format "JAVA_HOME=%s" project-maven-java-home) process-environment)))
	      (call-process "mvn" nil nil t "help:effective-pom" (concat "-Doutput=" xml-file)))
	  (call-process "mvn" nil nil t "help:effective-pom" (concat "-Doutput=" xml-file)))
	(with-temp-buffer
	  (insert-file-contents-literally xml-file nil)
	  (let* ((dom (libxml-parse-xml-region (point-min) (point-max)))
		 (modules-tags (dom-by-tag dom 'modules)))
	    (dolist (modules modules-tags)
	      (dolist (module (cddr modules))
		(cl-pushnew (file-name-concat dominator
					      (cl-third module))
			    external-roots
			    :test #'string-equal)))))
	(delete-file xml-file nil)
	(list 'maven dominator external-roots)))))

;;;###autoload
(add-to-list 'project-find-functions #'project-maven-try)

(provide 'project-maven)
;;; project-maven.el ends here
