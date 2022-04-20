JOBS :=64
FAST_FILESYSTEM := /dev/shm
ROOT := /apps
STORE := $(ROOT)/manali/UES/store
FAST_STORE := $(FAST_FILESYSTEM)/$(STORE)
SPACK := $(FAST_FILESYSTEM)/spack/bin/spack
BWRAP := bwrap --dev-bind / / --bind "$(FAST_FILESYSTEM)/$(ROOT)" "$(ROOT)" --bind "$(CURDIR)" "$(CURDIR)"
TIME := time

all: store.tar.zst

gcc/spack.lock: gcc/spack.yaml
	$(BWRAP) $(SPACK) -e ./gcc concretize -f

gcc/install: gcc/spack.lock
	$(BWRAP) $(SPACK) -e ./gcc install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./gcc install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./gcc install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./gcc install -j$(JOBS) -v && touch $@

nvhpc/register-compilers: gcc/install
	$(BWRAP) $(SPACK) -e ./nvhpc compiler find $$($(SPACK) -e ./gcc find --format '{prefix}' gcc@9) && touch $@

nvhpc/spack.lock: nvhpc/register-compilers nvhpc/spack.yaml
	$(BWRAP) $(SPACK) -e ./nvhpc concretize -f

nvhpc/install: nvhpc/spack.lock
	$(BWRAP) $(SPACK) -e ./nvhpc install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./nvhpc install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./nvhpc install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./nvhpc install -j$(JOBS) -v && touch $@

openmpi/register-compilers: gcc/install nvhpc/install
	$(BWRAP) $(SPACK) -e ./openmpi compiler find $$($(SPACK) -e ./gcc find --format '{prefix}' gcc@9) && touch $@

openmpi/spack.lock: openmpi/spack.yaml openmpi/register-compilers
	# Concretize
	$(BWRAP) $(SPACK) -e ./openmpi concretize -f

openmpi/install: openmpi/spack.lock
	$(BWRAP) $(SPACK) -e ./openmpi install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./openmpi install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./openmpi install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./openmpi install -j$(JOBS) -v && touch $@

# tools (tar with zstd)
tools/spack.lock: tools/spack.yaml
	$(BWRAP) $(SPACK) -e ./tools concretize -f

tools/install: tools/spack.lock
	$(BWRAP) $(SPACK) -e ./tools install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./tools install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./tools install -j$(JOBS) > /dev/null & \
	$(BWRAP) $(SPACK) -e ./tools install -j$(JOBS) -v && touch $@

store.tar.zst: tools/install openmpi/install
	# Create a tarball
	staging=$$(mktemp -d) && \
	$(TIME) ./tools/view/bin/tar --use-compress-program="./tools/view/bin/zstd -T0" -cf "$$staging/$@" -C $(FAST_STORE) . && \
	$(TIME) mv "$$staging/$@" $@

install: store.tar.zst tools/install
	$(TIME) ./tools/view/bin/tar --use-compress-program="./tools/view/bin/zstd -T0" -C $(STORE) --totals -xvf $<
clean:
	rm -f -- */spack.lock */install */register-compilers
