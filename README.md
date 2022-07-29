Bootstrap GCC, LLVM and NVHPC, and build an HPC software stack based on
OpenMPI, with a few unique features:

1. parallel package builds with single jobserver for all builds;
2. avoiding relocation issues by fixing the install path to a new directory `/some-dir` of choice (no root access required);
3. fast, in-memory builds.

**Requirements**:

- `spack`
- `bwrap` (when not already building inside a sandbox)

**Usage**:

1. Copy `Make.user.example` to `Make.user` and change some variables[^1].
2. Run `make -j$(nproc)` to bootstrap compilers and packages[^2].
3. Run `make store.squashfs` to bundle those in a squashfs file.

[^1]: For reproducibility, build with a clean environment: `env -i PATH=/usr/bin:/bin make ...`.

[^2]: A few variables should be set in `Make.user`:
    - `STORE`: where to install packages;
    - `SPACK`: what `spack` to use;
    - `SPACK_SYSTEM_CONFIG_PATH`: path to spack config dir (e.g. [config/hohgant](config/hohgant)).
    - `BWRAP`: use bubblewrap for sandboxing and speed: see `Make.user.example` for details.
    - `SPACK_INSTALL_FLAGS`: specify more install flags, like `--verbose`.

**Unprivileged mounts**

The squashfs file can then be mounted using [squashfs-mount](https://github.com/eth-cscs/squashfs-mount) or `squashfuse`
