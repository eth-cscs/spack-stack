#!/bin/bash

rm -rf Makefile;
ln -s Makefile.nocache Makefile
(cd compilers; rm -rf Makefile; ln -s Makefile.nocache Makefile)

