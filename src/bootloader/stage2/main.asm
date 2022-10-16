; our os loc


org 0x7C00
bits 16



%define ENDL 0x0D, 0x0A

; where shoulf we start
start:
    jmp main


; where we print our strings
puts:
    ; pushing registers
    push si
    push ax
    push bx

.loop:
    lodsb               
    or al, al            
    jz .done

    mov ah, 0x0E        ; call bios interrupt
    mov bh, 0 
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si    
    ret
    

main:
    mov ax, 0           
    mov ds, ax
    mov es, ax
    
    
    mov ss, ax
    mov sp, 0x7C00      

    ; print hello world message
    mov si, msg_hello
    call puts

    hlt

.halt
    jmp .halt


; hworld var
msg_hello: db 'Hello world!', ENDL, 0

; times func
times 510-($-$$) db 0
dw 0AA55h