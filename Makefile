JOBS :=64
FAST_FILESYSTEM := /dev/shm
ROOT := /apps
STORE := $(ROOT)/manali/UES/store
FAST_STORE := $(FAST_FILESYSTEM)/$(STORE)
SPACK := $(FAST_FILESYSTEM)/spack/bin/spack
BWRAP := bwrap --dev-bind / / --bind "$(FAST_FILESYSTEM)/$(ROOT)" "$(ROOT)" --bind "$(CURDIR)" "$(CURDIR)"
TIME := time

.PHONY: all fast_store install clean

all: store.tar.zst

fast_store:
	mkdir -p $(FAST_STORE)

gcc/spack.lock: gcc/spack.yaml fast_store
	$(BWRAP) $(SPACK) -e ./gcc concretize -f

gcc/install: gcc/spack.lock fast_store
	$(BWRAP) $(SPACK) -e ./gcc install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./gcc install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./gcc install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./gcc install -j$(JOBS) -v && touch $@

nvhpc/register-compilers: gcc/install fast_store
	$(BWRAP) $(SPACK) -e ./nvhpc compiler find $$($(SPACK) -e ./gcc find --format '{prefix}' gcc@11) && touch $@

nvhpc/spack.lock: nvhpc/register-compilers nvhpc/spack.yaml fast_store
	$(BWRAP) $(SPACK) -e ./nvhpc concretize -f

nvhpc/install: nvhpc/spack.lock fast_store
	$(BWRAP) $(SPACK) -e ./nvhpc install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./nvhpc install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./nvhpc install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./nvhpc install -j$(JOBS) -v && touch $@

openmpi/register-compilers: gcc/install nvhpc/install fast_store
	$(BWRAP) $(SPACK) -e ./openmpi compiler find $$($(BWRAP) $(SPACK) -e ./gcc find --format '{prefix}' gcc@11) && \
	$(BWRAP) $(SPACK) -e ./openmpi compiler find "$$($(BWRAP) find "$$($(BWRAP) $(SPACK) -e ./nvhpc find --format '{prefix}' nvhpc)" -iname compilers -type d | head -n1 )/bin" && \
	touch $@

openmpi/spack.lock: openmpi/spack.yaml openmpi/register-compilers fast_store
	# Concretize
	$(BWRAP) $(SPACK) -e ./openmpi concretize -f

openmpi/install: openmpi/spack.lock fast_store
	$(BWRAP) $(SPACK) -e ./openmpi install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./openmpi install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./openmpi install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./openmpi install -j$(JOBS) -v && touch $@

# tools (tar with zstd)
tools/spack.lock: tools/spack.yaml fast_store
	$(BWRAP) $(SPACK) -e ./tools concretize -f

tools/install: tools/spack.lock fast_store
	$(BWRAP) $(SPACK) -e ./tools install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./tools install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./tools install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./tools install -j$(JOBS) -v && touch $@

store.tar.zst: tools/install openmpi/install
	# Create a tarball
	staging=$$(mktemp -d) && \
	$(TIME) ./tools/view/bin/tar --use-compress-program="./tools/view/bin/zstd -T0" -cf "$$staging/$@" -C $(FAST_STORE) . && \
	$(TIME) mv "$$staging/$@" $@

install: tools/install
	$(TIME) ./tools/view/bin/tar --use-compress-program="./tools/view/bin/zstd -T0" -C $(STORE)-staging --totals -xvf store.tar.zst

clean:
	rm -f -- */spack.lock */install */register-compilers
