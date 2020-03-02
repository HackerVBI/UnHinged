
	IFUSED Galois16
Galois16	ld   hl, #FFFF      ; 10
SeedValue	EQU   $-2
		add  hl, hl         ; 11
		sbc  a         ; 4
		and  #EB         ; 7 instead of #EB one can use #AF
		ld   c, a         ; 4
		xor  l         ; 4
		ld   l, a         ; 4
		ld   a,c         ; 4
		xor  h         ; 4
		ld   h,a         ; 4
		ld   (SeedValue), hl      ; 16
		and   %10101010
		add   l         ; +7+4 => +11t
		ret 

	ENDIF

	IFUSED	rnd
rnd     	ld  de,0x2b3b   ; xz -> yw
		ld  hl,0x9c18   ; yw -> zt; 0xC0DE
		ld  (rnd+1),hl  ; x = y, z = w
		ld  a,l         ; w = w ^ ( w << 3 )
		add a,a
		add a,a
		add a,a
		xor l
		ld  l,a
		ld  a,d         ; t = x ^ (x << 1)
		add a,a
		xor d
		ld  h,a
		rra             ; t = t ^ (t >> 1) ^ w
		xor h
		xor l
		ld  h,e         ; y = z
		ld  l,a         ; w = t
		ld  (rnd+4),hl
		ret
	ENDIF

	IFUSED spr_off
spr_off		ld bc, FMADDR
		ld a, FM_EN+#c
		out (c), a      ; open FPGA arrays at #0000
		; clean SFILE

FM_SFILE        equ #0200+#c000
		ld hl,FM_SFILE
		xor a
spr_off_l1	ld (hl), a
		inc l
		jr nz,spr_off_l1
		inc h
spr_off_l2	ld (hl), a
		inc l
		jr nz,spr_off_l2
		out (c), a      ; close FPGA arrays at #0000
		ret
	ENDIF


	IFUSED clear_tileset
clear_tileset	ld bc,PAGE3
	    	ld a,Tile_page
		out (c),a
		ld (#c000),hl
		ld hl,tileset_clr
		jp set_ports
	ENDIF


	IFUSED fadeOUT
/*
		ld b,8
c_pal1		push bc
c_pal		ld hl,viol_pal-32
		ld de,32
		add hl,de
		ld (c_pal+1),hl
		call fadeOUT
		ld hl,(c_pal+1)
		ld de,32*4
		add hl,de
		ex de,hl
		ld hl,temp_pal
		ld bc,32
		ldir
		pop bc
		djnz c_pal1
*/	
fadeOUT
		ld hl,temp_pal
		ld b,#10
fadeout2	push bc
		xor a
		ld (greenH+1),a	; Green High
		ld (greenL+1),a ; Green Low
		ld (red+1),a
		ld (blue+1),a
		call fdout
greenL		ld a,0
blue		or 0
		ld (hl),a
		inc hl
red		ld a,0
greenH		or 0
		ld (hl),a
		inc hl
		pop bc
		djnz fadeout2
		ret

fdout		inc hl
		ld a,(hl)	; 0RRrrrGG gggBBbbb
		dec hl
		push af
		and %01111100
		srl a
		srl a
		dec a
		cp #ff
		jr z,fd21
		sla a
		sla a
		ld (red+1),a; R
fd21
		pop af
		and %00000011	; GG
		ld c,a
		ld a,(hl)
		push af
		and %11100000	; ggg  	0RRrrrGG gggBBbbb
		sla a
		rl c
		sla a
		rl c
		sla a
		rl c
		ld a,c
		dec a
		cp #ff
		jr z,fd22
		ld c,0
		srl a
		rr c
		srl a
		rr c
		srl a
		rr c
		ld (greenH+1),a	; Green High
		ld a,c
		ld (greenL+1),a ; Green Low
fd22
		pop af
		and %00011111
		dec a
		cp #ff
		ret z
		ld (blue+1),a
		ret
		align 2
temp_pal	ds 32
	ENDIF

	IFUSED tile_filler
/*
		ld hl,#c996
		ld de,#0000
		ld bc,#1008	; 128x160
		ld a,Tile_page
		call tile_filler
*/

tile_filler	exx
		ld bc,PAGE3
		out (c),a
		exx
		ld a,l
		ld (rfil3+1),a
		ld a,#40
		sub b
		ld (rfil4+1),a
rfil1		push bc
rfil2		ld (hl),e
		inc l
		ld (hl),d
		inc l
		inc de
		djnz rfil2
		inc h
rfil3		ld l,0
		ex de,hl
rfil4		ld bc,0
		add hl,bc
		ex de,hl
		pop bc
		dec c
		jr nz,rfil1
		ret
	ENDIF

	IFUSED set_ports
set_ports	ld c,#AF
.m1		ld b,(hl) 
		inc hl
		inc b
		jr z,dma_stats
		outi
		jr .m1
	ENDIF
	
	IFUSED set_ports_nowait
set_ports_nowait
		ld c,#AF
.m2		ld b,(hl) 
		inc hl
		inc b
		ret z
		outi
		jr .m2
	ENDIF
	IFUSED dma_stats
dma_stats	ld b,high DMASTATUS
		in a,(c)
		AND #80
		jr nz,$-4
		ret
	ENDIF