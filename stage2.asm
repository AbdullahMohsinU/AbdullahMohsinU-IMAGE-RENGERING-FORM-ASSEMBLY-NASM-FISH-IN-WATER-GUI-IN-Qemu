org 0x0000

start:
    ; set 320x200x256 VGA mode
    mov ax, 0x13
    int 0x10

    ; set ES to VGA segment
    mov ax, 0xA000
    mov es, ax
    xor di, di

    ; DS points to where stage2 is loaded
    mov ax, cs
    mov ds, ax

    mov si, imgdata
    mov cx, 320*200    ; 64,000 pixels
.copy:
    lodsb
    stosb
    loop .copy

.hang:
    jmp .hang

imgdata:
