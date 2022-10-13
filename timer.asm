proc timer
	cmp [timestring + secondone], 39h	;check for seconds
	je addtensec
		inc [timestring + secondone]
		jmp printtime
	addtensec:
	cmp [timestring + secondten], 35h	;check for tens
	je addonemin
		mov [timestring + secondone], 30h	
		inc [timestring + secondten]
		jmp printtime
	addonemin:
	cmp [timestring + minuteone], 39h	;check for minutes
	je addtemmin
		mov  [timestring + secondone], 30h
		mov  [timestring + secondten], 30h
		inc	 [timestring + minuteone]
		jmp printtime
	addtemmin:
		mov  [timestring + secondone], 30h
		mov  [timestring + secondten], 30h
		mov  [timestring + minuteone], 30h
		inc	 [timestring + minuteten]
	printtime:
	mov cx, 11
	mov si, 0
	
	cmp [seccounter], maxscore
	jae @printloop
		add [seccounter], 10
	@printloop:		;print the time on screen 
	push cx
		mov dx, si
		mov bx, 0
		mov ah, 2
		int 10h		;set the cursor position to the start of the screen
		
		mov ah, 9h
		mov bl, 00B1h
		mov al, [timestring + si]
		mov bh, 2
		mov cx, 1
		int 10h		;print a letter in a spacial color
	inc si
	pop cx
	loop @printloop
ret
endp timer