# Git variables

GIT_REPOSITORY_NAME := $(shell basename `git rev-parse --show-toplevel`)
GIT_VERSION := $(shell git describe --always --tags --long --dirty | sed -e 's/\-0//' -e 's/\-g.......//')

# -----------------------------------------------------------------------------
# The first "make" target runs as default.
# -----------------------------------------------------------------------------

.PHONY: default
default: help

# -----------------------------------------------------------------------------
# Docker-based builds
# -----------------------------------------------------------------------------

.PHONY: build
build: main.json

# -----------------------------------------------------------------------------
# Build files
# -----------------------------------------------------------------------------

main.json: bicep/main.bicep
	bicep build bicep/main.bicep \
		--outfile arm-json/main.json

# -----------------------------------------------------------------------------
# Clean up targets
# -----------------------------------------------------------------------------

.PHONY: clean-main
clean-main:
	rm arm-json/main.json

.PHONY: clean
clean: clean-main

# -----------------------------------------------------------------------------
# Help
# -----------------------------------------------------------------------------

.PHONY: help
help:
	@echo "List of make targets:"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs
