#! /usr/bin/bash

recipe_path="$(pwd)/recipe"
cp ${recipe_path}/Make.user .

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

mkdir -p spack/var/spack/repos/builtin/packages/cray-mpich-binary
cp cray-mpich-binary-package.py spack/var/spack/repos/builtin/packages/cray-mpich-binary/package.py
