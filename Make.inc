# vi: filetype=make

SPACK ?= spack

SPACK_ENV = $(SPACK) -e $(dir $@)

ifndef STORE
$(error STORE should point to a Spack install root)
endif

ifeq ($(wildcard $(SPACK_SYSTEM_CONFIG_PATH)),)
$(error SPACK_SYSTEM_CONFIG_PATH = "$(SPACK_SYSTEM_CONFIG_PATH)" doesn't point to an existing directory)
endif

# Guard against accidentally running on Cray.
SPACK_ARCH:=$(shell $(BWRAP) $(SPACK) arch)
ifeq (cray,$(findstring cray,$(SPACK_ARCH)))
$(error `spack arch = $(SPACK_ARCH)` contains `cray`. You likely don't want to run Spack in Cray modules mode. To fix this, run from a clean environment: `env -i PATH=/usr/bin:/bin make ...`)
else
$(info spack arch = $(SPACK_ARCH))
endif

store:
	mkdir -p $(STORE)

# Concretization
%/spack.lock: %/spack.yaml %/compilers.yaml %/config.yaml %/packages.yaml
	$(SPACK_ENV) concretize -f

# Generate Makefiles for the environment install
%/Makefile: %/spack.lock
	$(SPACK_ENV) env depfile --make-target-prefix $*/generated -o $@

# For generating {compilers,config,packages}.yaml files.
%.yaml: export SPACK_USER_CONFIG_PATH=$(abspath $(dir $@))
%.yaml:
	touch $@

# Because Spack doesn't know how to find compilers, we help it by getting the bin folder of gcc, clang, nvc given a install prefix
compiler_bin_dirs = $$(find $(1) '(' -name gcc -o -name clang -o -name nvc ')' -path '*/bin/*' '(' -type f -o -type l ')' -exec dirname {} +)
