SPACK := $(SPACK) -c config:install_tree:root:$(STORE)

.PHONY: all install

all: install

spack.lock: spack.yaml
	$(SPACK) -e . concretize -f

install.Makefile: spack.lock
	$(SPACK) -e . env generate-makefile > $@

install: install.Makefile
	$(MAKE) -f install.Makefile

clean:
	$(MAKE) -f install.Makefile clean
	rm -rf -- spack.lock .spack-env install.Makefile