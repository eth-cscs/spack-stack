-include Make.user

.PHONY: compilers packages clean

all: packages

bootstrap:
	@echo Making sure Spack is properly bootstrapped...
	$(BWRAP) $(SPACK) spec zlib > /dev/null

compilers: | bootstrap
	$(BWRAP) $(MAKE) -C compilers

packages: compilers | bootstrap
	$(BWRAP) $(MAKE) -C packages

include Make.inc

store.squashfs: compilers
	$(BWRAP) "$$($(BWRAP) $(SPACK) -e ./compilers/1-gcc find --format='{prefix}' squashfs | head -n1)/bin/mksquashfs" $(STORE) $@ -all-root -no-recovery -noappend -offset 4096 -Xcompression-level 3 && \
	dd if=/dev/zero of=$@ conv=notrunc count=8 && \
	echo -n $(STORE) | dd of=$@ conv=notrunc

# Clean (todo: maybe call clean targets of included makefiles?)
clean:
	rm -rf -- $(wildcard */*/update-config) $(wildcard */*/spack.lock) $(wildcard */*/.spack-env) $(wildcard */*/Makefile) $(wildcard */*/generated) $(wildcard cache)