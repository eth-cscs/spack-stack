SPACK := $(SPACK) -c config:install_tree:root:$(STORE)

.PHONY: all install

all: install

# TODO: improve spack compiler find/add, especially for nvhpc.
register-compilers:
	$(SPACK) -e . compiler find \
		"$$($(SPACK) -e ../gcc find --format '{prefix}' gcc@11)" \
		"$$(find "$$($(SPACK) -e ../nvhpc find --format '{prefix}' nvhpc)" -iname compilers -type d | head -n1 )/bin" && \
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