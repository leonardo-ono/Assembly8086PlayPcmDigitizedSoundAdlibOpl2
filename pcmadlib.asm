; Written by Leonardo Ono (ono.leo@gmail.com)
; 11/05/2019
; Reference: http://www.dcee.net/Files/Programm/Sound/adldigi.arj

		bits 16
		org 100h

start:

		mov ah, 0eh
		mov al, 'A'
		int 10h
		
		;call reset_all_registers

		; bl = register
		; bh = value
		mov bl, 20h
		mov bh, 21h
		call write_adlib

		mov bl, 60h
		mov bh, 0f0h
		call write_adlib

		mov bl, 80h
		mov bh, 0f0h
		call write_adlib

		mov bl, 0c0h
		mov bh, 01h
		call write_adlib

		mov bl, 0e0h
		mov bh, 0
		call write_adlib
		
		mov bl, 43h
		mov bh, 3fh
		call write_adlib

		mov bl, 0b0h
		mov bh, 1h
		call write_adlib

		mov bl, 0a0h
		mov bh, 8fh
		call write_adlib

		mov bl, 0b0h
		mov bh, 2eh
		call write_adlib

		mov cx, 40000 ; <-- change this value according to the speed of your computer
	.delay3:
		nop
		loop .delay3
				
		mov bl, 0b0h
		mov bh, 20h
		call write_adlib

		mov bl, 0a0h
		mov bh, 0h
		call write_adlib
		
		
		mov si, 0

	.loop:

		; send byte audio sample
		mov bh, [sound_data + si]
		mov bl, 255
		sub bl, bh ; lowest value has the highest volume
		mov bh, bl
		shr bh, 2 ; convert to 6-bit sample

		
		; bl = register
		; bh = value
		mov bl, 40h
		; mov bh, -- -> bh already has the 6-bit sample
		call write_adlib

		mov cx, 10000 ; <-- change this value according to the speed of your computer
	.delay:
		nop
		loop .delay

		mov ah, 1
		int 16h
		jnz .exit

		inc si
		cmp si, 51529
		jb .loop	

	.exit:
		mov ax, 4c00h
		int 21h

reset_all_registers:
		mov bl, 0h
		mov bh, 0
	.next_register:
		; bl = register
		; bh = value
		call write_adlib
		inc bl
		cmp bl, 0f5h
		jbe .next_register
	.end:
		ret
		
; bl = register
; bh = value
write_adlib:
		pusha
		
		mov dx, 388h
		mov al, bl
		out dx, al

		mov cx, 6
	.delay_1:
		in al, dx
		loop .delay_1

		mov dx, 389h

		mov al, bh
		out dx, al

		mov dx, 388h

		mov cx, 35
	.delay_2:
		in al, dx
		loop .delay_2
		
		popa
		ret
			
sound_data:
		incbin "kingsv.wav" ; 51.529 bytes			
		