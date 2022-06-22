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
2. Run `env -i PATH=/usr/bin:/bin make -j$(nproc)`

This outputs two files:
- `store.tar.zst`: a ZStandard compressed tarball of the software stack;
- `store.squashfs`: a SquashFS file of the software stack.

Installing the software stack can be done by extracting the tarball or mounting the
SquashFS file at the `STORE` location.

A few variables can be set in `Make.user`:

- `STORE`: where to install packages;
- `SPACK`: what `spack` to use;
- `SPACK_INSTALL_FLAGS`: specify more install flags, like `--verbose`.
- `BWRAP`: how to use bubblewrap. By default used to setup a pristine `/tmp` folder, since some packages (cuda toolkit, mkl) write a "lock" to `/tmp` and don't allow simultaneous installs, which is not an issue with Spack. This can also be used to bind `/dev/shm/$(STORE)` to `$(STORE)`, so that the entire build is on a fast filesystem. To disable bubblewrap set `BWRAP:=`.

To build packages in parallel with nice output, use `-O` (requires GNU make >= 4.3):

```console
env -i PATH=/usr/bin:/bin make -j<N> -Orecurse
```

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
