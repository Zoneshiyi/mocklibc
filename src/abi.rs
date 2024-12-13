const SYS_HELLO: usize = 1;
const SYS_PUTCHAR: usize = 2;
const SYS_EXIT: usize = 3;
pub static mut ABI_TABLE_ADDR: usize = 0;
static mut ABI_TABLE: [usize; 16] = [0; 16];

pub unsafe fn init_abis(){
    ABI_TABLE[SYS_HELLO] = *((ABI_TABLE_ADDR + SYS_HELLO * 8) as *const usize);
    ABI_TABLE[SYS_PUTCHAR] = *((ABI_TABLE_ADDR + SYS_PUTCHAR * 8) as *const usize);
    ABI_TABLE[SYS_EXIT] = *((ABI_TABLE_ADDR + SYS_EXIT * 8) as *const usize);
}

#[no_mangle]
extern "C" fn hello() {
    unsafe {
        let abi_hello: fn();
        abi_hello = core::mem::transmute(ABI_TABLE[SYS_HELLO]);
        abi_hello();
    }
}

#[no_mangle]
extern "C" fn putchar(c: usize){
    unsafe {
        let abi_putchar: fn(usize);
        abi_putchar = core::mem::transmute(ABI_TABLE[SYS_PUTCHAR]);
        abi_putchar(c);
    }
}

#[no_mangle]
extern "C" fn exit(){
    unsafe {
        let abi_exit: fn();
        abi_exit = core::mem::transmute(ABI_TABLE[SYS_EXIT]);
        abi_exit();
    }
}

#[no_mangle]
extern "C" fn puts(s: *const u8){
    let mut i = 0;
    unsafe {
        while *s.offset(i) != 0 {
            putchar(*s.offset(i) as usize);
            i += 1;
        }
    }
}