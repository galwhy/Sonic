proc readfromfile		;read from file the number of bytes i want
	push bp
	mov bp, sp
	numofbytes equ [bp + 4]
	arrayoffset equ [bp + 6]

	mov ah,3fh
	mov bx, [filehandle4]
	mov cx, numofbytes
	mov dx,	arrayoffset
	int 21h
	
	mov sp, bp
	pop bp
	ret 4
endp readfromfile

proc OpenFile		;open a file
	push bp
	mov bp, sp
	openfile_filename equ [bp + 4]
	openfile_filehandle equ [bp + 6]
	; Open file
	mov ah, 3Dh
	mov al, 2
	mov dx, openfile_filename ;offset filename
	int 21h
	jc openerror
	mov si, openfile_filehandle
	mov [si], ax
	mov sp, bp
	pop bp
	ret 4
	openerror :
		mov dx, offset ErrorMsg
		mov ah, 9h
		int 21h
	mov sp, bp
	pop bp
	ret 4
endp OpenFile

proc CloseFile		;close a file
	push bp
	mov bp, sp
	closefile_filehandle equ [bp + 4]
    push ax
    push bx
    mov ah, 3Eh
	mov si, closefile_filehandle
    mov bx, [si]
    int 21h
    pop bx
    pop ax
	mov sp, bp
	pop bp
    ret 2
endp CloseFile

proc ReadHeader		;read the header of the bmp
	; Read BMP file header, 54 bytes
	push bp
	mov bp, sp
	readheader_header equ [bp + 4]
	readheader_filehandle equ [bp + 6]
	mov ah,3fh
	mov bx, readheader_filehandle
	mov cx,54
	mov dx,readheader_header
	int 21h
	mov sp, bp
	pop bp
	ret 4
endp ReadHeader

proc ReadPalette		;read the palette of the bmp
	; Read BMP file color palette, 256 colors * 4 bytes (400h)
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp ReadPalette

proc CopyPal		;copy the palette to the memory of the computer
	; Copy the colors palette to the video memory
	; The number of the first color should be sent to port 3C8h
	; The palette is sent to port 3C9h
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0
	; Copy starting color to port 3C8h
	out dx,al
	; Copy palette itself to port 3C9h
	inc dx
	PalLoop:
		; Note: Colors in a BMP file are saved as BGR values rather than RGB .
		mov al,[si+2] ; Get red value .
		shr al,2 ; Max. is 255, but video palette maximal
		; value is 63. Therefore dividing by 4.
		out dx,al ; Send it .
		mov al,[si+1] ; Get green value .
		shr al,2
		out dx,al ; Send it .
		mov al,[si] ; Get blue value .
		shr al,2
		out dx,al ; Send it .
		add si,4 ; Point to next color .
		; (There is a null chr. after every color.)
	loop PalLoop
	ret
endp CopyPal

