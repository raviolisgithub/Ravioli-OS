; bx is a preserved register
; i wonder where will our os be...
; oh, the org func!
[org 0x7c00]

; these codes like 0x0aa or 0x55 or 0x0e are hexdecimals which have c: os dir

; now variables..
; btw mov means it just moves something to somewhere
; this setup will print "Hello world!"
mov ah, 0x0e
mov bx, hworld

; how we print our string
printString:
    ; pointer to bx
    mov al, [bx]
    ; cmp is for comparing
    cmp al, 0
    ; if equal, je will do jump
    je end
    ; ofc int
    int 0x10
    ; incrementing bx register
    inc bx
    ; jumppppppppppppp
    jmp printString
; idk but the end?
end:
jmp $

; ofc, our variable
hworld:
    ; db of the glorius, HELLO WORLD!
    db "Hello world!", 0

; times is where it repeats an action, db means definite byte
times 510-($-$$) db 0
db 0x55, 0xaa