Bootstrap GCC and NVHPC, and build an HPC software stack based on OpenMPI, with a few
unique features:

1. parallel package builds with single jobserver for all builds;
2. building on a fast filesystem, targeting a slower filesystem, without worrying
   about relocation issues.

**Requirements**:

- `spack`
- `bwrap` (optionally)

**Usage**:

1. Copy `Make.user.example` to `Make.user` and possibly change some variables.
2. Run `make -j$(nproc)`

This outputs two files:
- `store.tar.zst`: a ZStandard compressed tarball of the software stack;
- `store.squashfs`: a SquashFS file of the software stack.

Installing the software stack can be done by extracting the tarball or mounting the
SquashFS file at the `STORE` location.

A few variables can be set in `Make.user`:

- `STORE`: where to install packages;
- `SPACK`: what `spack` to use;
- `SPACK_INSTALL_FLAGS`: specify more install flags, like `--verbose`.

To build packages in parallel with nice output, use `-O` (requires GNU make >= 4.3):

```console
make -j<N> -Orecurse
```

To build on a fast filesystem, use `bwrap`, for example:

```console
./bwrap.sh make -j<N> -Orecurse
```

This allows you to map the directory `/dev/shm/$(STORE) -> $(STORE)`, so that the Spack
install directory is fast. Note that `bwrap.sh` has some hard-coded paths you need to
change.

**Generating modules**

There's no `modules.yaml` file right now, but generating modules goes along those lines:

```yaml
modules:
  'default:':
    arch_folder: false
    roots:
      tcl: /path/to/tcl/modules
    enable:
    - tcl
    tcl:
      projections:
        all: '{name}/{version}-{compiler.name}-{compiler.version}'
      all:
        autoload: none
        filter:
          environment_blacklist: ['LD_LIBRARY_PATH', 'LIBRARY_PATH', 'CPATH']
```

```console
spack module tcl refresh
spack module tcl setdefault gcc@11
```