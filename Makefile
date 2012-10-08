all:

## ------ Environment ------

WGET = wget

Makefile-setupenv: Makefile.setupenv
	$(MAKE) --makefile Makefile.setupenv setupenv-update \
	    SETUPENV_MIN_REVISION=20121008

Makefile.setupenv:
	$(WGET) -O $@ https://raw.github.com/wakaba/perl-setupenv/master/Makefile.setupenv

pmbp-update pmbp-install generatepm: %: Makefile-setupenv
	$(MAKE) --makefile Makefile.setupenv $@

deps: pmbp-install

## ------ Tests ------

PROVE = ./prove

test: safetest

test-deps: deps

safetest: test-deps safetest-main

safetest-main:
	$(PROVE) t/*.t

## ------ Packaging ------

GENERATEPM = local/generatepm/bin/generate-pm-package

dist: generatepm
	$(GENERATEPM) config/dist/json-functions-xs.pi dist/ --generate-json

dist-wakaba-packages: local/wakaba-packages dist
	cp dist/*.json local/wakaba-packages/data/perl/
	cp dist/*.tar.gz local/wakaba-packages/perl/
	cd local/wakaba-packages && $(MAKE) all

local/wakaba-packages: always
	git clone "git@github.com:wakaba/packages.git" $@ || (cd $@ && git pull)
	cd $@ && git submodule update --init

always:

## License: Public Domain.
