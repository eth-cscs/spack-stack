`make` bootstraps first gcc, then nvhpc using a gcc, then build openmpi with gcc and nvhpc, then create a tarball.

`make install` will extract the tarball on the target directory.

- The software stack is built in memory
- `bwrap` is used to map say `/dev/shm/apps` to `/apps` to avoid relocation issues, assuming the final binaries are going to live in /apps/something/...
- There's parallellism over 4 packages, each using `JOBS=64` threads.

Note:

Some paths are still hard-coded (see config section of spack.yaml files).

By default Spack is assumed to live in `/dev/shm/spack`.

https://github.com/spack/spack/pull/30189 is required in Spack for nvhpc.

Customizing install locations goes like:

```console
make SPACK=/dev/shm/spack/bin/spack FAST_FILESYSTEM=/dev/shm ROOT=/apps STORE=/apps/manali/UES/store install
```
