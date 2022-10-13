proc checkcol
	push bp
	mov bp, sp
	checkcol_playerlocX equ [bp + 4]
	checkcol_playerlocY equ [bp + 6]
	checkcol_cxOffest equ [bp - 2]
	checkcol_dxOffest equ [bp - 4]
	checkcol_rowsize equ [bp - 6]
	sub sp, 6
	
	
	
	mov ax, PIC_WIDTH		;calculate the offset in the pic
	mov dx, 0
	mov bx, 4
	div bx
	mov ax, PIC_WIDTH
	add ax, dx
	mov CopyBitmap_rowsize, ax
	
	
	mov cx, PIC_HIGHT
	sub cx, checkcol_playerlocY
	;sub cx, 200
	mov ax, CopyBitmap_rowsize
	mul cx
	mov cx, dx
	mov dx, ax
	add dx, checkcol_playerlocX
	jnc addpallet2
	inc cx
	
	addpallet2:
	add dx, 1078
	jnc movecursor2
	inc cx
	movecursor2:
	mov CopyBitmap_cxOffest, cx
	mov CopyBitmap_dxOffest, dx
	mov al, 0
	mov ah, 42h
	mov bx, [filehandle2]
	int 21h
	
	
	mov ah,3fh
	mov bx, [filehandle2]
	mov cx, 1
	mov dx,offset collision
	int 21h
		
	mov al, [collision]			;check for the color
	cmp al, colorcollisionIndex
	je cancolide		;wall
	cmp al, colorImmigrationIndex
	je immigrationjmp	;immigration
	cmp al, coloracceleration
	je accelerationjmp	;accelarate
	cmp al, colordecceleration
	je deccelerationjmp	;deccelerate
	cmp al, colorjump
	je jumpjmp			;jump
	cmp al, colorstop
	je stopjmp			;stop
	mov ah, nocollision
	mov sp, bp
	pop bp
	ret 4
	cancolide:
	mov ah, yescollision
	mov sp, bp
	pop bp
	ret 4
	immigrationjmp:
	mov ah, immigration
	mov sp, bp
	pop bp
	ret 4
	accelerationjmp:
	mov ah, acceleration
	mov sp, bp
	pop bp
	ret 4
	deccelerationjmp:
	mov ah, decceleration
	mov sp, bp
	pop bp
	ret 4
	jumpjmp:
	mov ah, jumpcolor
	mov sp, bp
	pop bp
	ret 4
	stopjmp:
	mov ah, stopcolor
	mov sp, bp
	pop bp
	ret 4

endp checkcol

proc Pcheckfall
	mov ax, [offsety]
	add ax, [playery]
	add ax, 1
	push ax
	mov ax, [offsetX]
	add ax, [playerx]
	add ax, playerwidth/2
	push ax
	call checkcol
	cmp [canfall], TRUE		;check if the user is on the ground
	jne continuecheckfall
	cmp ah, stopcolor		;check if the user needs to stop
	je falljmp
	continuecheckfall:
	cmp ah, acceleration	;check if the user needs to accelerate
	je falljmp
	cmp ah, decceleration	;check if the user needs to deccelerate
	je falljmp
	cmp ah, jumpcolor		;check if the player needs to jump
	je falljmp
	cmp ah, nocollision		
	jne isonground
	falljmp:
	mov [onground], FALSE	;the player is falling
	cmp [offsetX], 2940		;check for boundries
	jae changeminmaphight 
	mov [minmaphight], 310
	jmp checkfall
	changeminmaphight:
	mov [minmaphight], 430
	
	checkfall:
	mov bx, [minmaphight]
	cmp [offsety], bx
	ja movmap
	add [offsety], 3
	movmap:
	; call CopyBitmap
	cmp [offsetY], bx
	jbe movcharacter
	
	add [playery], 3
	movcharacter:
	cmp [jumpcounter], 0
	ja continuefall
	mov [frame], jumpanimation
	mov [jumpcounter], 8
	continuefall:
	push [frame]
	mov ax, [offsety]
	add ax, [playery]
	push ax
	mov ax, [offsetX]
	add ax, [playerx]
	push ax
	call draw
	add [frame], nextanimation
	dec [jumpcounter]
	jmp notonground
	
	isonground:
	mov [onground], TRUE		;the player is not falling
	notonground:
	
	ret
endp Pcheckfall 