-include Make.user

# Propagate those variables to other other Makefiles
export SPACK SPACK_JOBS STORE

.PHONY: all store gcc nvhpc clean

all: packages_gcc packages_nvhpc

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

# # tools (tar with zstd)
# tools/spack.lock: tools/spack.yaml
# 	$(SPACK_TOOLS_ENV) concretize -f

# tools/install: tools/spack.lock
# 	$(foreach n, $(BUILDS), $(SPACK_TOOLS_ENV) install --jobs $(JOBS) > /dev/null &) \
# 		$(SPACK_TOOLS_ENV) install --jobs $(JOBS) -v && touch $@


# store.tar.zst: tools/install packages_gcc/install packages_nvhpc/install
# 	# Create a tarball
# 	staging=$$(mktemp -d) && \
# 	$(TIME) ./tools/view/bin/tar --use-compress-program="./tools/view/bin/zstd -T0" -cf "$$staging/$@" -C . && \
# 	$(TIME) mv "$$staging/$@" $@

# install: tools/install
# 	$(TIME) ./tools/view/bin/tar --use-compress-program="./tools/view/bin/zstd -T0" -C $(STORE)-staging --totals -xvf store.tar.zst

clean:
	$(MAKE) -C gcc clean && $(MAKE) -C nvhpc clean && \
	$(MAKE) -C packages_gcc clean && $(MAKE) -C packages_nvhpc clean