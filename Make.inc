# vi: filetype=make

SPACK ?= spack

SPACK_ENV = $(SPACK) -e $(dir $@)

ifndef STORE
$(error STORE should point to a Spack install root)
endif

ifeq ($(wildcard $(SPACK_USER_CONFIG_PATH)),)
$(error SPACK_USER_CONFIG_PATH = "$(SPACK_USER_CONFIG_PATH)" doesn't point to an existing directory)
endif

store:
	mkdir -p $(STORE)

# Concretization
%/spack.lock: %/spack.yaml %/update-config
	$(SPACK_ENV) concretize -f

# Generate Makefiles for the environment install
%/Makefile: %/spack.lock
	$(SPACK_ENV) env depfile --make-target-prefix $*/generated -o $@