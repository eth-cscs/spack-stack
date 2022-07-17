Bootstrap GCC, LLVM and NVHPC, and build an HPC software stack based on
OpenMPI, with a few unique features:

1. parallel package builds with single jobserver for all builds;
2. avoiding relocation issues by fixing the install path to a new directory `/some-dir` of choice (no root access required);
3. fast, in-memory builds.

**Requirements**:

- `spack`
- `bwrap`

**Usage**:

1. Copy `Make.user.example` to `Make.user` and possibly change some variables.
2. Run `make -j$(nproc)` to bootstrap compilers and packages.
3. Run `make store.squashfs` to bundle those in a squashfs file.

The squashfs file can then be mounted using [squashfs-mount](https://github.com/eth-cscs/squashfs-mount).

A few variables can be set in `Make.user`:

- `STORE`: where to install packages;
- `SPACK`: what `spack` to use;
- `SPACK_INSTALL_FLAGS`: specify more install flags, like `--verbose`.
- `BWRAP`: how to use bubblewrap. By default hides the `/tmp` and home folder.
  This can also be used to bind `/dev/shm/$(STORE)` to `$(STORE)`, so that the
  entire build is on a fast filesystem. To disable bubblewrap set `BWRAP:=`.

For reproducibility, it's useful to prefix make commands with `env -i
PATH=/usr/bin:/bin ...`.

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
