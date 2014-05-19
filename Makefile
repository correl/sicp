.PHONY: org jekyll

default: org jekyll

org:
	emacs --batch -u ${USER} -l org-publish.el

jekyll:
	jekyll build

serve:
	jekyll serve
