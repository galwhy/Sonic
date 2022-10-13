IDEAL

MODEL small
STACK 100h


DATASEG

	;files------------------------
	Header db 54 dup (?)
	header2 db 54 dup (?)
	filename db  'game/map.bmp',0
	filename2 db 'game/sonic_00.bmp',0
	filename3 db 'game/col2.bmp', 0
	filename4 db 'anim/ani_00.bmp',0
	filename5 db 'game/music1.txt',0
	filename6 db 'game/music2.txt',0
	filename7 db 'game/end_00.bmp',0
	filename8 db 'game/music3.txt',0
	filename9 db 'game/start_00.bmp',0
	filename10 db 'game/lose_00.bmp',0
	filename11 db 'game/music4.txt',0
	
	filehandle  dw ?
	filehandle2 dw ?
	filehandle3 dw ?
	filehandle4 dw ?
	filehandle5 dw ?
	
	
	
	
	Palette db 256*4 dup (?)
	ScrLine db 320 dup (?)
	ErrorMsg db 'Error', 13, 10 ,'$'
	
	PIC_WIDTH equ [word ptr header + 12h]
	PIC_HIGHT equ [word ptr header + 16h]
	
	;offset-----------------
	
	startX dw ?
	startY dw ?
	offsetx dw ?
	offsety dw ?;313
	playerx dw ?
	playery dw ?
	
	;player------------------
	playerhight equ 12
	playerwidth equ 14
	 
	playerdir db ?
	rightdir equ 1
	leftdir equ 2
	jumppower dw 14
	playerspeed dw 2
	acctimer dw 30
	exitgame db FALSE
	onground db TRUE
	canfall db FALSE
	isjumping db FALSE
	TRUE equ 1
	FALSE equ 0
	
	;collision--------------------
	collision db ?
	
	
	colorcollisionIndex equ 0 ; black
	colorImmigrationIndex equ 0FFh ; white
	coloracceleration equ 0F9h ; red
	colordecceleration equ 1 ; dark red
	colorjump equ 0FAh ; green
	colorstop equ 0FCh ; blue
	nocollision equ 0
	yescollision equ 1
	immigration equ 2
	acceleration equ 3
	decceleration equ 4
	jumpcolor equ 5
	stopcolor equ 6
	
	
	minmaphight dw 1000
	
	;animation----------------------
	player  db 440*43 dup(10) ; 43 pics 20x22
	nextanimation equ 440
	rightcounter	db ?
	leftcounter		db ?
	jumpcounter		db ?
	pushleftcounter		db ?
	pushrightcounter	db ?

			
	savemap db 440 dup (?)
	frame dw ?
	leftframe dw ?
	rightframe dw ?
	
	
	idle		equ 440*0
	idleend		equ 440*2

	walkleft 		equ 440*10
	walkleftend	 	equ 440*16
	
	runleft			equ 440*16
	runleftend		equ 440*20
	
	walkright 		equ 440*20
	walkrightend	equ 440*26
	
	runright		equ 440*26
	runrightend		equ 440*30
	
	jumpanimation	equ 440*2
	jumpend			equ 440*2
	
	roll			equ 440*30
	
	pushright		equ 440*37
	
	pushleft		equ 440*31
	
	
	button db ?
	lastkey db ?
	
	;music----------------------------
	musiccounter db ?
	sound dw ?
	openingmusicArrayLENGHT equ 36
	openingmusicArray dw openingmusicArrayLENGHT dup (?)
	musicarrayLENGTH equ 135
	songloop equ 45
	musicarray dw musicarrayLENGTH dup (?)
	endingmusicArrayLENGHT equ 20
	endingmusicArray dw endingmusicArrayLENGHT dup(?)
	losingmusicArrayLENGTH equ 4
	losingmusicArray dw losingmusicArrayLENGTH dup(?)
	noteduration dw	?
	jumpsound dw ?
	JSound equ 1708
	
	;timer--------------------------
	seccounter dw ?
	timestring db "TIME: 00:00$"
	timecounter db ?
	score db "0000"
	maxscore equ 2000
	onesecond equ 100
	secondone equ 10
	secondten equ 9
	minuteone equ 7
	minuteten equ 6
	

CODESEG

	ORG 100h
	
		include 'files.asm'
		include 'draw.asm'
		include 'move.asm'
		include 'animate.asm'
		include 'music.asm'
		include 'screens.asm'
		include 'timer.asm'
		include 'colision.asm'
		
start :
	mov ax, @data
	mov ds, ax
	; Graphic mode
	mov ax, 13h
	int 10h
	
	in al, 61h
	or al, 00000011b
	out 61h, al
	
	
	call loadanimation

	push offset filehandle4
	push offset filename5
	call OpenFile
	push offset openingmusicArray
	push openingmusicArrayLENGHT*2;72
	call readfromfile
	
	call openingscreen
	push offset filehandle4
	call CloseFile
	mov ax, 1
	out 42h, al ; stop sound
	mov al, ah
	out 42h, al
	
	push offset filehandle4
	push offset filename6
	call OpenFile
	push offset musicarray
	push musicarrayLENGTH*2;270
	call readfromfile
	push offset filehandle4
	call CloseFile
	

	restartjmp:
	mov [musiccounter], 0
	
	
	call startscreen
	
	; Process BMP file
	mov [offsetY], 313
	mov [offsetX], 0
	push offset filehandle
	push offset filename
	call OpenFile


	push [filehandle]
	push offset header
	call ReadHeader
	call ReadPalette
	call CopyPal

	
	
	
	push offset filehandle2
	push offset filename3
	call OpenFile


	
	mov [playerx], 36
	mov [playery], 130
	push 0
	mov ax, [offsety]
	add ax, [playery]
	push ax
	mov ax, [offsetX]
	add ax, [playerx]
	push ax
	call draw
	
	mov cx, 0
	mov [lastkey],0
	mov [timestring + secondone], 30h
	mov [timestring + secondten], 30h
	mov [timestring + minuteone], 30h
	mov [timestring + minuteten], 30h

	
	movloop:

	call mainmusic

	push ax
	push cx
	push dx
	;print timer
	
	
	
	
	mov cx, 11
	mov si, 0
	
	printloop:
	push cx
		mov dx, si		
		mov bx, 0
		mov ah, 2
		int 10h
		
		
		
		mov ah, 9h
		mov bl, 00B1h
		mov al, [timestring + si]
		mov bh, 2
		mov cx, 1
		int 10h
	inc si
	pop cx
	loop printloop

	
	
	mov cx, 0
	mov dx, 2710h  ; delay so the it wont check the buffer when its empty
	mov ah, 86h
	int 15h
	
	cmp [timecounter], 69
	jne inccounter
	mov [timecounter], 0
	call timer
	inccounter:
	inc [timecounter]
	pop dx
	pop cx
	pop ax
	
	cmp [isjumping], TRUE
	je skipcheck
	dec [noteduration]
	cmp [noteduration], 0
	je nextSound2
	jmp continuegame
	nextSound2:
	inc [musiccounter]
	
	
	continuegame:
	
	cmp [musiccounter], musicarrayLENGTH
	jne continuegame2
	mov [musiccounter], songloop ;45
	continuegame2:
	skipcheck:
	call move
	
	mov bx, [minmaphight]
	add bx, 240
	mov dx, [offsetY]
	add dx, [playery]

	cmp dx, bx
	jna skipfalllose
		mov ax, 1
		out 42h, al ; stop sound
		mov al, ah
		out 42h, al
		
		
		push offset filehandle4
		push offset filename11
		call OpenFile
		push offset losingmusicArray
		push losingmusicArrayLENGTH*2;8
		call readfromfile
		push offset filehandle4
		call CloseFile
		
		mov [musiccounter], 0
		call losescreen
		
			loseloop:

		jne loseloop
		jmp restartjmp
	skipfalllose:

	
	push cx
	call Pcheckfall
	pop cx
	cmp [button], 1
	jne skipexitjmp
	jmp exitgamejmp
	skipexitjmp:
	cmp [offsetX], 4528-320
	jnae continuemoveloop
	cmp [playerx], 314
	jae finishjmp
	
	continuemoveloop:
	jmp movloop
	
	finishjmp:
		mov ax, 1
		out 42h, al ; stop sound
		mov al, ah
		out 42h, al
		mov [musiccounter], 0
		push offset filehandle4
		push offset filename8
		call OpenFile
		push offset endingmusicArray
		push endingmusicArrayLENGHT*2;40
		call readfromfile
		call endscreen

		mov ax, 1
		out 42h, al ; stop sound
		mov al, ah
		out 42h, al
		
		mov ax, maxscore
		sub ax, [seccounter]
		mov cx, ax
		mov si, 0
	scoreloop:
		push cx
		push si
			
		
		mov cx, 4
		mov si, 25
		@@printloop:		;print the time on screen 
		push cx
			mov dx, si
			mov dh, 12
			mov bx, 0
			mov ah, 2
			int 10h		;set the cursor position to the start of the screen
			
			mov ah, 9h
			mov bl, 00FFh
			mov al, [score + si - 25]
			mov bh, 0
			mov cx, 1
			int 10h		;print a letter in a spacial color
		inc si
		pop cx
		loop @@printloop
		
		pop si
		cmp si, 20
		jae stopsound
		
			mov ax, 54Ah
			out 42h, al ; stop sound
			mov al, ah
			out 42h, al
			inc si
			jmp waitjmp
		
		stopsound:
			mov ax, 1
			out 42h, al ; stop sound
			mov al, ah
			out 42h, al
			inc si
			cmp si, 30
			jne waitjmp
			mov si, 0
		
		waitjmp:
			mov cx, 0
			mov dx, 500h  ; delay so the it wont check the buffer when its empty
			mov ah, 86h
			int 15h
		
		
			cmp [score + 3], 39h	;check for seconds
		je addten
			inc [score + 3]
			jmp @continueloop
		addten:
		cmp [score + 2], 39h	;check for tens
		je addhundred
			mov [score + 3], 30h	
			inc [score + 2]
			jmp @continueloop
		addhundred:
		cmp [score + 1], 39h	;check for minutes
		je addthousand
			mov  [score + 3], 30h
			mov  [score + 2], 30h
			inc	 [score + 1]
			jmp @continueloop
		addthousand:
			mov  [score + 3], 30h
			mov  [score + 2], 30h
			mov  [score + 1], 30h
			inc	 [score]
			
			@continueloop:
			pop cx 
			dec cx
			cmp cx, 0
			je finishloop
	jmp scoreloop
	finishloop:
		mov ax, 1
		out 42h, al ; stop sound
		mov al, ah
		out 42h, al
		call checkKey
		cmp ah, 1
		je exitgamejmp
	jmp finishloop 
	
		mov ax, 1
		out 42h, al ; stop sound
		mov al, ah
		out 42h, al
	exitgamejmp:
	mov ax, 1
	out 42h, al ; stop sound
	mov al, ah
	out 42h, al
	
	
	
	push [filehandle2]
	call CloseFile
	push [filehandle]
	call CloseFile
	
	in al, 61h
	or al, 11111100b
	out 61h, al
	; Wait for key press
	mov ah,1
	int 21h
	; Back to text mode
	mov ah, 0
	mov al, 2
	int 10h
exit :
	mov ax, 4c00h
	int 21h
END start
