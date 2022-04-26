-include Make.user

# Propagate those variables to other other Makefiles
export SPACK SPACK_JOBS STORE

.PHONY: all store gcc nvhpc packages_gcc packages_nvhpc clean

all: store.tar.zstd

store:
	mkdir -p $(STORE)

gcc: | store
	$(MAKE) -C $@

nvhpc: | gcc
	$(MAKE) -C $@

packages_gcc: | gcc
	$(MAKE) -C $@

packages_nvhpc: | nvhpc
	$(MAKE) -C $@

store.tar.zst: | packages_gcc packages_nvhpc
	tar --use-compress-program="$$(spack -e ./gcc find --format='{prefix}' zstd+programs | head -n1)/bin/zstd -T0" -cf $@ -C $(STORE) .

clean:
	$(MAKE) -C gcc clean && $(MAKE) -C nvhpc clean && \
	$(MAKE) -C packages_gcc clean && $(MAKE) -C packages_nvhpc clean
