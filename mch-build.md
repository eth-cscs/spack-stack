# Building for MCH

This stack is specific to MCH

**Current Version**: v0.3

```bash
mkdir /dev/shm/mch-build
cd /dev/shm/mch-build

git clone git@github.com:bcumming/spack-stack.git
cd spack-stack
./configure.sh
env --ignore-environment PATH=/usr/bin:/bin:`pwd`/spack/bin make modules -j64
env --ignore-environment PATH=/usr/bin:/bin:`pwd`/spack/bin make store.squashfs
```
