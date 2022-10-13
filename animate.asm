proc loadanimation
	mov cx, 43
	mov bx, 30h
	mov dx, 30h
	mov si, 0
	loadloop: ;open a bmp file of a picture and put it in a array
		push cx
		push bx
		push dx
		push si
		mov [filename4 + 10], bl
		mov [filename4 + 9], dl
		
		push offset filehandle3
		push offset filename4
		call OpenFile
		mov dx, 1078
		mov cx, 0
		mov al, 0
		mov ah, 42h
		mov bx, [filehandle3]
		int 21h
		
		
		mov cx, 22
		pop si
		readfromfileloop:
		push cx
		mov ah,3fh
		mov bx, [filehandle3]
		mov cx,20
		mov dx,	offset player
		add dx, si
		int 21h
		
		add si, 20
		pop cx
		loop readfromfileloop
		push si
		push offset filehandle3
		call CloseFile
		pop si
		pop dx 
		pop bx
		cmp bx, 39h
		jne continueload
		mov bx, 30h
		inc dx
		jmp continueloop2
		continueload:
		inc bx
		continueloop2:
		pop cx
	loop loadloop
ret
endp loadanimation