proc draw
	push bp
	mov bp, sp
	draw_playerlocX equ [bp + 4]
	draw_playerlocY equ [bp + 6]
	animationoffset equ [bp + 8]
	draw_cxOffest equ [bp - 2]
	draw_dxOffest equ [bp - 4]
	draw_rowsize equ [bp - 6]
	sub sp, 6
	
	mov ax, PIC_WIDTH		; calculate the offset on the file
	mov dx, 0
	mov bx, 4
	div bx
	mov ax, PIC_WIDTH
	add ax, dx		
	mov draw_rowsize, ax
	
	
	
	mov cx, PIC_HIGHT
	sub cx, draw_playerlocY
	;sub cx, 200
	mov ax, draw_rowsize
	mul cx
	mov cx, dx
	mov dx, ax
	add dx, draw_playerlocX
	jnc addpallet4
	inc cx
	
	addpallet4:
	add dx, 1078
	jnc movecursor4
	inc cx
	movecursor4:
	mov draw_cxOffest, cx
	mov draw_dxOffest, dx
	
	mov cx, 22
	mov si, 0
	copyloop:		;copy the section that im drawing on from the file to an array
		push cx
		
		mov dx, draw_dxOffest
		mov cx, draw_cxOffest
		mov al, 0
		mov ah, 42h 
		mov bx, [filehandle]
		int 21h 	;move to offset in file
		
		
		mov ah,3fh	;
		mov bx, [filehandle]
		mov cx, 20
		mov dx, offset savemap
		add dx, si
		int 21h		;copy from file to savemap(array)
		
		mov dx, draw_dxOffest
		mov cx, draw_cxOffest
		add dx, draw_rowsize
		jnc continuecopy
		inc cx
		continuecopy:
		mov draw_cxOffest, cx
		mov draw_dxOffest, dx
		
		add si, 20
		pop cx
	loop copyloop	;loop untill cx = 0
	
	
	mov cx, PIC_HIGHT		;calculate the offset again
	sub cx, draw_playerlocY
	;sub cx, 200
	mov ax, draw_rowsize
	mul cx
	mov cx, dx
	mov dx, ax
	add dx, draw_playerlocX
	jnc addpallet5
	inc cx
	
	addpallet5:
	add dx, 1078
	jnc movecursor5
	inc cx
	movecursor5:
	mov draw_cxOffest, cx
	mov draw_dxOffest, dx
	
	
	
	mov cx, 22
	mov si, animationoffset
	drawloop:	;draw a frame to the screen
		push cx
		push si
		
		mov dx, draw_dxOffest
		mov cx, draw_cxOffest
		mov al, 0
		mov ah, 42h
		mov bx, [filehandle]
		int 21h		;move to offset
		
		pop si
		mov cx, 20
		checkwhite:		;ignore the white color on the frame
		push cx
			cmp [player + si], 0h
			jbe continueloop3
				mov ah, 40h
				mov bx, [filehandle]
				mov cx, 1
				mov dx, offset player
				add dx, si
				int 21h
				mov dx, draw_dxOffest
				add dx, 1
				mov draw_dxOffest, dx
				jmp continueloop4
			continueloop3:
			mov dx, draw_dxOffest
			add dx, 1
			mov cx, draw_cxOffest
			mov draw_dxOffest, dx
			mov draw_cxOffest, cx
			mov al, 0
			mov ah, 42h
			mov bx, [filehandle]
			int 21h		;copy to pic
			
			
			
			continueloop4:
			inc si
			pop cx
		loop checkwhite
		
		
		; mov ah, 40h
		; mov bx, [filehandle]
		; mov cx, 20
		; mov dx, offset player
		; add dx, si
		; int 21h
		
		
		
		
		; AH = 40h
		; BX = file handle
		; CX = number of bytes to write, a zero value truncates/extends
			 ; the file to the current file position
		; DS:DX = pointer to write buffer
		mov dx, draw_dxOffest
		mov cx, draw_cxOffest
		add dx, draw_rowsize
		jnc continuedraw
		inc cx
		continuedraw:
		sub dx, 20
		mov draw_cxOffest, cx
		mov draw_dxOffest, dx
		
		; pop si
		; add si, 20
		; mov di, 0
		pop cx
	loop drawloop
	
	push 0
	push [filehandle]
	call CopyBitmap
	
	mov cx, PIC_HIGHT		;calculate offset again
	sub cx, draw_playerlocY
	;sub cx, 200
	mov ax, draw_rowsize
	mul cx
	mov cx, dx
	mov dx, ax
	add dx, draw_playerlocX
	jnc addpallet3
	inc cx
	
	addpallet3:
	add dx, 1078
	jnc movecursor3
	inc cx
	movecursor3:
	mov draw_cxOffest, cx
	mov draw_dxOffest, dx
	
	
	
	mov cx, 22
	mov si, 0
	drawcopyloop:		;copy the part i saved back to the pic
		push cx
		
		mov dx, draw_dxOffest
		mov cx, draw_cxOffest
		mov al, 0
		mov ah, 42h
		mov bx, [filehandle]
		int 21h		;move to offset
		
		mov ah, 40h
		mov bx, [filehandle]
		mov cx, 20
		mov dx, offset savemap
		add dx, si
		int 21h		;copy to pic
		; AH = 40h
		; BX = file handle
		; CX = number of bytes to write, a zero value truncates/extends
			 ; the file to the current file position
		; DS:DX = pointer to write buffer
		mov dx, draw_dxOffest
		mov cx, draw_cxOffest
		add dx, draw_rowsize
		jnc continuedrawcopy
		inc cx
		continuedrawcopy:
		; sub dx, 11
		mov draw_cxOffest, cx
		mov draw_dxOffest, dx
		
		add si, 20
		pop cx
	loop drawcopyloop
	
	mov sp, bp
	pop bp
	
ret 6
endp draw

proc CopyBitmap
	push bp
	mov bp, sp
	sub sp, 6
	
	CopyBitmap_Filehandle equ [bp + 4]
	CopyBitmap_transparentColor equ [bp + 6]
	CopyBitmap_cxOffest equ [bp - 2]
	CopyBitmap_dxOffest equ [bp - 4]
	CopyBitmap_rowsize equ [bp - 6]
	; BMP graphics are saved upside-down .
	; Read the graphic line by line (200 lines in VGA format),
	; displaying the lines from bottom to top.
	
	; calculate row size with pedding, row size needs to be divisible by 4
	mov ax, PIC_WIDTH		;calculate the padding at the end of the pic
	mov dx, 0
	mov bx, 4
	div bx
	mov ax, PIC_WIDTH
	add ax, dx
	mov CopyBitmap_rowsize, ax
	
	
	mov cx, PIC_HIGHT		;calculate the offset with [offsetY] and [offsetx]
	sub cx, [offsetY]
	sub cx, 200
	mov ax, CopyBitmap_rowsize
	mul cx
	mov cx, dx
	mov dx, ax
	add dx, [offsetX]
	jnc addpallet
	inc cx
	
	addpallet:	;add the pallete
	add dx, 1078
	jnc movecursor
	inc cx
	movecursor:
	mov CopyBitmap_cxOffest, cx
	mov CopyBitmap_dxOffest, dx
	mov al, 0
	mov ah, 42h
	mov bx, CopyBitmap_Filehandle;[filehandle]
	int 21h		;move to offset
	
	mov ax, 0A000h
	mov es, ax
	mov cx, 200 ; PIC_HIGHT
	mov ax, 320
	mov di, cx
	add di, [startY]
	mul di
	mov di, ax
	add di, [startX]
	mov cx, 200 ; PIC_HIGHT
	PrintBMPLoop :
		push cx
		
		; Read one line
		mov ah,3fh
		mov cx, 320 ; PIC_WIDTH
		mov dx, offset ScrLine
		mov bx, CopyBitmap_Filehandle;[filehandle]
		int 21h		;copy a line of the pic to an array
		; Copy one line into video memory
		cld ; Clear direction flag, for movsb
		mov cx, 320 ; PIC_WIDTH
		mov si,offset ScrLine
		
		; rep movsb
		cmp CopyBitmap_transparentColor, 0	;check for transperancy if 0 no transperancy, any other number, the color of that number is transparent
		jne copybitmaploop
		rep movsb
		jmp continuecopyBitMap
		copybitmaploop:
		je skipcheckcolor
		mov bl, [byte ptr si]
		cmp bl, CopyBitmap_transparentColor
		je skipcopybitmap
		skipcheckcolor:
		mov al, [byte ptr si]
		mov [es:di], al
		skipcopybitmap:
		inc si
		inc di
		loop copybitmaploop
		
		continuecopyBitMap:
		;rep movsb ; Copy line to the screen
		 ;rep movsb is same as the following code :
		 ;mov es:di, ds:si
		 ;inc si
		 ;inc di
		 ;dec cx
		;loop until cx=0
		sub di, 640 ; 320 + width
		;sub di, PIC_WIDTH
		
		mov cx, CopyBitmap_cxOffest
		mov dx, CopyBitmap_dxOffest
		add dx, CopyBitmap_rowsize
		jnc continueloop
		inc cx
		
	continueloop:
		
		mov CopyBitmap_cxOffest, cx
		mov CopyBitmap_dxOffest, dx
		mov al, 0
		mov ah, 42h
		mov bx, CopyBitmap_Filehandle;[filehandle]
		int 21h
		pop cx
	loop PrintBMPLoop
	mov sp, bp
	pop bp
		ret	4	
endp CopyBitmap