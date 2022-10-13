proc openingMusic

	startsong:
	
	
	; push cx
	
	mov al, 0B6h		;access permission
	out 43h, al
	
	cmp [noteduration], 0		;check if the sound continues or not 
	jne playsound
	
	;call readfromfile
	cmp [musiccounter], 10		;check for spacial notes
	je  longsound
	cmp [musiccounter], 22
	je  longsound
	cmp [musiccounter], 35
	je longsound
	jmp shortsound
	
	
	longsound:
	mov [noteduration], 06h		;move the duration of the note
	jmp playsound
	
	
	shortsound:
	mov [noteduration], 01h
	
	playsound:
	
	mov bx, 0
	mov bl, [musiccounter]
	mov ax, 2
	mul bx
	mov bx, ax
	mov ax, [openingmusicArray + bx]		;play the sound
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; sending upper byte
	
ret
endp openingMusic

proc mainmusic
	startsong2:
	
	
	; push cx
	
	mov al, 0B6h
	out 43h, al
	
	cmp [isjumping], TRUE
	jne continueMusic
	mov ax, [jumpsound]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; sending upper byte
	ret
	continueMusic:
	
	
	cmp [noteduration], 0
	jne playsound2
	
	;call readfromfile
	cmp [musiccounter], 16
	jbe  shortsound2
	cmp [musiccounter], 44
	jbe  normalsound
	jmp longsound2
	
	
	longsound2:
	mov [noteduration], 014h
	jmp playsound2
	
	normalsound:
	mov [noteduration], 019h
	jmp playsound2
	
	shortsound2:
	mov [noteduration], 02h
	jmp playsound2

	
	playsound2:
	
	mov bx, 0
	mov bl, [musiccounter]
	mov ax, 2
	mul bx
	mov bx, ax
	mov ax, [musicarray + bx]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; sending upper byte
	
ret
endp mainmusic

proc endmusic
	mov al, 0B6h
	out 43h, al
	
	
	cmp [noteduration], 0
	jne playsound3
	
	cmp [musiccounter], 2
	je  longsound3
	cmp [musiccounter], 7
	je  longsound3
	cmp [musiccounter], 12
	je longsound3
	cmp [musiccounter], 19
	je longsound3
	jmp shortsound3
	
	
	longsound3:
	mov [noteduration], 06h
	jmp playsound3
	
	
	shortsound3:
	mov [noteduration], 03h
	jmp playsound3
	
	playsound3:
	
	mov bx, 0
	mov bl, [musiccounter]
	mov ax, 2
	mul bx
	mov bx, ax
	mov ax, [endingmusicArray + bx]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; sending upper byte
	
ret
endp endmusic

proc losemusic
	mov al, 0B6h
	out 43h, al
	
	
	cmp [noteduration], 0
	jne playsound4
	
	
	
	
	shortsound4:
	mov [noteduration], 09h
	jmp playsound4

	
	playsound4:
	
	mov bx, 0
	mov bl, [musiccounter]
	mov ax, 2
	mul bx
	mov bx, ax
	mov ax, [losingmusicArray + bx]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; sending upper byte
	
ret
endp losemusic