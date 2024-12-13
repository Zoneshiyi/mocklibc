.PHONY: auto hello lib clean

export APP_SIZE = 0
# export CC=riscv64-linux-musl-gcc
# export LD=riscv64-linux-musl-ld
# export RUSTFLAGS=-C linker=riscv64-linux-musl-ld

auto:
	$(call build_lib)
	$(call build_static_hello_auto)

custom:
	$(call build_lib)
	$(call build_static_hello_custom)

hello:
	$(call build_static_hello_auto)

lib:
	$(call build_lib)

clean:
	rm -rf ./hello.o ./hello ./hello.elf ./hello.dump
	rm -rf ./target


STATIC_FLAG = \
-nostdlib \
-nostartfiles \
-nodefaultlibs \
-ffreestanding \
-O0 \
-mcmodel=medany \
-Wl,--gc-sections \
-static \
-L./target/riscv64gc-unknown-linux-musl/release/ -lmocklibc


define build_static_hello_custom
	riscv64-linux-musl-gcc -c hello.c $(STATIC_FLAG) -o hello.o -no-pie
	riscv64-linux-musl-ld ./target/riscv64gc-unknown-linux-musl/release/libmocklibc.a hello.o -T./linker.ld -o hello
	$(call generate_bin)
endef

define build_static_hello_auto
	riscv64-linux-musl-gcc hello.c $(STATIC_FLAG) -o hello
	$(call generate_bin)
endef

define build_lib
	cargo build --release --target riscv64gc-unknown-linux-musl
endef

define generate_bin
	riscv64-linux-musl-readelf -a hello > hello.elf
	riscv64-linux-musl-objdump -d hello > hello.dump

	dd if=/dev/zero of=./apps.bin bs=1M count=32
	$(eval APP_SIZE = $(shell stat -c %s ./hello))
	$(call write_app_size,$(value APP_SIZE))

	dd if=./hello of=./apps.bin conv=notrunc bs=1 seek=8
	mkdir -p ../arceos/payload
	cp ./apps.bin ../arceos/payload/apps.bin
endef

define write_app_size
	printf "%016x" $(1) | tac -rs .. | xxd -r -p > ./temp.bin
	dd if=./temp.bin of=./apps.bin conv=notrunc bs=1 seek=0
	rm ./temp.bin
endef