; ===========================================================================
; ---------------------------------------------------------------------------
; Object DE - Buzz Bomber enemy	(GHZ, MZ, SYZ)
; ---------------------------------------------------------------------------

ObjDE:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Buzz_Index(pc,d0.w),d1
		jmp	Buzz_Index(pc,d1.w)
; ===========================================================================
Buzz_Index:	dc.w Buzz_Main-Buzz_Index
		dc.w Buzz_Action-Buzz_Index
		dc.w Buzz_Delete-Buzz_Index

buzz_timedelay = $32
buzz_buzzstatus = $34
buzz_parent = $3C
; ===========================================================================

Buzz_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Buzz,obMap(a0)
		move.w	#ArtTile_ArtNem_BuzzBomber,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#8,obColType(a0)
		move.b	#$18,obActWid(a0)

Buzz_Action:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	index(pc,d0.w),d1
		jsr	index(pc,d1.w)
		lea	(Ani_Buzz).l,a1
		jsr	AnimateSprite
        jmp	DisplaySprite
; ===========================================================================
index:		dc.w bbmove-index
		dc.w chknearsonic-index
; ===========================================================================

bbmove:
		subq.w	#1,buzz_timedelay(a0) ; subtract 1 from time delay
		bpl.s	noflip		; if time remains, branch
		btst	#1,buzz_buzzstatus(a0) ; is Buzz Bomber near Sonic?
		bne.s	fire		; if yes, branch
		addq.b	#2,ob2ndRout(a0)
		move.w	#127,buzz_timedelay(a0) ; set time delay to just over 2 seconds
		move.w	#$400,obVelX(a0) ; move Buzz Bomber to the right
		move.b	#1,obAnim(a0)	; use "flying" animation
		btst	#0,obStatus(a0)	; is Buzz Bomber facing	left?
		bne.s	noflip		; if not, branch
		neg.w	obVelX(a0)	; move Buzz Bomber to the left

	noflip:
		rts	
; ===========================================================================

	fire:
		jsr	FindFreeObj
		bne.s	objDEfail
		move.b	#ObjID_Buzzmissile,0(a1) ; load missile object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		addi.w	#$1C,obY(a1)
		move.w	#$200,obVelY(a1) ; move missile downwards
		move.w	#$200,obVelX(a1) ; move missile to the right
		move.w	#$18,d0
		btst	#0,obStatus(a0)	; is Buzz Bomber facing	left?
		bne.s	noflip2	; if not, branch
		neg.w	d0
		neg.w	obVelX(a1)	; move missile to the left

	noflip2:
		add.w	d0,obX(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.w	#$E,buzz_timedelay(a1)
		move.l	a0,buzz_parent(a1)
		move.b	#1,buzz_buzzstatus(a0) ; set to "already fired" to prevent refiring
		move.w	#59,buzz_timedelay(a0)
		move.b	#2,obAnim(a0)	; use "firing" animation

	objDEfail:
		rts	
; ===========================================================================

chknearsonic:
		subq.w	#1,buzz_timedelay(a0) ; subtract 1 from time delay
		bmi.s	chgdirection
		jsr	SpeedToPos
		tst.b	buzz_buzzstatus(a0)
		bne.s	keepgoing
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bpl.s	isleft
		neg.w	d0

	isleft:
		cmpi.w	#$60,d0		; is Buzz Bomber within	$60 pixels of Sonic?
		bcc.s	keepgoing	; if not, branch
		tst.b	obRender(a0)
		bpl.s	keepgoing
		move.b	#2,buzz_buzzstatus(a0) ; set Buzz Bomber to "near Sonic"
		move.w	#29,buzz_timedelay(a0) ; set time delay to half a second
		bra.s	objDEstop
; ===========================================================================

	chgdirection:
		move.b	#0,buzz_buzzstatus(a0) ; set Buzz Bomber to "normal"
		bchg	#0,obStatus(a0)	; change direction
		move.w	#59,buzz_timedelay(a0)

	objDEstop:
		subq.b	#2,ob2ndRout(a0)
		move.w	#0,obVelX(a0)	; stop Buzz Bomber moving
		move.b	#0,obAnim(a0)	; use "hovering" animation

keepgoing:
		rts	
; ===========================================================================

Buzz_Delete:	; Routine 4
		jsr	DeleteObject
		rts	

Map_Buzz:	BINCLUDE	"mappings/sprite/objDE_buzz_bomber.bin"

; ---------------------------------------------------------------------------
; Animation script - Buzz Bomber enemy
; ---------------------------------------------------------------------------
Ani_Buzz:	dc.w anibfly1-Ani_Buzz
		dc.w anibfly2-Ani_Buzz
		dc.w anibfires-Ani_Buzz
anibfly1:		dc.b 1,	0, 1, afEnd
anibfly2:		dc.b 1,	2, 3, afEnd
anibfires:		dc.b 1,	4, 5, afEnd
		even
