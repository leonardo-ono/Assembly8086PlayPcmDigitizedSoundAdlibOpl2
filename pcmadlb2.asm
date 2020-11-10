; Written by Leonardo Ono (ono.leo@gmail.com)
; 10 nov 2020
; Target OS: DOS
; use: nasm pcmadlb2.asm -o pcmadlb2.com -f bin
; 
; update: 14 feb 2020 - this program uses timer 0
;         10 nov 2020 - finally it works thanks to Jim Leonard.
;
; Reference: http://www.dcee.net/Files/Programm/Sound/adldigi.arj
;            Thanks to Jim Leonard for 'wait until 952h timer ticks' routine

		bits 16
		org 100h

start:
		
		call reset_all_registers

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

		; --- wait until 952h (2386) timer ticks have passed --
		; --- kindly provided by Jim Leonard --

                cli                             ;disable interrupts

                mov     al,0                    ;reprogram timer
                out     43h,al                  ;timer-0 count-mode
                in      al,40h                  ;read low-byte count
                mov     bl,al                   ;save in BL
                in      al,40h                  ;read high-byte count
                mov     bh,al                   ;save in BH
	.delay3:

                mov     al,0                    ;reprogram timer
                out     43h,al                  ;timer-0 count-mode
                in      al,40h                  ;read low-byte count
                mov     cl,al                   ;save in CL
                in      al,40h                  ;read high-byte count
                mov     ch,al                   ;save in CH
                neg     cx
                add	cx, bx                  ;compute clocks gone by
                cmp     cx,2386
                jb      .delay3

		sti

		; ---
		
		mov bl, 0b0h
		mov bh, 20h
		call write_adlib

		mov bl, 0a0h
		mov bh, 0h
		call write_adlib


		call start_fast_clock

		; --- start playback --- 
		
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
		
	.delay:
		call get_current_time
		cmp eax, [last_time]
		jbe .delay
		mov [last_time], eax
			

		mov ah, 1
		int 16h
		jnz .exit

		inc si
		cmp si, 51529
		jb .loop	

	.exit:
		call stop_fast_clock
		
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
			
; count = 1193180 / sampling_rate
; sampling_rate = 4000 cycles per second
; count = 1193180 / 4000 = 298 (in decimal) = 12a (in hex) 
start_fast_clock:
		cli
		mov al, 36h
		out 43h, al
		mov al, 2ah ; low 2ah
		out 40h, al
		mov al, 1h ; high 01h
		out 40h, al
		sti
		ret
		
stop_fast_clock:
		cli
		mov al, 36h
		out 43h, al
		mov al, 0
		out 40h, al
		mov al, 0
		out 40h, al
		sti
		ret		
		
; eax = get current time
get_current_time:
		push es
		mov ax, 0
		mov es, ax
		mov eax, [es:46ch]
		pop es
		ret
			
last_time dd 0			
sound_data:
		incbin "kingsv.wav" ; 51.529 bytes			
		