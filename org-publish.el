(require 'org)

(setq org-publish-project-alist
      '(
        ("org-sicp"
         :base-directory "."
         :base-extension "org"

         :publishing-directory "./_org"
         :recursive t
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :html-extension "html"
         :with-toc nil
         :body-only t)
        ("org-sicp-code"
         :base-directory "."
         :base-extension "scm\\|scheme"
         :publishing-directory "./code"
         :recursive nil
         :publishing-function org-publish-attachment)
        ("sicp" :components ("org-sicp" "org-sicp-code"))))

(org-publish "sicp" 't)
