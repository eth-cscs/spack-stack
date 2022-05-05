Bootstrap GCC and NVHPC, and build an HPC software stack based on OpenMPI, with a few
unique features:

1. parallel package builds with single jobserver for all builds;
2. building on a fast filesystem, targeting a slower filesystem, without worrying
   about relocation issues.

**Requirements**:

- `spack` with the following patches:
  1. https://github.com/spack/spack/pull/30254
  2. https://github.com/spack/spack/pull/30302
- `bwrap` (optionally)


**Usage**:

`make` builds a tarball `store.tar.zst` with all compilers and the software stack.

A few variables can be set in `Make.user`:

- `STORE`: where to install packages;
- `SPACK`: what `spack` to use;
- `SPACK_INSTALL_FLAGS`: specify more install flags, like `--verbose`.

To build packages in parallel with nice output, use `-O` (requires GNU make >= 4.3):

```
make -j<N> -Orecurse
```

To build on a fast filesystem, use `bwrap`, for example:

```
./bwrap.sh make -j<N> -Orecurse
```

This allows you to map the directory `/dev/shm/$(STORE) -> $(STORE)`, so that the Spack
install directory is fast.