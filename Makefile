-include Make.user

.PHONY: all store clean

all: store.tar.zst store.squashfs

store:
	mkdir -p $(STORE)

# Compiler GCC
gcc/update-config: | store
	$(SPACK) -e ./gcc config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e ./gcc external find perl m4 autoconf automake libtool gawk libfuse && \
	touch $@

%/spack.lock: %/spack.yaml %/update-config
	$(SPACK) -e $(dir $@) concretize -f

%/Makefile: %/spack.lock
	$(SPACK) -e $(dir $@) env depfile --make-target-prefix $*/generated -o $@

# hack to make sure spack.lock files are not removed...
all_locks: gcc/spack.lock nvhpc/spack.lock packages_gcc/spack.lock packages_nvhpc/spack.lock

# Compiler NVHPC
nvhpc/update-config: gcc/generated/env
	$(SPACK) -e ./nvhpc config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e ./nvhpc compiler find \
		"$$($(SPACK) -e ./gcc find --format '{prefix}' gcc@11)" && \
	touch $@

## Packages GCC
packages_gcc/update-config: gcc/generated/env
	$(SPACK) -e ./packages_gcc config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e ./packages_gcc compiler find \
		"$$($(SPACK) -e ./gcc find --format '{prefix}' gcc@11)" && \
	touch $@

## Packags NVHPC
packages_nvhpc/update-config: gcc/generated/env nvhpc/generated/env
	$(SPACK) -e ./packages_nvhpc config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e ./packages_nvhpc compiler find \
		"$$($(SPACK) -e ./gcc find --format '{prefix}' gcc@11)" \
		"$$(find "$$($(SPACK) -e ./nvhpc find --format '{prefix}' nvhpc)" -iname compilers -type d | head -n1 )/bin" && \
	touch $@

store.tar.zst: packages_gcc/generated/env packages_nvhpc/generated/env
	tar --totals --use-compress-program="$$($(SPACK) -e ./gcc find --format='{prefix}' zstd+programs | head -n1)/bin/zstd -15 -T0" -cf $@ -C $(STORE) .

store.squashfs: packages_gcc/generated/env packages_nvhpc/generated/env
	"$$($(SPACK) -e ./gcc find --format='{prefix}' squashfs | head -n1)/bin/mksquashfs" $(STORE) $@ -all-root -no-recovery -noappend

# clean should run without rebuilding makefiles
clean:
	rm -rf -- $(wildcard */update-config) $(wildcard */spack.lock) $(wildcard */.spack-env) $(wildcard */Makefile) $(wildcard */generated)

ifeq (,$(filter clean,$(MAKECMDGOALS)))
include gcc/Makefile
ifneq (,$(wildcard gcc/Makefile))
include nvhpc/Makefile
endif
ifneq (,$(wildcard packages_gcc/Makefile))
include packages_gcc/Makefile
endif
ifneq (,$(wildcard nvhpc/Makefile))
include packages_nvhpc/Makefile
endif
endif
