-include ../Make.user

MAKEFLAGS += --output-sync=recurse

.PHONY: all .locks

all: 3-llvm/generated/env

# Make sure spack.lock files are never removed as intermediate files...
.locks: 1-gcc/spack.lock 2-gcc/spack.lock 3-llvm/spack.lock

# Configure the install location.
1-gcc/config.yaml 2-gcc/config.yaml 3-llvm/config.yaml: | store
	$(SPACK) config --scope=user add config:install_tree:root:$(STORE)

# Detect some build-type packages.
1-gcc/packages.yaml 2-gcc/packages.yaml:
	$(SPACK) external find --scope=user perl m4 autoconf automake libtool gawk python

2-gcc/compilers.yaml: 1-gcc/generated/env
	$(SPACK) compiler find --scope=user $(call compiler_bin_dirs, $$($(SPACK) -e ./1-gcc find --format '{prefix}' gcc@11))

3-llvm/compilers.yaml: 2-gcc/generated/env
	$(SPACK) compiler find --scope=user $(call compiler_bin_dirs, $$($(SPACK) -e ./2-gcc find --format '{prefix}' gcc@11))

include ../Make.inc

# GNU Make isn't very smart about dependencies across included Makefiles, so we
# specify the order here by conditionally including them, when the dependent exists.
ifeq (,$(filter clean,$(MAKECMDGOALS)))

include 1-gcc/Makefile

ifneq (,$(wildcard 1-gcc/Makefile))
include 2-gcc/Makefile
endif

ifneq (,$(wildcard 2-gcc/Makefile))
include 3-llvm/Makefile
endif

endif
