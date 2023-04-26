#!/bin/bash

rm -rf Makefile;
ln -s Makefile.cache Makefile
(cd compilers; rm -rf Makefile; ln -s Makefile.cache Makefile)
(cd packages; rm -rf Makefile; ln -s Makefile.cache Makefile)

