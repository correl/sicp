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
         :section-numbers nil
         :html-extension "html"
         :htmlized-source t
         :with-toc nil
         :body-only t)
        ("sicp" :components ("org-sicp"))))

(org-publish "sicp" 't)
