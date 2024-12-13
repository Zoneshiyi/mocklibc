BASE_ADDRESS = 0xffffffc080100000;

ENTRY(_start)

SECTIONS
{
    . = BASE_ADDRESS;
    .text : ALIGN(8) {
        *(.text._start)
        *(.text)
    }
}