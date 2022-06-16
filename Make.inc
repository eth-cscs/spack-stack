# vi: filetype=make

SPACK ?= spack

SPACK_ENV = $(SPACK) -e $(dir $@)

ifndef STORE
$(error STORE should point to a Spack install root)
endif

store:
	mkdir -p $(STORE)

# Concretization
%/spack.lock: %/spack.yaml %/update-config
	$(SPACK_ENV) concretize -f

# Generate Makefiles for the environment install
%/Makefile: %/spack.lock
	$(SPACK_ENV) env depfile --make-target-prefix $*/generated -o $@