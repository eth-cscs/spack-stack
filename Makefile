-include Make.user

.PHONY: all store clean

all: store.tar.zst store.squashfs

store:
	mkdir -p $(STORE)

# make sure spack.lock files are never removed...
all_locks: gcc/spack.lock nvhpc/spack.lock pkgs-gcc/spack.lock pkgs-nvhpc/spack.lock

%/spack.lock: %/spack.yaml %/update-config
	$(SPACK) -e $(dir $@) concretize -f

%/Makefile: %/spack.lock
	$(SPACK) -e $(dir $@) env depfile --make-target-prefix $*/generated -o $@

# update config for environments

gcc/update-config: | store
	$(SPACK) -e $(dir $@) config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e $(dir $@) external find perl m4 autoconf automake libtool gawk libfuse && \
	touch $@

nvhpc/update-config: gcc/generated/env
	$(SPACK) -e $(dir $@) config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e $(dir $@) compiler find \
		"$$($(SPACK) -e ./gcc find --format '{prefix}' gcc@11)" && \
	touch $@

pkgs-gcc/update-config: gcc/generated/env
	$(SPACK) -e $(dir $@) config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e $(dir $@) compiler find \
		"$$($(SPACK) -e ./gcc find --format '{prefix}' gcc@11)" && \
	touch $@

pkgs-nvhpc/update-config: gcc/generated/env nvhpc/generated/env
	$(SPACK) -e $(dir $@) config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e $(dir $@) compiler find \
		"$$($(SPACK) -e ./gcc find --format '{prefix}' gcc@11)" \
		"$$(find "$$($(SPACK) -e ./nvhpc find --format '{prefix}' nvhpc)" -iname compilers -type d | head -n1 )/bin" && \
	touch $@

# bundling

store.tar.zst: pkgs-gcc/generated/env pkgs-nvhpc/generated/env
	tar --totals --use-compress-program="$$($(SPACK) -e ./gcc find --format='{prefix}' zstd+programs | head -n1)/bin/zstd -15 -T0" -cf $@ -C $(STORE) .

store.squashfs: pkgs-gcc/generated/env pkgs-nvhpc/generated/env
	"$$($(SPACK) -e ./gcc find --format='{prefix}' squashfs | head -n1)/bin/mksquashfs" $(STORE) $@ -all-root -no-recovery -noappend

clean:
	rm -rf -- $(wildcard */update-config) $(wildcard */spack.lock) $(wildcard */.spack-env) $(wildcard */Makefile) $(wildcard */generated)

# clean should run without rebuilding makefiles
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
