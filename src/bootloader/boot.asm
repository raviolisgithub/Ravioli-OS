; our os loc
org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

; fat fs header
jmp short start
nop


; these 8 bytes can be set to anything, but mswin4.1 will do
bdb_oem:                    db 'MSWIN4.1'
; next field is bytes per sector
bdb_bytes_per_sector:       dw 512
; sectors per cluster is 1
bdb_sectors_per_cluster:    db 1
; reserved sectors
bdb_reserved_sectors:       dw 1
; number of fat file allocation tables (2)
bdb_fat_count:              db 2
; number of directory entries
bdb_dir_entries_count:      dw 0E0h
; total sectors
bdb_total_sectors:          dw 2800 ; (2880 * 512 = 1.44MB)
; indicates media descriptor type
bdb_media_descriptior_type: db 0F0h ; "0F0h" or "F0" = 3.5" floppy disk
; sectors per fat (only for fat16 or fat12)
bdb_sectors_per_fat:        dw 9 ; 9 sectors per fat
; sectors per track
bdb_sectors_per_track:      dw 18 ; 18 sectors per track
; head count (2)
bdb_heads:                  dw 2
; hidden sectors
bdb_hidden_sectors:         dd 0
; large sectors
bdb_large_sector_count:     dd 0

; extended boot record
ebr_drive_number:           db 0 ; useless value, 0x00
                            db 0 ; reserved
ehr_signature:              db 29h
ehr_volume_id:              db 12h, 34, 56h, 78h ; these are serial numbers
ehr_volume_label:           db 'RAVIOLI  OS' ; 11 bytes
ehr_system_id:              db 'FAT12   ' ; 8 bytes

; where we should start
start:
    ; jumping to main
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

    mov [ebr_drive_number], dl

    mov ax, 1
    mov cl, 1
    mov bx, 0x7E00   

    ; print hello world message
    mov si, msg_hello
    call puts

    hlt

; error 
floppy_error:
    mov si, msg_read_failed
    call puts
    jmp wait_key_and_reboot
    hlt

wait_key_and_reboot:
    mov ah, 0
    int 16h
    jmp 0FFFFh:0


.halt
    cli
    hlt

; disk routines
; converting lba address to chs address (research if u wanna know what these are)
lba_to_chs:

    ; push ax & dx to stack
    push ax
    push dx

    xor dx, dx ; dx = 0
    div word [bdb_sectors_per_track] ; ax = LBA / SectorsPerTrack
                                     ; dx = LBA % SectorsPerTrack

    inc dx ; incrementing dx = LBA % SectorsPerTrack + 1 (like sector)
    mov cx, dx ; cx = sector

    xor dx, dx ; remember dx = 0
    div word [bdb_heads] ; Formula of ax divided by Heads = cylinder
                         ; Formula of dx % Heads = head

    ; CX = ---CH--- ---CL---
    mov dh, dl ; dh = head
    mov ch, al ; ch = cylinder (lower 8 bits)
    shl ah, 6
    or cl, ah ; higher 2 bits of cylinder in cl

    ; then we pop ax and mov dl, al
    pop ax
    mov dl, al
    pop ax 
    ret

; reads sectors from disk
; parameters:
; ax: LBA Address 
; CL will be number of sectors to read
; dl will be the drive number
disk_read:

    push ax
    push bx
    push cx
    push di

    push cx ; temp. saving cl
    call lba_to_chs ; computing chs
    pop ax ; al = cl

    mov ah, 02h
    mov di, 3 ; retry count for floppy disks

.retry:
    pusha ; save all registers
    stc ; Sets carry flag as some bios dont set it.
    int 13h
    jnc .done
    ; disk reading failed
    popa
    call disk_reset

    dec di
    test di, di
    jnz .retry

.fail:
    jmp floppy_error

.done:
    push di
    push dx
    push cx
    push bx
    push ax
    ret

; reseting disk controll
disk_reset:
    pusha
    mov ah, 0
    stc
    int 13h
    jc floppy_error
    popa
    ret

; hworld var
msg_hello:          db 'Hello world!', ENDL, 0
; msg read failed
msg_read_failed:    db 'Failed to read the disk.', ENDL, 0

; times func
times 510-($-$$) db 0
dw 0AA55h