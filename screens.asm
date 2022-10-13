proc openingscreen

	mov dx, 0
	openloop:
	push dx

	
    add dx, 30h
    mov [filename2 + 12], dl
	


	push offset filehandle
	push offset filename2
	call OpenFile
	push [filehandle]		;open and read from file
	push offset header
	call ReadHeader
	call ReadPalette
	call CopyPal
	
	call openingMusic		;play a sound
	
	push 0
	push [filehandle]
	call CopyBitmap			;show the file on the screen
	push offset filehandle
	call CloseFile
	

	
    mov cx, 1
    mov dx, 0C000h			;delay so it wouldn't be to fast
    mov ah, 86h
    int 15h
	
	dec [noteduration]		;check if the sound is over and move to the next sound
	cmp [noteduration], 0
	je nextSound
	jmp continuegif
	nextSound:
	inc [musiccounter]
	
	continuegif:
	
	cmp [musiccounter], openingmusicArrayLENGHT
	jne continuegif2
	mov [musiccounter], 0
	continuegif2:
	


	pop dx
	cmp dl, 9
	jne continue
	dec dl
	
	mov ah, 1
    int 16h
    jne exitloop
	
	jmp openloop
	continue:
	inc dl
	
	mov ah, 1
    int 16h
    jne exitloop
	
	jmp openloop
	
	exitloop:

ret
endp openingscreen

proc startscreen 
	mov dx, 0
	mov [filename9 + 12],"0"
	mov [filename9 + 11],"0"
	mov [musiccounter], 0
	mov [noteduration], 0
	mov [offsetX], 0
	mov [offsetY], 0
	
	@startloop:

	push dx
	
	cmp dx, 0Fh
	jae @musicjmp
	cmp dx, 09h 
	je @checkten
	inc dx
    inc [filename9 + 12]
	jmp printjmp
	@checkten:
	mov dh, 30h
	mov [filename9 + 12], dh
	inc dx
	inc [filename9 + 11]

	
   
	
	
	
	printjmp:

	push offset filehandle5
	push offset filename9
	call OpenFile
	push [filehandle5]
	push offset header
	call ReadHeader
	call ReadPalette
	call CopyPal
	
	@musicjmp:
	
	call mainmusic
	
	push 0
	push [filehandle5]
	call CopyBitmap
	push offset filehandle5
	call CloseFile
	
	
	
    mov cx, 0
    mov dx, 0B800h
    mov ah, 86h
    int 15h
	
	
	
	
	dec [noteduration]
	cmp [noteduration], 0
	je @@nextSound
	jmp @@continuegif
	@@nextSound:
	inc [musiccounter]
	
	@@continuegif:
	
	cmp [musiccounter], 16
	jne @@continuegif2
	
	pop dx
	jmp @exitloopjmp
	@@continuegif2:
	
	pop dx
	inc dl
	jmp @startloop
	
	@exitloopjmp:
	
ret
endp startscreen

proc endscreen 
	

	mov dx, 0
	mov [musiccounter], 0
	mov [noteduration], 0

	@endloop:

	push dx
	push [offsetX]
	push [offsetY]
	
	cmp dx, 0Ah 
	jnae continuend
	jmp musicjmp
	continuend:
	add dx, 30h
    mov [filename7 + 10], dl
	
	push offset filehandle
	push offset filename
	call OpenFile
	push [filehandle]
	push offset header
	call ReadHeader
	call ReadPalette
	call CopyPal
	
	
	
	push 0
	push [filehandle]
	call CopyBitmap
	push offset filehandle
	call CloseFile
	
	
	
	mov [offsetX],0
	mov [offsetY], 0

	
   

	push offset filehandle5
	push offset filename7
	call OpenFile
	push [filehandle5]
	push offset header
	call ReadHeader
	call ReadPalette
	call CopyPal
	
	musicjmp:
	
	call endmusic
	
	push 0FFh
	push [filehandle5]
	call CopyBitmap
	push offset filehandle5
	call CloseFile
	
	
	
    mov cx, 0
    mov dx, 0E000h
    mov ah, 86h
    int 15h
	
	
	
	
	dec [noteduration]
	cmp [noteduration], 0
	je @nextSound
	jmp @continuegif
	@nextSound:
	inc [musiccounter]
	
	@continuegif:
	
	cmp [musiccounter], endingmusicArrayLENGHT
	jne @continuegif2
	
	pop [offsetY]
	pop [offsetx]
	pop dx
	jmp @exitloop
	@continuegif2:
	
	pop [offsetY]
	pop [offsetx]
	
	pop dx
	inc dl
	jmp @endloop
	
	@exitloop:
	
ret
endp endscreen

proc losescreen 
	

	mov dx, 0
	mov [filename10 + 10],"0"
	mov [filename10 + 11],"0"
	mov [musiccounter], 0
	mov [noteduration], 0
	mov [offsetX], 0
	mov [offsetY], 0

	@@startloop:

	push dx
	
	cmp dl, 9
	jae openfilejmp

    inc [filename10 + 11]


	

	
	openfilejmp:

	push offset filehandle5
	push offset filename10
	call OpenFile
	push [filehandle5]
	push offset header
	call ReadHeader
	call ReadPalette
	call CopyPal
	

	
	call losemusic

	
	push 0
	push [filehandle5]
	call CopyBitmap
	push offset filehandle5
	call CloseFile
	
	
	
    mov cx, 0
    mov dx, 0B800h
    mov ah, 86h
    int 15h
	
	
	
	
	dec [noteduration]
	cmp [noteduration], 0
	je @@@nextSound
	jmp @@@continuegif
	@@@nextSound:
	cmp [musiccounter], 4
	jae @@@continuegif
	inc [musiccounter]
	
	@@@continuegif:
	

	call checkKey
	cmp ah, 1ch 
	je @@exitloopjmp
	
	pop dx
	inc dx

	jmp @@startloop
	
	@@exitloopjmp:
	pop dx

ret
endp losescreen