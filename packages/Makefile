-include ../Make.user

.PHONY: all .locks

all: gcc/generated/env nvhpc/generated/env

# Make sure spack.lock files are never removed as intermediate files...
.locks: gcc/spack.lock nvhpc/spack.lock tools/spack.lock

gcc/update-config: | store
	$(SPACK_ENV) config add config:install_tree:root:$(STORE) && \
	$(SPACK_ENV) compiler find "$$($(SPACK) -e ../compilers/2-gcc find --format '{prefix}' gcc@11)" && \
	touch $@

nvhpc/update-config: | store
	$(SPACK_ENV) config add config:install_tree:root:$(STORE) && \
	$(SPACK_ENV) compiler find \
		"$$($(SPACK) -e ../compilers/2-gcc find --format '{prefix}' gcc@11)" \
		"$$(find "$$($(SPACK) -e ../compilers/3-llvm find --format '{prefix}' nvhpc)" -iname compilers -type d | head -n1 )/bin" && \
	touch $@

tools/update-config: | store
	$(SPACK_ENV) config add config:install_tree:root:$(STORE) && \
	$(SPACK_ENV) compiler find "$$($(SPACK) -e ../compilers/2-gcc find --format '{prefix}' gcc@11)" && \
	touch $@

-include ../Make.inc

ifeq (,$(filter clean,$(MAKECMDGOALS)))
include gcc/Makefile
include nvhpc/Makefile
include tools/Makefile
endif
