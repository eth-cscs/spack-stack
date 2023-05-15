# Building for MCH

This stack is specific to MCH

## status

**Current Version**: v4 rc0

## building

```bash
mkdir /dev/shm/mch-build
cd /dev/shm/mch-build

git clone git@github.com:eth-cscs/spack-stack.git
cd spack-stack

# TODO: update configuration before running configure.sh
./configure.sh
env --ignore-environment PATH=/usr/bin:/bin:`pwd`/spack/bin make modules -j64
env --ignore-environment PATH=/usr/bin:/bin:`pwd`/spack/bin make store.squashfs

# make a copy of the new image, e.g.
mv store.squashfs $SCRATCH/balfrin-<tag>.squashfs
```
