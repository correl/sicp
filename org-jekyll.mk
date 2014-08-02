.PHONY: default all clean jekyll serve jekyll-config

SITE_NAME ?= My Documents
SITE_TITLE ?= Emacs Org-Mode Documents
SITE_DESCRIPTION ?=
SITE_BASEURL ?=
SITE_URL ?=
SITE_AUTHOR ?=
SITE_AUTHOR_EMAIL ?=
SITE_TWITTER ?=
SITE_GITHUB ?=

ORG_DIR ?= .
BUILD_DIR ?= _build
SITE_DIR ?= _site
OUTPUT_DIR = $(BUILD_DIR)/_org
CODE_DIR = $(BUILD_DIR)/_src

JEKYLL_CONFIG = $(BUILD_DIR)/_config.yml
JEKYLL_OPTS += -s $(BUILD_DIR)

targets = $(BUILD_DIR) $(SITE_DIR)
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
org_files := $(patsubst %.org,$(OUTPUT_DIR)/%.html,$(notdir $(wildcard $(ORG_DIR)/*.org)))
tangle_org_files := $(shell grep -il '+BEGIN_SRC .* :tangle yes' $(ORG_DIR)/*.org)
tangle_output_files := $(patsubst %.org,$(CODE_DIR)/%.src.txt,$(notdir $(tangle_org_files)))
tangle_tmp := $(shell tempfile -s .org)

V ?= 0
org_verbose_0		= @echo " ORG  " $(?F);
org_verbose		= $(org_verbose_$(V))
tangle_verbose_0	= @echo " CODE " $(?F);
tangle_verbose		= $(tangle_verbose_$(V))
jekyll_verbose_0	= @echo " BUILD jekyll";
jekyll_verbose		= $(jekyll_verbose_$(V))
config_verbose_0	= @echo " CFG  " $@;
config_verbose		= $(config_verbose_$(V))
serve_verbose_0		= @echo " SERVE jekyll";
serve_verbose		= $(jekyll_verbose_$(V))

default: all

all: jekyll

clean:
	rm -rf $(targets)

$(JEKYLL_CONFIG):
	$(config_verbose) echo "\
# Site settings \n\
name: \"$(SITE_NAME)\" \n\
title: \"$(SITE_TITLE)\" \n\
email: \"$(SITE_AUTHOR_EMAIL)\" \n\
description: \"$(SITE_DESCRIPTION)\" \n\
baseurl: \"$(SITE_BASEURL)\" \n\
url: \"$(SITE_URL)\" \n\
twitter: \"$(SITE_TWITTER)\" \n\
github: \"$(SITE_GITHUB)\" \n\
 \n\
# Build settings \n\
markdown: kramdown \n\
permalinks: pretty \n\
 \n\
collections: \n\
  org: \n\
    output: true \n\
  src: \n\
    output: true \n\
 \n\
defaults: \n\
  - scope: \n\
      path: \"\" \n\
      type: \"org\" \n\
    values: \n\
      layout: \"page\" \n\
      author: \"$(SITE_AUTHOR)\" \n\
" > $@

jekyll: assets org-html org-code $(JEKYLL_CONFIG)
	$(jekyll_verbose) jekyll build $(JEKYLL_OPTS)

serve: assets org-html org-code $(JEKYLL_CONFIG)
	$(serve_verbose) jekyll serve $(JEKYLL_OPTS)

$(BUILD_DIR):
	mkdir -p $@

$(OUTPUT_DIR):
	mkdir -p $@

$(CODE_DIR):
	mkdir -p $@

$(OUTPUT_DIR)/%.html: $(ORG_DIR)/%.org
	$(org_verbose) emacs --batch -u ${USER} --eval " \
(progn \
  (require 'org) \
  \
  (setq org-publish-project-alist \
        '( \
          (\"org-jekyll\" \
           :base-directory \".\" \
           :base-extension \"org\" \
  \
           :publishing-directory \"$(abspath $(OUTPUT_DIR))\" \
           :recursive t \
           :publishing-function org-html-publish-to-html \
           :headline-levels 4 \
           :section-numbers nil \
           :html-extension \"html\" \
           :htmlized-source t \
           :with-toc nil \
           :body-only t) \
          (\"jekyll\" :components (\"org-jekyll\")))) \
  \
  (find-file \"$<\") \
  (org-publish-current-file 't)) \
" 2>/dev/null

$(CODE_DIR)/%.src.txt: $(ORG_DIR)/%.org
	@sed "s/:tangle yes/:tangle $(subst /,\/,$(abspath $@))/g" "$<" > $(tangle_tmp)
	$(tangle_verbose) emacs	--batch -u ${USER} \
		--eval "(require 'org)" \
		--eval "(org-babel-tangle-file \"$(tangle_tmp)\")" 2>/dev/null ;
	@rm $(tangle_tmp)

org-html: $(OUTPUT_DIR) $(org_files)
org-code: $(CODE_DIR) $(tangle_output_files)

.PHONY: assets

assets_verbose_0 = @echo Extracting assets to $(BUILD_DIR);
assets_verbose   = $(assets_verbose_$(V))

assets: $(BUILD_DIR)
	$(assets_verbose) echo '' \
		'begin-base64 664 -\n'\
		'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\n'\
		'====\n'\
	 | sed 's/^ //' | uudecode | tar zx -C $(BUILD_DIR)
