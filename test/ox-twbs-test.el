;;; ox-twbs-test.el --- Tests for ox-twbs -*- lexical-binding: t; -*-

(require 'ert)
(require 'org)
(require 'ox)
(require 'ox-twbs)

(defmacro org-twbs-test-with-export (input &rest body)
  "Evaluate BODY with OUTPUT bound to the export of INPUT.
INPUT is an Org string.  Within BODY the variable `output' is bound to
HTML produced by `org-export-string-as' using the twbs back-end."
  (declare (indent 1))
  `(let ((org-export-show-temporary-export-buffer nil)
         (org-export-use-babel nil)
         (org-export-with-toc nil)
         (org-html-html5-fancy nil))
     (let ((output (org-export-string-as ,input 'twbs t)))
       ,@body)))

(ert-deftest org-twbs-export-includes-following-headlines ()
  "Headlines after the first should appear in the exported HTML."
  (org-twbs-test-with-export "* Parent\n** Child\n*** Grandchild\n"
    (let ((headline-regexp
           (lambda (id text)
             (format
              "<h[0-9]+ id=\\\"%s\\\">\\(?:<span[^>]*>[^<]*</span> \\)?%s</h[0-9]+>"
              id text))))
      (should (string-match-p (funcall headline-regexp "sec-1" "Parent") output))
      (should (string-match-p (funcall headline-regexp "sec-1-1" "Child") output))
      (should (string-match-p (funcall headline-regexp "sec-1-1-1" "Grandchild") output)))))

(ert-deftest org-twbs-export-wraps-headlines-without-section ()
  "Headlines that lack a section node still get outline containers."
  (org-twbs-test-with-export "* Parent\n** Child\n*** Grandchild\n"
    (let* ((text-pos (string-match "<div class=\\\"outline-text-[0-9]+\\\" id=\\\"text-1-1\\\">" output))
           (grandchild-pos (string-match "<h[0-9]+ id=\\\"sec-1-1-1\\\">" output)))
      (should text-pos)
      (should grandchild-pos)
      (should (< text-pos grandchild-pos)))))

(ert-deftest org-twbs-export-uses-custom-ids-for-outline-text ()
  "Custom IDs should drive outline text container identifiers."
  (org-twbs-test-with-export "* Parent\n:PROPERTIES:\n:CUSTOM_ID: parent-id\n:END:\n** Child\n"
    (should (string-match "<div class=\\\"outline-text-1\\\" id=\\\"text-parent-id\\\">" output))))

(provide 'ox-twbs-test)

;;; ox-twbs-test.el ends here
