-include ../Make.user

MAKEFLAGS += --output-sync=recurse

.PHONY: all .locks

all: gcc/generated/env nvhpc/generated/env tools/generated/env

# Make sure spack.lock files are never removed as intermediate files...
.locks: gcc/spack.lock nvhpc/spack.lock tools/spack.lock

gcc/config.yaml nvhpc/config.yaml tools/config.yaml: | store
	$(SPACK) config --scope=user add config:install_tree:root:$(STORE)

gcc/compilers.yaml:
	$(SPACK) compiler find --scope=user \
		"$$($(SPACK) -e ../compilers/2-gcc find --format '{prefix}' gcc@11)"

nvhpc/compilers.yaml:
	$(SPACK) compiler find --scope=user \
		"$$($(SPACK) -e ../compilers/2-gcc find --format '{prefix}' gcc@11)" \
		"$$(dirname $$(find "$$($(SPACK) -e ../compilers/3-llvm find --format '{prefix}' nvhpc)" -name nvfortran -type f) | head -n1 )"

tools/compilers.yaml:
	$(SPACK) compiler find --scope=user \
		"$$($(SPACK) -e ../compilers/2-gcc find --format '{prefix}' gcc@11)"

-include ../Make.inc

ifeq (,$(filter clean,$(MAKECMDGOALS)))
include gcc/Makefile
include nvhpc/Makefile
include tools/Makefile
endif
