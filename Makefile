-include Make.user

.PHONY: compilers packages clean

all: packages

compilers:
	$(BWRAP) $(MAKE) -C compilers

packages: compilers
	$(BWRAP) $(MAKE) -C packages

include Make.inc

store.squashfs: compilers
	echo -n /spack-store > $@ && \
	dd if=/dev/null of=$@ obs=4K seek=1 status=none && \
	$(BWRAP) "$$($(BWRAP) $(SPACK) -e ./compilers/1-gcc find --format='{prefix}' squashfs | head -n1)/bin/mksquashfs" $(STORE) $@ -all-root -no-recovery -noappend -o 4K

# Clean (todo: maybe call clean targets of included makefiles?)
clean:
	rm -rf -- $(wildcard */*/update-config) $(wildcard */*/spack.lock) $(wildcard */*/.spack-env) $(wildcard */*/Makefile) $(wildcard */*/generated)
