-include Make.user

include Make.inc

.PHONY: compilers packages clean

all: store.tar.zst store.squashfs

compilers:
	$(BWRAP) $(MAKE) -C compilers

packages: compilers
	$(BWRAP) $(MAKE) -C packages

# TODO: bring back "install" type of target.
# # Generate tarball/squashfs files
# store.tar.zst: 1-gcc/generated/env 4-pkgs-gcc/generated/env 5-pkgs-nvhpc/generated/env
# 	tar --totals --use-compress-program="$$($(SPACK) -e ./1-gcc find --format='{prefix}' zstd+programs | head -n1)/bin/zstd -15 -T0" -cf $@ -C $(STORE) .

# store.squashfs: 1-gcc/generated/env 4-pkgs-gcc/generated/env 5-pkgs-nvhpc/generated/env
# 	"$$($(SPACK) -e ./1-gcc find --format='{prefix}' squashfs | head -n1)/bin/mksquashfs" $(STORE) $@ -all-root -no-recovery -noappend

# Clean (todo: maybe call clean targets of included makefiles?)
clean:
	rm -rf -- $(wildcard */*/update-config) $(wildcard */*/spack.lock) $(wildcard */*/.spack-env) $(wildcard */*/Makefile) $(wildcard */*/generated)
