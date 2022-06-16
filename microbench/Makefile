.PHONY: all bench clean

TAR=tar
CURL=curl
GCCS=/usr/bin/gcc # put your gccs here

all: bench

main.c:
	echo '#include <stdio.h>' > $@
	echo 'int main(){return 3;}' >> $@

hyperfine:
	$(CURL) -sfL https://github.com/sharkdp/hyperfine/releases/download/v1.13.0/hyperfine-v1.13.0-x86_64-unknown-linux-musl.tar.gz | $(TAR) --strip-components=1 -xzf - --no-anchored hyperfine

bench: main.c hyperfine
	./hyperfine --warmup 3 --shell=none $(foreach GCC, $(GCCS), '$(GCC) -c main.c')

clean:
	rm hyperfine main.c main.o

