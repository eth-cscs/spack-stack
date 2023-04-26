# Building for MCH

This stack is specific to MCH

## status

**Current Version**: v3

## building

```bash
mkdir /dev/shm/mch-build
cd /dev/shm/mch-build

git clone git@github.com:bcumming/spack-stack.git
cd spack-stack
git checkout balfrinv3

# TODO: update configuration before running configure.sh
./configure.sh
env --ignore-environment PATH=/usr/bin:/bin:`pwd`/spack/bin make modules -j64
env --ignore-environment PATH=/usr/bin:/bin:`pwd`/spack/bin make store.squashfs

# make a copy of the new image, e.g.
mv store.squashfs $SCRATCH/balfrin-v3.squashfs
```
