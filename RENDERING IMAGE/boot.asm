; boot.asm - boot sector + raw image loader
BITS 16
ORG 0x7C00

start:
    ; set video mode 13h (320x200x256 colors)
    mov ax, 0x0013
    int 0x10

    ; load 128 sectors (128*512 = 64KB)
    mov ax, 0x1000      ; ES = 1000h (buffer segment)
    mov es, ax
    xor bx, bx          ; ES:BX = 1000:0000
    mov ah, 0x02        ; BIOS read sectors
    mov al, 128         ; number of sectors to read
    mov ch, 0           ; cylinder 0
    mov cl, 2           ; sector 2 (sector 1 = bootloader)
    mov dh, 0           ; head 0
    mov dl, 0x00        ; drive 0 (floppy for qemu -fda)
    int 0x13
    jc disk_error       ; if error, halt

    ; copy buffer → VGA video memory
    mov ax, 0xA000
    mov es, ax
    xor di, di          ; ES:DI = A000:0000
    mov ax, 0x1000
    mov ds, ax
    xor si, si
    mov cx, 320*200     ; 64,000 bytes
    rep movsb

hang:
    jmp hang

disk_error:
    hlt
    jmp disk_error

; pad boot sector to 512 bytes
times 510-($-$$) db 0
dw 0xAA55
