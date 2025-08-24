; bootbmp.asm — boot sector that shows a 320x200x256 BMP with correct colors
BITS 16
ORG 0x7C00

start:
    ; keep boot drive
    mov [BOOT_DRIVE], dl

    ; set safe segments/stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    cli
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; VGA mode 13h
    mov ax, 0x0013
    int 0x10

    ; load 128 sectors (covers a 65,078-byte BMP) from sector 2 → 1000:0000
    mov ax, 0x1000
    mov es, ax
    xor bx, bx
    mov ah, 0x02          ; BIOS read sectors (CHS; QEMU OK with large reads)
    mov al, 128
    xor ch, ch            ; cyl 0
    mov cl, 2             ; start at sector 2 (sector 1 = bootloader)
    xor dh, dh            ; head 0
    mov dl, [BOOT_DRIVE]  ; same drive we booted from
    int 0x13
    jc disk_error

    ; DS = 1000h points at BMP we just read
    mov ax, 0x1000
    mov ds, ax

    ; ----- set VGA DAC palette from BMP palette -----
    ; BMP palette starts at offset 54 (14-file hdr + 40-info hdr), 256 * (B,G,R,0)
    mov si, 54

    ; DAC write index = 0
    mov dx, 0x3C8
    xor al, al
    out dx, al
    inc dx                ; DX = 0x3C9 (DAC data port)

    mov cx, 256           ; 256 entries
pal_loop:
    ; order to DAC is R, G, B (6-bit each). BMP stores B,G,R,0 (8-bit each).
    mov al, [si+2]        ; R
    shr al, 2             ; 8-bit → 6-bit
    out dx, al
    mov al, [si+1]        ; G
    shr al, 2
    out dx, al
    mov al, [si]          ; B
    shr al, 2
    out dx, al
    add si, 4
    loop pal_loop
    ; ----- palette is set -----

    ; copy pixel data (bottom-up in BMP) to A000:0000 top-down
    ; pixel array offset for 8bpp BMP with 256-color palette is 54 + 1024 = 1078
    ; start at top row:
    mov si, 1078 + (200-1)*320

    mov ax, 0xA000
    mov es, ax
    xor di, di

    mov cx, 200           ; 200 rows
row_loop:
    push cx
    mov cx, 320           ; 320 pixels per row
    rep movsb             ; copies one row; SI += 320, DI += 320
    sub si, 640           ; step SI back to previous row (top→down copy)
    pop cx
    loop row_loop

hang: jmp hang

disk_error:
    hlt
    jmp disk_error

BOOT_DRIVE: db 0

times 510-($-$$) db 0
dw 0xAA55
