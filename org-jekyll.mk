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
BABEL_LANGUAGES ?= emacs-lisp

JEKYLL_CONFIG = $(BUILD_DIR)/_config.yml
JEKYLL_OPTS += -s $(BUILD_DIR)

ORG_BUILD_DIR = $(BUILD_DIR)/_org
ORG_ASSET_DIR = $(BUILD_DIR)/org

targets = $(BUILD_DIR) $(SITE_DIR)
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
org_files := $(wildcard $(ORG_DIR)/*.org)
tangle_org_files := $(addprefix $(ORG_ASSET_DIR)/,$(notdir $(shell grep -l ':tangle ' $(org_files))))
org_asset_files := $(addprefix $(ORG_ASSET_DIR)/,$(notdir $(org_files)))
html_files := $(patsubst %.org,$(ORG_BUILD_DIR)/%.html,$(notdir $(org_files)))
load_languages := $(shell echo "$(BABEL_LANGUAGES)" | sed -r 's/(\S+)/\(\1 . ''t\)/g')

V ?= 0
stderr_verbose_0	= 2>/dev/null
stderr_verbose		= $(stderr_verbose_$(V))
org_verbose_0		= @echo " ORG  " $<;
org_verbose		= $(org_verbose_$(V))
tangle_verbose_0	= @echo " CODE " $(1);
tangle_verbose		= $(tangle_verbose_$(V))
jekyll_verbose_0	= @echo " BUILD jekyll";
jekyll_verbose		= $(jekyll_verbose_$(V))
config_verbose_0	= @echo " CFG  " $@;
config_verbose		= $(config_verbose_$(V))
serve_verbose_0		= @echo " SERVE jekyll";
serve_verbose		= $(jekyll_verbose_$(V))

default: all

all: build

clean:
	rm -rf $(targets)

jekyll-config:
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
 \n\
defaults: \n\
  - scope: \n\
      path: \"\"\n\
      type: \"org\" \n\
    values: \n\
      layout: \"org\" \n\
" > $(JEKYLL_CONFIG)

build: assets org jekyll-config
	$(jekyll_verbose) jekyll build $(JEKYLL_OPTS)

serve: assets org jekyll-config
	$(serve_verbose) jekyll serve $(JEKYLL_OPTS)

org: $(org_asset_files) $(html_files)

$(ORG_BUILD_DIR)/%.html: $(ORG_ASSET_DIR)/%.html
	@mkdir -p $(@D)
	@mv $< $@

$(ORG_ASSET_DIR)/%.org: $(ORG_DIR)/%.org
	@mkdir -p $(@D)
	@cp $< $@

define tangle
	$(tangle_verbose) emacs --batch -u ${USER} \
		--eval " \
(progn \
  (require 'org) \
  (org-babel-do-load-languages \
   'org-babel-load-languages \
    '($(load_languages))) \
  (org-babel-tangle-file \"$(1)\"))" $(stderr_verbose)
endef

$(ORG_ASSET_DIR)/%.html: $(ORG_ASSET_DIR)/%.org
	$(if $(shell grep ':tangle ' $<),$(call tangle,$<))
	$(org_verbose) emacs --batch -u ${USER} --eval " \
(progn \
  (require 'org) \
  (require 'ox) \
  \
  (org-babel-do-load-languages \
   'org-babel-load-languages \
    '($(load_languages))) \
  (setq org-confirm-babel-evaluate nil) \
  \
  (defun org-jekyll.mk/inject-frontmatter (string backend info) \
    (when (and (org-export-derived-backend-p backend 'html) \
               (not (eq 0 (string-match \"---\" string)))) \
      (let ((title (org-export-data (plist-get info :title) info)) \
            (author (org-export-data (plist-get info :author) info))) \
        (replace-regexp-in-string (rx buffer-start) \
                                  (concat \"---\\n\" \
                                          (format \"title: \\\"%s\\\"\\n\" title) \
                                          (format \"author: \\\"%s\\\"\\n\" author) \
                                          \"---\\n\") \
                                  string)))) \
  (add-to-list 'org-export-filter-final-output-functions \
               'org-jekyll.mk/inject-frontmatter) \
  \
  (setq org-publish-project-alist \
        '( \
          (\"org-jekyll\" \
           :base-directory \".\" \
           :base-extension \"org\" \
  \
           :publishing-directory \"$(abspath $(@D))\" \
           :recursive t \
           :publishing-function org-html-publish-to-html \
           :headline-levels 4 \
           :section-numbers nil \
           :html-extension \"html\" \
           :htmlized-source t \
           :with-toc nil \
           :body-only t \
           :babel-evaluate t) \
          (\"jekyll\" :components (\"org-jekyll\")))) \
  \
  (find-file \"$<\") \
  (org-publish-current-file 't)) \
" $(stderr_verbose)

.PHONY: assets

assets_verbose_0 = @echo Extracting assets to $(BUILD_DIR);
assets_verbose   = $(assets_verbose_$(V))

assets:
	@mkdir -p $(BUILD_DIR)
	$(assets_verbose) echo '' \
		'begin-base64 664 -\n'\
		'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\n'\
		'====\n'\
	 | sed 's/^ //' | uudecode | tar zx -C $(BUILD_DIR)
