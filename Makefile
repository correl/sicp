.PHONY: default all org org-code jekyll serve

default: all

all: org org-code jekyll

org:
	emacs --batch -u ${USER} -l org-publish.el

org-code: *.org
	for org in $?; do \
		emacs	--batch -u ${USER} \
			--eval "(require 'org)" \
			--eval "(org-babel-tangle-file \"$$org\")" ; \
	done

jekyll:
	jekyll build

serve:
	jekyll serve
