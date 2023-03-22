#! /usr/bin/bash

cluster=$CLUSTER_NAME
echo "=== targeting $cluster"

config_path=$(pwd)/config/$cluster
if [ ! -d "$config_path" ]
then
    echo "ERROR: no config for cluster with name $cluster"
    exit
fi

# TODO update this for the target cluster
store_root="/mch-environment/devt"

echo "=== creating repos.yaml in $config_path/repos.yaml"
echo "repos:
- ${store_root}/repo" > $config_path/repos.yaml

recipe_path="$(pwd)/recipe"
cp ${recipe_path}/Make.user .

mkdir -p tmp store

if [ ! -d "$(pwd)/spack/.git" ]
then
    echo "=== installing spack"
    git clone git@github.com:spack/spack.git
    (cd spack && git checkout a8b1314d188149e696eb8e7ba3e4d0de548f1894)
fi

for target in gcc tools nvhpc
do
    recipe="${recipe_path}/${target}.spack.yaml"
    if [ -f "${recipe}" ]
    then
        echo "=== setting custom ${target} packages: ${recipe}"
        cp "${recipe}" packages/${target}/spack.yaml
    fi
done

mkdir -p module-config
rm -rf module-config/*
recipe="${recipe_path}/modules.yaml"
if [ -f "${recipe}" ]
then
    echo "=== setting custom modules configuration: ${recipe}"
    cp "${recipe}" module-config
    cp ${recipe_path}/upstreams.yaml module-config
fi

echo "=== patching cray-mpich-binary spack package"

if [ ! -d "$(pwd)/store/repo" ]
then
    echo "=== copying repo to store"
    cp -R ${recipe_path}/repo store
fi

for f in `ls module-config/*.*` Make.user
do
    echo UPDATING $f
    sed -i "s|MOUNTPOINT|${store_root}|g" $f
done

#mkdir -p spack/var/spack/repos/builtin/packages/cray-mpich-binary
#cp cray-mpich-binary-package.py spack/var/spack/repos/builtin/packages/cray-mpich-binary/package.py
