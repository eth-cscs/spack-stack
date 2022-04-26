.PHONY: all install

all: install

update-config:
	$(SPACK) -e . config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e . compiler find $$($(SPACK) $(SPACK_FLAGS) -e ../gcc find --format '{prefix}' gcc@11) && \
		touch $@

spack.lock: spack.yaml update-config
	$(SPACK) -e . concretize -f

install.Makefile: spack.lock
	$(SPACK) -e . env generate-makefile > $@

install: install.Makefile
	$(MAKE) -f install.Makefile

clean:
	if [ -f install.Makefile ]; then $(MAKE) -f install.Makefile clean; fi
	rm -rf -- update-config spack.lock .spack-env install.Makefile
