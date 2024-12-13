#![no_std]
#![no_main]

#[allow(unused)]
extern "C" {
    fn main();
}

mod abi;
use abi::{ABI_TABLE_ADDR, init_abis};

#[no_mangle]
unsafe extern "C" fn _start() {
    core::arch::asm!("
        mv      {abi_table}, a7",
        abi_table = out(reg) ABI_TABLE_ADDR,
    );
    init_abis();

    main();
    return;
}

use core::panic::PanicInfo;
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
