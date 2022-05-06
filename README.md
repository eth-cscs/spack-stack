Bootstrap GCC and NVHPC, and build an HPC software stack based on OpenMPI, with a few
unique features:

1. parallel package builds with single jobserver for all builds;
2. building on a fast filesystem, targeting a slower filesystem, without worrying
   about relocation issues.

**Requirements**:

- `spack`
- `bwrap` (optionally)


**Usage**:

Run `make -j$(nproc)`, it outputs two files:
- `store.tar.zst`: a ZStandard compressed tarball of the software stack;
- `store.squashfs`: a SquashFS file of the software stack.

Installing the software stack can be done by extracting the tarball or mounting the
SquashFS file at the `STORE` location.

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