## This is an example Makefile.

PERL_VERSION = latest
PERL_PATH = $(abspath local/perlbrew/perls/perl-$(PERL_VERSION)/bin)

Makefile-setupenv: Makefile.setupenv
	$(MAKE) --makefile Makefile.setupenv setupenv-update \
	    SETUPENV_MIN_REVISION=20120317

Makefile.setupenv:
	wget -O $@ https://raw.github.com/wakaba/perl-setupenv/master/Makefile.setupenv


local-perl perl-version perl-exec \
local-submodules config/perl/libs.txt \
carton-install carton-update carton-install-module \
remotedev-test remotedev-reset remotedev-reset-setupenv \
generatepm: %: Makefile-setupenv
	$(MAKE) --makefile Makefile.setupenv $@

PROVE = prove

test: local-submodules carton-install config/perl/libs.txt
	PATH=$(PERL_PATH):$(PATH) PERL5LIB=$(shell cat config/perl/libs.txt) \
	    $(PROVE) t/*.t

GENERATEPM = local/generatepm/bin/generate-pm-package

dist: generatepm
	$(GENERATEPM) config/dist/json-functions-xs.pi dist/
