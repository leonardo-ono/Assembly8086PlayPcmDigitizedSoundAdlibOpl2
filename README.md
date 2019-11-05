# Assembly8086PlayPcmDigitizedSoundAdlibOpl2
Play Pcm Digitized Sound through Adlib OPL2 sound card.

target OS: DOS

assembler: nasm

executable: .COM

note:
for purpose of this test, i've implemented a very horrible delay that depends on the speed of your computer.

later you can try to modify this source to reprogram the timer so that the sound can be played at the correct sampling rate regardless of computer speed.

for now, please just adjust the cx value according to the speed of your computer
and assemble it again:

    ...
    ...
    ...
		mov bl, 0b0h
		mov bh, 2eh
    call write_adlib

		mov cx, 40000 ; <-- change this value according to the speed of your computer
	.delay3:
		nop
		loop .delay3
				
		mov bl, 0b0h
    ...
    ...
    ...


use: nasm pcmadlib.asm -o pcmadlib.com -f bin
