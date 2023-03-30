Bootstrap GCC, LLVM and NVHPC, and build an HPC software stack based on
OpenMPI, with a few unique features:

1. parallel package builds with single jobserver for all builds;
2. avoiding relocation issues by fixing the install path to a new directory `/some-dir` of choice (no root access required);
3. fast, in-memory builds.

**Requirements**:

- `spack`
- `bwrap` (when not already building inside a sandbox)

**Usage**:

1. Copy `Make.user.example` to `Make.user` and change some variables.
2. Run `make -j$(nproc)` to bootstrap compilers and packages.
3. Run `make store.squashfs` to bundle those in a squashfs file.
4. Run `make build.tar.gz` to create a tarball of all concrete environments and
   generated config files for posterity. This excludes the actual software.

**Variables**

A few variables in `Make.user`:

- `STORE`: where to install packages;
- `SPACK`: what `spack` to use;
- `SPACK_SYSTEM_CONFIG_PATH`: path to spack config dir (e.g. [config/hohgant](config/hohgant)).
- `SANDBOX`: run commands in a sandbox (e.g. bubblewrap), see `Make.user.example` for details.
- `SPACK_INSTALL_FLAGS`: specify more install flags, like `--verbose`.

**Reproducibility**

When building on a production system instead of in a sandbox, there's a few things to
do to improve reproducibility:

1. Always run `make` inside a clean environment:
   ```
   env --ignore-environment PATH=/usr/bin:/bin make
   ```
2. Update `Make.user` to hide your home folder so that no user config is picked up:
   ```
   SANDBOX := bwrap --tmpfs ~ ...
   ```
3. Set `LC_ALL`, `TZ` and `SOURCE_DATE_EPOCH` to something fixed in `Make.user`.

**Unprivileged mounts**

The squashfs file can then be mounted using [squashfs-mount](https://github.com/eth-cscs/squashfs-mount) or `squashfuse`
