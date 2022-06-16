-include ../Make.user

all: 3-llvm/generated/env

# Make sure spack.lock files are never removed as intermediate files...
all_locks: 1-gcc/spack.lock 2-gcc/spack.lock 3-llvm/spack.lock

# Concretization
%/spack.lock: %/spack.yaml %/update-config
	$(SPACK_ENV) concretize -f

# Generate Makefiles for the environment install
%/Makefile: %/spack.lock
	$(SPACK_ENV) env depfile --make-target-prefix $*/generated -o $@

# Update environment config (set install_root, detect packages, set compilers)
1-gcc/update-config: | store
	$(SPACK_ENV) config add config:install_tree:root:$(STORE) && \
	$(SPACK_ENV) external find perl m4 autoconf automake libtool gawk libfuse && \
	touch $@

2-gcc/update-config: 1-gcc/generated/env | store
	$(SPACK_ENV) config add config:install_tree:root:$(STORE) && \
	$(SPACK_ENV) external find perl m4 autoconf automake libtool gawk python && \
	$(SPACK_ENV) compiler find "$$($(SPACK) -e ./1-gcc find --format '{prefix}' gcc@11)" && \
	touch $@

3-llvm/update-config: 2-gcc/generated/env | store
	$(SPACK_ENV) config add config:install_tree:root:$(STORE) && \
	$(SPACK_ENV) compiler find "$$($(SPACK) -e ./2-gcc find --format '{prefix}' gcc@11)" && \
	touch $@

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