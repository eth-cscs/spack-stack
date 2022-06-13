-include Make.user

SPACK ?= spack

SPACK_ENV = $(SPACK) -e $(dir $@)

ifndef STORE
$(error STORE should point to a Spack install root)
endif

.PHONY: all store clean

all: store.tar.zst store.squashfs

store:
	mkdir -p $(STORE)

# Make sure spack.lock files are never removed as intermediate files...
all_locks: 1-gcc/spack.lock 2-gcc/spack.lock 3-nvhpc/spack.lock 4-pkgs-gcc/spack.lock 5-pkgs-nvhpc/spack.lock

# Concretization
%/spack.lock: %/spack.yaml %/update-config
	$(SPACK_ENV) concretize -f

# Generate Makefiles for the environment install
%/Makefile: %/spack.lock
	$(SPACK_ENV) env depfile --make-target-prefix $*/generated -o $@

# Update environment config (set install_root, detect packages, set compilers)
1-gcc/update-config: | store
	$(SPACK_ENV) config add config:install_tree:root:$(STORE) && \
	$(SPACK_ENV) external find perl m4 autoconf automake libtool gawk && \
	touch $@

2-gcc/update-config: 1-gcc/generated/env | store
	$(SPACK_ENV) config add config:install_tree:root:$(STORE) && \
	$(SPACK_ENV) external find perl m4 autoconf automake libtool gawk && \
	$(SPACK_ENV) compiler find "$$($(SPACK) -e ./1-gcc find --format '{prefix}' gcc@11)" && \
	touch $@

3-nvhpc/update-config: 2-gcc/generated/env | store
	$(SPACK_ENV) config add config:install_tree:root:$(STORE) && \
	$(SPACK_ENV) compiler find "$$($(SPACK) -e ./2-gcc find --format '{prefix}' gcc@11)" && \
	touch $@

4-pkgs-gcc/update-config: 2-gcc/generated/env | store
	$(SPACK_ENV) config add config:install_tree:root:$(STORE) && \
	$(SPACK_ENV) compiler find "$$($(SPACK) -e ./2-gcc find --format '{prefix}' gcc@11)" && \
	touch $@

5-pkgs-nvhpc/update-config: 2-gcc/generated/env 3-nvhpc/generated/env | store
	$(SPACK_ENV) config add config:install_tree:root:$(STORE) && \
	$(SPACK_ENV) compiler find \
		"$$($(SPACK) -e ./2-gcc find --format '{prefix}' gcc@11)" \
		"$$(find "$$($(SPACK) -e ./3-nvhpc find --format '{prefix}' nvhpc)" -iname compilers -type d | head -n1 )/bin" && \
	touch $@

# Generate tarball/squashfs files
store.tar.zst: 1-gcc/generated/env 4-pkgs-gcc/generated/env 5-pkgs-nvhpc/generated/env
	tar --totals --use-compress-program="$$($(SPACK) -e ./1-gcc find --format='{prefix}' zstd+programs | head -n1)/bin/zstd -15 -T0" -cf $@ -C $(STORE) .

store.squashfs: 1-gcc/generated/env 4-pkgs-gcc/generated/env 5-pkgs-nvhpc/generated/env
	"$$($(SPACK) -e ./1-gcc find --format='{prefix}' squashfs | head -n1)/bin/mksquashfs" $(STORE) $@ -all-root -no-recovery -noappend

# Clean (todo: maybe call clean targets of included makefiles?)
clean:
	rm -rf -- $(wildcard */update-config) $(wildcard */spack.lock) $(wildcard */.spack-env) $(wildcard */Makefile) $(wildcard */generated)

# Include Makefiles for environment installs; I can't really specify an include order /
# force a restart of make, so the if's here impose an include order, which is hacky).
ifeq (,$(filter clean,$(MAKECMDGOALS)))
include 1-gcc/Makefile
ifneq (,$(wildcard 1-gcc/Makefile))
include 2-gcc/Makefile
endif
ifneq (,$(wildcard 2-gcc/Makefile))
include 3-nvhpc/Makefile
include 4-pkgs-gcc/Makefile
endif
ifneq (,$(wildcard 3-nvhpc/Makefile))
include 5-pkgs-nvhpc/Makefile
endif
endif
