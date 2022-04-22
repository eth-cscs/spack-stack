JOBS := 64
BUILDS := 1 2 3
FAST_FILESYSTEM := /dev/shm
ROOT := /apps
STORE := $(ROOT)/manali/UES/store
FAST_STORE := $(FAST_FILESYSTEM)/$(STORE)
SPACK := $(FAST_FILESYSTEM)/spack/bin/spack
BWRAP := bwrap --dev-bind / / --tmpfs /tmp --bind "$(FAST_FILESYSTEM)/$(ROOT)" "$(ROOT)" --bind "$(CURDIR)" "$(CURDIR)"
TIME := time

SPACK_GCC_ENV := $(BWRAP) $(SPACK) -e ./gcc -c config:install_tree:root:$(STORE)
SPACK_NVHPC_ENV := $(BWRAP) $(SPACK) -e ./nvhpc -c config:install_tree:root:$(STORE)
SPACK_PACKAGES_GCC_ENV := $(BWRAP) $(SPACK) -e ./packages_gcc -c config:install_tree:root:$(STORE)
SPACK_PACKAGES_NVHPC_ENV := $(BWRAP) $(SPACK) -e ./packages_nvhpc -c config:install_tree:root:$(STORE)
SPACK_TOOLS_ENV := $(BWRAP) $(SPACK) -e ./tools -c config:install_tree:root:$(STORE)

.PHONY: all fast_store install clean

all: store.tar.zst

$(FAST_STORE):
	mkdir -p $(FAST_STORE)


gcc/spack.lock: gcc/spack.yaml $(FAST_STORE)
	$(SPACK_GCC_ENV) concretize -f

gcc/install: gcc/spack.lock $(FAST_STORE)
	$(foreach n, $(BUILDS), $(SPACK_GCC_ENV) install --jobs $(JOBS) > /dev/null &) \
		$(SPACK_GCC_ENV) install --jobs $(JOBS) -v; touch $@


nvhpc/register-compilers: gcc/install $(FAST_STORE)
	$(SPACK_NVHPC_ENV) compiler find $$($(SPACK_GCC_ENV) find --format '{prefix}' gcc@11) && touch $@

nvhpc/spack.lock: nvhpc/register-compilers nvhpc/spack.yaml $(FAST_STORE)
	$(SPACK_NVHPC_ENV) concretize -f

nvhpc/install: nvhpc/spack.lock $(FAST_STORE)
	$(foreach n, $(BUILDS), $(SPACK_NVHPC_ENV) install --jobs $(JOBS) > /dev/null &) \
		$(SPACK_NVHPC_ENV) install --jobs $(JOBS) -v && touch $@


packages_gcc/register-compilers: gcc/install nvhpc/install $(FAST_STORE)
	$(SPACK_PACKAGES_GCC_ENV) compiler find $$($(SPACK_GCC_ENV) find --format '{prefix}' gcc@11) && \
		touch $@

packages_gcc/spack.lock: packages_gcc/spack.yaml packages_gcc/register-compilers $(FAST_STORE)
	$(SPACK_PACKAGES_GCC_ENV) concretize -f

packages_gcc/install: packages_gcc/spack.lock $(FAST_STORE)
	$(foreach n, $(BUILDS), $(SPACK_PACKAGES_GCC_ENV) install --jobs $(JOBS) > /dev/null &) \
		$(SPACK_PACKAGES_GCC_ENV) install --jobs $(JOBS) -v && touch $@


packages_nvhpc/register-compilers: gcc/install nvhpc/install $(FAST_STORE)
	# detect gcc and nvhpc
	$(SPACK_PACKAGES_NVHPC_ENV) compiler find \
		"$$($(SPACK_GCC_ENV) find --format '{prefix}' gcc@11)" \
		"$$($(BWRAP) find "$$($(SPACK_NVHPC_ENV) find --format '{prefix}' nvhpc)" -iname compilers -type d | head -n1 )/bin" && \
			touch $@

packages_nvhpc/spack.lock: packages_nvhpc/spack.yaml packages_nvhpc/register-compilers $(FAST_STORE)
	$(SPACK_PACKAGES_NVHPC_ENV) concretize -f

packages_nvhpc/install: packages_nvhpc/spack.lock $(FAST_STORE)
	$(foreach n, $(BUILDS), $(SPACK_PACKAGES_NVHPC_ENV) install --jobs $(JOBS) > /dev/null &) \
		$(SPACK_PACKAGES_NVHPC_ENV) install --jobs $(JOBS) -v && touch $@


# tools (tar with zstd)
tools/spack.lock: tools/spack.yaml $(FAST_STORE)
	$(SPACK_TOOLS_ENV) concretize -f

tools/install: tools/spack.lock $(FAST_STORE)
	$(foreach n, $(BUILDS), $(SPACK_TOOLS_ENV) install --jobs $(JOBS) > /dev/null &) \
		$(SPACK_TOOLS_ENV) install --jobs $(JOBS) -v && touch $@


store.tar.zst: tools/install packages_gcc/install packages_nvhpc/install
	# Create a tarball
	staging=$$(mktemp -d) && \
	$(TIME) ./tools/view/bin/tar --use-compress-program="./tools/view/bin/zstd -T0" -cf "$$staging/$@" -C $(FAST_STORE) . && \
	$(TIME) mv "$$staging/$@" $@

install: tools/install
	$(TIME) ./tools/view/bin/tar --use-compress-program="./tools/view/bin/zstd -T0" -C $(STORE)-staging --totals -xvf store.tar.zst

clean:
	rm -f -- */spack.lock */install */register-compilers
