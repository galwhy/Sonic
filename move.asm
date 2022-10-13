proc checkKey	;check if the user had pressed a key on the keyboard if so put it in ah
		
	
	
		mov ah, 1  ; check buffer
		int 16h
	jne BuffernotEmpty
	xor ax, ax
	mov [button], 0
ret
	BuffernotEmpty:
		mov ah, 0
		int 16h  ; get from buffer
		ret
ret
endp checkKey

proc move
	push bp
	mov bp, sp
	mov [startX], 0
	mov [startY],0
	
	mov ah, [button]
	cmp ah, 4Bh
	je movekey
	cmp ah, 4Dh
	je movekey
	jmp checkdir
	movekey:
	mov [lastkey], ah	;save the last key the user pressed
	checkdir:
	
	
	
	; mov ah, 4Dh
	;jmp moveright
	call checkKey
	mov [button], ah
	
	cmp [playerdir], rightdir  ; check the dir
	jne continuedir ;middlejmpmoveright
	mov [playerspeed], 2
	
	mov ax, [offsety]
	add ax, [playery]
	sub ax, playerhight/2
	push ax
	mov ax, [offsetX]
	add ax, [playerx]
	push ax
	call checkcol
	cmp ah, decceleration
	jne continuecheck3
	mov [playerdir], leftdir
		continuecheck3:
	
	cmp [offsetX], 4528-320
	jae continuerollright
	
	
	
	cmp [rightcounter], 0
	ja continuerollright
	mov [rightframe], jumpanimation
	mov [frame], jumpanimation
	mov [jumpcounter], 8
	mov [rightcounter], 8
	mov [pushrightcounter], 8
	continuerollright:
	
	jmp moverightjmp
	continuedir:
	
	cmp [playerdir], leftdir
	jne getkey ;middlejmpmoveleft
	mov [playerspeed], 2
	
	
	mov ax, [offsety]
	add ax, [playery]
	sub ax, playerhight/2
	push ax
	mov ax, [offsetX]
	add ax, [playerx]
	add ax, playerwidth
	push ax
	call checkcol
	cmp ah, acceleration
	jne continuecheck4
	mov [playerdir], rightdir
		continuecheck4:

	cmp [leftcounter], 0
	ja continuerollleft
	mov [leftframe], jumpanimation
	mov [frame], jumpanimation
	mov [jumpcounter], 8
	mov [leftcounter], 8
	mov [pushleftcounter], 8
	continuerollleft:
	jmp moveLeftjmp
	
	getkey:

	
		cmp [button], 48h	;check if the user pressed up
	je moveupjmp
		cmp [onground], FALSE	;check if the user is on the ground
	je moveupjmp
		cmp [button], 4Bh	;check if the user pressed left
	je moveLeftjmp
		cmp [button], 4Dh	;check if the user pressed right
	je moverightjmp
	@skipcheck:

	
	jmp continue4
	middlemoveup:
	jmp moveupjmp
	continue4:
	
	cmp [acctimer], 0
	je decspeed
	dec [acctimer]
	jmp exitmove
	decspeed:		;if the user hadn't pressed any key decrese the speed of the user and change the animation
		call Pidle	
	jmp exitmove
	
	
	
	moveupjmp:		;if the user pressed up: jump
	call Pjump
	jmp exitmove
		
	moveLeftjmp:		;if the user had pressed left, move left
		call moveLeft
		jmp exitmove
	
	
	moverightjmp:		;if the user had pressed left, move left
	call moveright
		jmp exitmove
		
	exitmove:
	mov sp, bp
	pop bp
ret 
endp move

proc Pidle
	mov [isjumping], FALSE
	mov [rightcounter], 6
	mov [rightframe], walkright
	mov [leftcounter],  6
	mov [leftframe], walkleft
	mov [jumpcounter], 0
	cmp [frame], idleend
	jb continueidle
	mov [frame], idle
	continueidle:
	push [frame]
	mov ax, [offsety]
	add ax, [playery]
	push ax
	mov ax, [offsetX]
	add ax, [playerx]
	push ax
	call draw
	add [frame], nextanimation
	cmp [playerspeed], 0
	je skipacc
	sub [playerspeed], 1
	skipacc:
ret
endp Pidle

proc moveleft
		mov [isjumping], FALSE
		cmp [acctimer], 10000		;check the timer to accelerate
		jae skipacc1
		add [acctimer], 2
		cmp [playerspeed], 5
		jae skipacc1
		add [playerspeed], 1
		skipacc1:
		mov ax, [offsety]
		add ax, [playery]
		sub ax, playerhight/2
		push ax
		mov ax, [offsetX]
		add ax, [playerx]
		push ax
		call checkcol
		cmp ah, yescollision	;check if next to a wall
		jne continue3
		
		
		
		cmp [pushleftcounter], 0	
		ja continueleft
		mov [frame], pushleft
		mov [pushleftcounter], 6
		continueleft:
		push [frame]
		mov ax, [offsety]
		add ax, [playery]
		push ax
		mov ax, [offsetX]
		add ax, [playerx]
		push ax
		call draw
		add  [frame], nextanimation
		dec [pushleftcounter]
		
		ret
		
		continue3:
		push ax
		cmp ah, immigration		;check if next to an immigration
		jne continuemove1
		mov ax, [playerspeed]
		cmp [playery],100		;check boundries
		jbe suboffsety
		sub [playery], ax
		jmp continuemove1
			suboffsety:
		sub [offsetY], ax
			continuemove1:
		; call checkcol
		; cmp ah, 1
		; je exitmove
		cmp [offsetX], 4
		jbe skipmap1
		mov ax, [playerspeed]
		sub [offsetX], ax
		skipmap1:
		; call CopyBitmap
		cmp [offsetX], 5
		jnb drawjmp2
		cmp [playerx], 4
		jbe drawjmp2
		mov ax, [playerspeed]
		sub [playerx], ax
		
		drawjmp2:
		cmp [leftcounter], 0
		ja continueleft2
		mov [leftframe], runleft
		mov [leftcounter], 4
		continueleft2:
		
		
		push [leftframe]	;move the animation
		mov ax, [offsety]
		add ax, [playery]
		push ax
		mov ax, [offsetX]
		add ax, [playerx]
		push ax
		call draw
		add [leftframe], nextanimation
		dec [leftcounter]
		pop ax
		cmp ah, decceleration
		jne continuecheck1
		mov [playerdir], leftdir
			continuecheck1:
		cmp ah, acceleration
		jne exitmovejmp1
		mov [playerdir], rightdir
		
		exitmovejmp1:
		cmp ah, stopcolor
		jne exitmoveleft
		mov [playerdir], 0
		exitmoveleft:
ret
endp moveLeft

proc moveright
		mov [isjumping], FALSE
		cmp [acctimer], 10000		;check the timer to accelerate
		jae skipacc2
		add [acctimer], 2
		cmp [playerspeed], 5
		jae skipacc2
		add [playerspeed], 1
		skipacc2:
		mov ax, [offsety]
		add ax, [playery]
		sub ax, playerhight/2
		push ax
		mov ax, [offsetX]
		add ax, [playerx]
		add ax, playerwidth
		push ax
		call checkcol
		cmp ah, yescollision		;check if next to a wall
		jne continue2 ;middleexit
		
		cmp [pushrightcounter], 0
		ja continueright
		mov [frame], pushright
		mov [pushrightcounter], 6
			continueright:
		push [frame]
		mov ax, [offsety]
		add ax, [playery]
		push ax
		mov ax, [offsetX]
		add ax, [playerx]
		push ax
		call draw
		add  [frame], nextanimation
		dec [pushrightcounter]
		ret
		
		continue2:
		cmp ah, jumpcolor
		jne continuecheck5
		call Pjump
		ret
		continuecheck5:
		push ax
		cmp ah, immigration		;check if next to immigration
		jne continuemove
		mov ax, [playerspeed]
		cmp [playery], 100		;check boundries
		jbe addoffsety
		sub [playery], ax
		jmp continuemove
			addoffsety:
		sub [offsetY], ax
			continuemove:
		cmp [offsetx], 4528
		jae @drawjmp
		cmp [playerx], 160
		jb skipmap2
		mov ax, [playerspeed]
		add [offsetX], ax
			skipmap2:
		; call CopyBitmap
		cmp [playerx], 160
		jae	 @@drawjmp
			@drawjmp:
		mov ax, [playerspeed]
		add [playerx], ax
			@@drawjmp:
		cmp [rightcounter], 0
		ja continueright2
		mov [rightframe], runright		;move animation
		mov [rightcounter], 4
		continueright2:
		push [rightframe]
		mov ax, [offsety]
		add ax, [playery]
		push ax
		mov ax, [offsetX]
		add ax, [playerx]
		push ax

		call draw
		add [rightframe], nextanimation
		dec [rightcounter]
		
		pop ax
		cmp ah, decceleration
		jne continuecheck2
		mov [canfall], TRUE
		mov [playerdir], leftdir
			continuecheck2:
		cmp ah, acceleration
		jne exitmovejmp2
		mov [playerdir], rightdir
		jmp exitmoveright
			exitmovejmp2:
		cmp ah, stopcolor
		jne exitmoveright
		mov [playerdir], 0
		exitmoveright:
ret
endp moveright

proc Pjump
		cmp [lastkey], 4Bh	;check if the last key was left
	je jumpleft
		cmp [lastkey], 4Dh	;check if the lest key was right
	je jumpright
	jmp jump
	
	jumpleft:		;if the last key was left, jump left
	cmp [playerx], 160
	jae movmapl
	cmp [playerx], 2
	jbe movmapl
	sub [playerx], 3
	jmp jump
	movmapl:
	cmp [offsetX], 2
	je jump
	mov ax, [playerspeed]
	sub [offsetX], ax
	jmp jump
	jumpright:		;if the last key was right, jump right
	cmp [playerx], 160
	jae movmapr
	mov ax, [playerspeed]
	add [playerx], ax
	jmp jump
	movmapr:
	mov ax, [playerspeed]
	add [offsetX], ax
	jump:		
		
		cmp [onground], TRUE	;check if the user is on the ground, if so start the jump
		jne continuejump
		mov [isjumping], TRUE
		mov [jumpsound], JSound
		; mov [noteduration], 3
		mov cx, [jumppower]
		continuejump:
		cmp cx, 0
		jne continuejump2
		mov [isjumping], FALSE
		jmp skipmov
		continuejump2:
		sub [jumpsound], 30 ;25
		skipmov:
		
		cmp cx, 0
		jbe skipjump
		cmp [playery], 80
		jbe movmapup
		sub [playery], cx
		dec cx
		jmp skipjump
		movmapup:
		sub [offsetY], cx
		dec cx
		skipjump:
ret
endp Pjump