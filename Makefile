-include Make.user

# compilers.yaml and packages.yaml
SPACK_USER_CONFIG_PATH ?= $(CURDIR)/config
export SPACK_USER_CONFIG_PATH

.PHONY: all store clean

all: store.tar.zst

store:
	mkdir -p $(STORE)

# Compiler GCC
gcc/update-config: | store
	$(SPACK) -e ./gcc config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e ./gcc compiler find && \
	touch $@

gcc/spack.lock: gcc/spack.yaml gcc/update-config
	$(SPACK) -e ./gcc concretize -f

gcc/Makefile: gcc/spack.lock
	$(SPACK) -e ./gcc env generate-makefile --target-prefix gcc_deps > $@

# Compiler NVHPC
nvhpc/update-config: gcc_deps/all
	$(SPACK) -e ./nvhpc config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e ./nvhpc compiler find \
		"$$($(SPACK) -e ./gcc find --format '{prefix}' gcc@11)" && \
	touch $@

nvhpc/spack.lock: nvhpc/spack.yaml nvhpc/update-config
	$(SPACK) -e ./nvhpc concretize -f

nvhpc/Makefile: nvhpc/spack.lock
	$(SPACK) -e ./nvhpc env generate-makefile --target-prefix nvhpc_deps > $@

## Packages GCC
packages_gcc/update-config: gcc_deps/all
	$(SPACK) -e ./packages_gcc config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e ./packages_gcc compiler find \
		"$$($(SPACK) -e ./gcc find --format '{prefix}' gcc@11)" && \
	touch $@

packages_gcc/spack.lock: packages_gcc/spack.yaml packages_gcc/update-config
	$(SPACK) -e ./packages_gcc concretize -f

packages_gcc/Makefile: packages_gcc/spack.lock
	$(SPACK) -e ./packages_gcc env generate-makefile --target-prefix packages_gcc_deps > $@

## Packags NVHPC
packages_nvhpc/update-config: gcc_deps/all nvhpc_deps/all
	$(SPACK) -e ./packages_nvhpc config add config:install_tree:root:$(STORE) && \
	$(SPACK) -e ./packages_nvhpc compiler find \
		"$$($(SPACK) -e ./gcc find --format '{prefix}' gcc@11)" \
		"$$(find "$$($(SPACK) -e ./nvhpc find --format '{prefix}' nvhpc)" -iname compilers -type d | head -n1 )/bin" && \
	touch $@

packages_nvhpc/spack.lock: packages_nvhpc/spack.yaml packages_nvhpc/update-config
	$(SPACK) -e ./packages_nvhpc concretize -f

packages_nvhpc/Makefile: packages_nvhpc/spack.lock
	$(SPACK) -e ./packages_nvhpc env generate-makefile --target-prefix packages_nvhpc_deps > $@

store.tar.zst: packages_gcc_deps/all packages_nvhpc_deps/all
	tar --use-compress-program="$$(spack -e ./gcc find --format='{prefix}' zstd+programs | head -n1)/bin/zstd -T0" -cf $@ -C $(STORE) .

# clean should run without rebuilding makefiles
clean:
	rm -rf -- gcc/update-config gcc/spack.lock gcc/Makefile gcc_deps \
	          nvhpc/update-config nvhpc/spack.lock nvhpc/Makefile nvhpc_deps \
	          packages_gcc/update-config packages_gcc/spack.lock packages_gcc/Makefile packages_gcc_deps \
	          packages_nvhpc/update-config packages_nvhpc/spack.lock packages_nvhpc/Makefile packages_nvhpc_deps \

ifeq (,$(filter clean,$(MAKECMDGOALS)))
-include gcc/Makefile
-include nvhpc/Makefile
-include packages_gcc/Makefile
-include packages_nvhpc/Makefile
endif