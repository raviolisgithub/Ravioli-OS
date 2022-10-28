bits 16

section _TEXT class=CODE

global _x86_Video_WriteCharTeletype
_x86_Video_WriteCharTeletype:
    ; making a new call frame.
    push bp
    mov bp, sp

    push bx

    mov ah, 0Eh
    mov al, [bp + 4]
    mov bh, [bp + 6]

    int 10h

    ; pushes bx of the stack (in english, restores bx)
    pop bx

    ; restore old call frame by moving bp to sp
    mov sp, bp
    ; pops bp of the stack and helps in restoring old call frame
    pop bp
    ret

