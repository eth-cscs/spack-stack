-include Make.user

SPACK ?= spack

ifndef STORE
$(error STORE should point to a Spack install root)
endif

.PHONY: all store clean

all: store.tar.zst store.squashfs

store:
	mkdir -p $(STORE)

# Make sure spack.lock files are never removed as intermediate files...
all_locks: gcc/spack.lock nvhpc/spack.lock pkgs-gcc/spack.lock pkgs-nvhpc/spack.lock

# Concretization
%/spack.lock: %/spack.yaml %/update-config
	$(SPACK) -e $(dir $@) concretize -f

# Generate Makefiles for the environment install
%/Makefile: %/spack.lock
	$(SPACK) -e $(dir $@) env depfile --make-target-prefix $*/generated -o $@

# Update environment config (set install_root, detect packages, set compilers)
gcc/update-config: | store
	$(SPACK) -e $(dir $@) config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e $(dir $@) external find perl m4 autoconf automake libtool gawk libfuse && \
	touch $@

nvhpc/update-config: gcc/generated/env | store
	$(SPACK) -e $(dir $@) config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e $(dir $@) compiler find \
		"$$($(SPACK) -e ./gcc find --format '{prefix}' gcc@11)" && \
	touch $@

pkgs-gcc/update-config: gcc/generated/env | store
	$(SPACK) -e $(dir $@) config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e $(dir $@) compiler find \
		"$$($(SPACK) -e ./gcc find --format '{prefix}' gcc@11)" && \
	touch $@

pkgs-nvhpc/update-config: gcc/generated/env nvhpc/generated/env | store
	$(SPACK) -e $(dir $@) config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e $(dir $@) compiler find \
		"$$($(SPACK) -e ./gcc find --format '{prefix}' gcc@11)" \
		"$$(find "$$($(SPACK) -e ./nvhpc find --format '{prefix}' nvhpc)" -iname compilers -type d | head -n1 )/bin" && \
	touch $@

# Generate tarball/squashfs files
store.tar.zst: pkgs-gcc/generated/env pkgs-nvhpc/generated/env
	tar --totals --use-compress-program="$$($(SPACK) -e ./gcc find --format='{prefix}' zstd+programs | head -n1)/bin/zstd -15 -T0" -cf $@ -C $(STORE) .

store.squashfs: pkgs-gcc/generated/env pkgs-nvhpc/generated/env
	"$$($(SPACK) -e ./gcc find --format='{prefix}' squashfs | head -n1)/bin/mksquashfs" $(STORE) $@ -all-root -no-recovery -noappend

# Clean (todo: maybe call clean targets of included makefiles?)
clean:
	rm -rf -- $(wildcard */update-config) $(wildcard */spack.lock) $(wildcard */.spack-env) $(wildcard */Makefile) $(wildcard */generated)

# Include Makefiles for environment installs; I can't really specify an include order /
# force a restart of make, so the if's here impose an include order, which is hacky).
ifeq (,$(filter clean,$(MAKECMDGOALS)))
include gcc/Makefile
ifneq (,$(wildcard gcc/Makefile))
include nvhpc/Makefile
endif
ifneq (,$(wildcard gcc/Makefile))
include pkgs-gcc/Makefile
endif
ifneq (,$(wildcard nvhpc/Makefile))
include pkgs-nvhpc/Makefile
endif
endif
