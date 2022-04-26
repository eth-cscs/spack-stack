SPACK := $(SPACK) -c config:install_tree:root:$(STORE)

.PHONY: all install

all: install

register-compilers:
	$(SPACK) -e . compiler find $$($(SPACK) -e ../gcc find --format '{prefix}' gcc@11) && \
		touch $@

spack.lock: spack.yaml register-compilers
	$(SPACK) -e . concretize -f

install.Makefile: spack.lock
	$(SPACK) -e . env generate-makefile > $@

install: install.Makefile
	$(MAKE) -f install.Makefile

clean:
	$(MAKE) -f install.Makefile clean
	rm -rf -- register-compilers spack.lock .spack-env install.Makefile