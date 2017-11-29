(in-package :cl-user)
(defpackage :cl-yes
  (:use :cl)
  (:import-from :cffi)
  (:export :yes))
(in-package :cl-yes)

(defun prepare (string &optional (length (* 1024 16)) (alignment 4))
  (setf string (format nil "~A~%" string))
  (multiple-value-list
   (cffi:with-foreign-string ((s size) string)
     (cffi:foreign-string-alloc
      (if (> (/ length 2) size)
          (with-output-to-string (o)
            (loop repeat (* (floor length (* size alignment))
                            (* size alignment))
               do (princ string o)))
          string)))))

(defun yes (&optional (s "y"))
  (loop
     with (buf len) = (prepare s)
     do #+sbcl (sb-posix:write
                #.(sb-sys:fd-stream-fd sb-sys:*stdout*) buf len)
       #-sbcl (error "not supported")))
