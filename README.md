Bootstrap GCC and NVHPC, and build an HPC software stack based on OpenMPI, with a few
unique features:

1. parallel package builds (with multiple jobs per package);
2. building on a fast filesystem, targeting a slower filesystem, without worrying
   about relocation issues.

**Requirements**:

- `spack` with the following patches:
  1. https://github.com/spack/spack/pull/30254
  2. https://github.com/spack/spack/pull/30215
- `bwrap` (optionally)


**Usage**:

`make` builds a tarball `store.tar.zst` with all compilers and the software stack.

A few variables can be set in `Make.user`:

- `STORE`: spack install location;
- `SPACK`: path to `spack`;
- `SPACK_JOBS`: maximum number of jobs per spack package install.

To build packages in parallel with nice output, use the following flags:

```
make SPACK_COLOR=always -j<N> -O
```

To build on a fast filesystem, use `bwrap`, for example:

```
./bwrap.sh make SPACK_COLOR=always -j -O
```

This allows you to map the directory `/dev/shm/$(STORE) -> $(STORE)`, so that the Spack
install directory is fast.