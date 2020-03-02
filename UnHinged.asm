	device zxspectrum128

; temp pages:
Tilegfx_temp_page	equ #78
Stains_gfx_temp_page	equ #80
noise_screen_Vid_page	equ #88
Vid_page		equ #a0
words_spr_page		equ #a8
mask_vpage		equ #b0

Tile_page		equ #9f
Tile0_spr_page		equ #90
Tile1_spr_page		equ #98

mus_page		equ #10
music			equ #c000

alphabet_page		equ #0e
stains_page		equ #16

mask_phone_pic		equ #c000
mask_phone_page		equ #11
mask_red_pic		equ #c000
mask_red_page		equ mask_phone_page+2

mask_glith_pos		equ #7c00
words_glith_pos		equ mask_glith_pos+#100
colorz_glith_pos	equ words_glith_pos+#100
hate_glith_pos		equ colorz_glith_pos+#100
frstartr_glith_pos	equ mask_glith_pos

frstartr_page		equ #20	;	248 x 164

mask_pics_page		equ #48
intro_page		equ #1b
sound_page		equ #1a

		org #8000
start
		di
		ld sp,#bfff
		call im2_init
		call all_init
		ld a,mus_page
		ld bc,PAGE3
		out (c),a
		ld hl,music
		call #c000
		call set_Y
;		ld bc,PALSEL
;		ld a,6
;		out (c),a
		ld hl,intro1
		call set_ports
		ld hl,intro3
		call set_ports
		ld hl,intro4
		call set_ports
		ld hl,intro2
		call set_ports
		ld hl,mask_glith_pos
		ld de,mask_glith_pos+1
		ld bc,#2ff
		ld (hl),l
		ldir
		ld bc,INTMASK
		ld a,3
		out (c),a
		ld hl,intro_line_proc
		ld (#befd),hl
		exx
		ld c,low GYOFFSL
		ld hl,mask_glith_pos
		exx
		ld bc,PAGE3
		ld a,sound_page
		out (c),a

;		jp demo_start


		ei 
		ld b,#30
4		call wait_frame
		djnz 4b
		ld c,#37
1		call wait_frame
		exx
		ld l,0
		exx
snd_pos		ld hl,#c000
		ld de,#11d
3		ld a,(hl)
		out (#fb),a
		inc hl
		ld b,#06
		djnz $
		dec de
		ld a,d
		or e
		jr nz,3b
		ld (snd_pos+1),hl
;		ld hl,0
		ld de,mask_glith_pos+#80
		ld b,#30
2		ld a,(hl)
		add #80
		jr c,$+4
		neg
		srl a		;#40
		ld (de),a
		inc hl
		inc e
		djnz 2b
		dec c
		jr nz,1b
		ld e,#80
		xor a
6		ld (de),a
		inc e
		jr nz,6b		

		ld b,#20
5		call wait_frame
		djnz 5b
demo_start
		di
		ld hl,mask_bw_pal_bin
		ld de,temp_pal
		ld bc,32
		ldir
		ld b,7
c_pal1		push bc
		ld hl,(c_pal+1)
		push hl
		call fadeOUT
		pop hl
		call fadeOUT
c_pal		ld hl,faded_pals
		ld bc,32
		add hl,bc
		ld (c_pal+1),hl
		ex de,hl
		ld hl,temp_pal
		ldir
		pop bc
		djnz c_pal1
		ld hl,all_pals
		call set_ports

		ld hl,mask_line_proc
		ld (#befd),hl
		call mask_vpages_init
		call words_init
		xor a
		ld bc,PALSEL
		out (c),a
		ld hl,int
		ld (#beff),hl
		call cls
;		call noise_screen_inits
;		call mask_bw_inits
;		call mask_red_inits
;		call stains_init
;		call frstartr_init
		ei
loop		call wait_frame
;		call noise_screen_unsync
;		call mask_unsync
;		call stains_play
;		call frstartr
main_proc	call en_pop_ex
		jp loop


		MACRO	_init	addr
		db	3
		dw	addr
		ENDM

		MACRO	_call	addr
		db	2
		dw	addr
		ENDM
		
		MACRO	_wait	time
		db	0
		dw	time
		ENDM

		MACRO	_poke	addr, value
		db	1
		dw	addr
		db	value
		ENDM

		MACRO	_pal	value,addr
		db	4
		db	value
		dw	addr
		ENDM

		MACRO	_mask	value
		db	5
		db	value
		ENDM

		MACRO	_rnd_screen
		db	6
		ENDM

left 		equ #0a0
right 		equ #160
center		equ 0

		MACRO	_mask_pos position
		db	7
		dw position
		ENDM
		
		MACRO	_pal_layer value
		db	8
		db	value

		ENDM

music_pattern	equ #60	; 2 words, 1 word- #30
off 		equ 0
on		equ 1

proc_db
/*
// ----------------
;Pt.4: Each message is synchronized with the synths beat
		_rnd_screen
		_init frstartr_init
		_pal 0, mask_red_pal_bin
		_poke word_v_pos+1,#c0
; rnd init
		_poke rnd+1,#52
		_poke rnd+2,#00
		_poke rnd+4,#0c
		_poke rnd+5,#b3

		_call frstartr
		
		_wait music_pattern*2-1

;Pt.5: wait
;		_rnd_screen
		_init stains_init
;		_pal 0, mask_bw_pal_bin
		_pal_layer 0
		_poke words_tiles_vert_glitch+1,off
		_poke mask_bw_fader+1, off
		_poke fade_mask_bw+1, on
		_call stains_play

		_wait music_pattern*16*4+music_pattern*4-1	; /2
		_poke words_tiles_vert_glitch+1,on

// ----------------
*/



; Pt.1: Each message is synchronized with the kick beat

		_init mask_bw_inits
		_mask 0
		_mask_pos center-#40
		_poke mask_bw_fader+1, on
		_poke words_tiles_vert_glitch+1,off
		_poke words_t0_glitch_switch+1,off
		_poke words_t1_glitch_switch+1,off
proc_loop
		_poke glitch_level+1, 1
		_call mask_unsync

		_wait 2
		_mask_pos center-#30
		_wait 2*2
		_mask_pos center-#20
		_wait 2*3
		_mask_pos center-#10
		_wait 2*4
		_mask_pos center-#c
		_wait 2*5
		_mask_pos center-#8
		_wait 2*6
		_mask_pos center-#6
		_wait 2*7
		_mask_pos center-#4
		_wait 2*8
		_mask_pos center-#2
		_wait 2*9
		_mask_pos center-#1
		_wait 2*10
		_mask_pos center
		_wait music_pattern*4

		_poke words_tiles_vert_glitch+1,on
		_poke words_t0_glitch_switch+1,on
		_poke glitch_level+1, 3
		_mask 1
		_poke word_v_pos+1,#c3
		_poke glitch_level+1, 7
		_wait music_pattern*6
		_poke glitch_level+1, #0f
		_wait music_pattern*8-6
		_poke mask_bw_fader+1, off
		_pal_layer 0
		
		_pal 0, white_pal
		_mask 3
		_wait music_pattern*8-3
		_mask 5
		_wait music_pattern*8


		_poke mask_bw_fader+1, on
		_pal 0, mask_bw_pal_bin
		_poke words_t1_glitch_switch+1,on	
		_mask 1
		_wait music_pattern*16-96+90
		_pal 0, mask_red_pal_bin
		_wait music_pattern*16-1
		_pal 0, mask_bw_pal_bin
; Pt.2: Each message is synchronized with the kick beat

		
		_mask 2
		_poke words_t1_glitch_switch+1,on
		_poke word_v_pos+1,#c6
		_wait music_pattern*16+music_pattern*2
		_poke fade_mask_bw+1, on		; MASSIVE glitch
		_wait music_pattern*16+music_pattern*4	
		_poke glitch_level+1, #1f
		_mask 3
		_poke word_v_pos+1,#c9
		_poke fade_mask_bw+1, off	; MASSIVE glitch OFF
		_wait music_pattern*16+music_pattern*4+music_pattern*2
		_poke fade_mask_bw+1, on		; MASSIVE glitch

;		_pal 0, white_pal
		_wait music_pattern*16+music_pattern*4*2
;		_pal 0, mask_bw_pal_bin

		_mask 4
		_poke word_v_pos+1,#cc
		_poke fade_mask_bw+1, off	; MASSIVE glitch OFF
		_wait music_pattern*16+music_pattern*4*2+music_pattern*2
		_poke fade_mask_bw+1, on		; MASSIVE glitch
		_wait music_pattern*16+music_pattern*4*3
		_poke glitch_level+1, #3f
		_mask 5
		_poke word_v_pos+1,#cf
		_poke fade_mask_bw+1, off		; MASSIVE glitch OFF
		_wait music_pattern*16+music_pattern*4*3+music_pattern*2
		_poke fade_mask_bw+1, on	; MASSIVE glitch

		_wait music_pattern*16*2-12
		_poke mask_bw_fader+1, off
		_pal_layer 0
		_pal 0, mask_red_pal_bin
		_wait music_pattern*16*2-6
		_pal 0, white_pal

		_wait music_pattern*16*2-1
		_pal 0, mask_bw_pal_bin


; Pt.3: Each message is synchronized with the kick beat
		_poke fade_mask_bw+1, off		; MASSIVE glitch OFF
		_poke mask_bw_fader+1, on
		_poke words_tiles_vert_glitch+1,off
		_rnd_screen
		_poke word_v_pos+1,#c8
		_wait music_pattern*16*2+music_pattern/2	; this 
		_poke words_tiles_vert_glitch+1,on
		_wait music_pattern*16*2+music_pattern-1	; is

		_poke words_tiles_vert_glitch+1,off
		_poke word_v_pos+1,#c0
		_poke mask_bw_fader+1, off
		_pal_layer 0
		_pal 0, white_pal
		_wait music_pattern*16*2+music_pattern+4	; not
		
		_pal 0, mask_bw_pal_bin
		_poke mask_bw_fader+1, on
		_wait music_pattern*16*2+music_pattern+music_pattern/2
		_poke words_tiles_vert_glitch+1,on
		_poke word_v_pos+1,#cf
		_poke mask_bw_fader+1, off			; cool
		_pal_layer 0
		_pal 0, white_pal
		_wait music_pattern*16*2+music_pattern+music_pattern/2+4
		
		_poke mask_bw_fader+1, on
		_pal 0, mask_bw_pal_bin
		_wait music_pattern*16*2+music_pattern*2-1

		_poke mask_bw_fader+1, off
		_poke words_tiles_vert_glitch+1,on

		_init mask_red_inits
		_pal_layer 1
		_mask_pos center
		_call mask_unsync
		_mask 6
		_poke word_v_pos+1,#d0
		_poke fade_mask_bw+1, off		; simple glitch 
		_poke words_t0_glitch_switch+1,on	; 0 - glitch t0, 1 - static t0 (for frstartr)

		_wait music_pattern*16*2+music_pattern*4

;		_poke red_heat_switch+1,on
;		_poke red_heat_level+1,1
		_wait music_pattern*16*2+music_pattern*4*2
		_poke red_heat_switch+1,on
		_poke red_heat_level+1,1
		_wait music_pattern*16*2+music_pattern*4*3
		_poke red_heat_level+1,3
		_wait music_pattern*16*3-music_pattern*2
;		_poke red_heat_level+1,7
;		_wait music_pattern*16*2+music_pattern*4+music_pattern-2

		_poke fade_mask_bw+1, on
		_wait music_pattern*16*3-music_pattern-1
		_poke red_heat_switch+1,1
		_poke fade_mask_bw+1, off
;		_pal 0, mask_bw_pal_bin

;		_wait music_pattern*16*3 -2*6-1
		_mask 5
		_wait music_pattern*16*3 -2*6
		_mask 4
		_wait music_pattern*16*3 -2*5
		_mask 3
		_wait music_pattern*16*3 -2*4
		_mask 2
		_wait music_pattern*16*3 -2*3
		_mask 1
		_wait music_pattern*16*3 -2*2
		_mask 0
		_wait music_pattern*16*3 -1
		_poke red_heat_switch+1,off

// ----------------
;Pt.4: Each message is synchronized with the synths beat
		_rnd_screen
		_init frstartr_init
		_pal 0, mask_red_pal_bin
		_poke word_v_pos+1,#c0
; rnd init
		_poke rnd+1,#52
		_poke rnd+2,#00
		_poke rnd+4,#0c
		_poke rnd+5,#b3

		_call frstartr
		
		_wait music_pattern*16*4-1

;Pt.5: wait
;		_rnd_screen
		_init stains_init
;		_pal 0, mask_bw_pal_bin
		_pal_layer 0
		_poke words_tiles_vert_glitch+1,off
		_poke mask_bw_fader+1, off
		_poke fade_mask_bw+1, on
		_call stains_play

		_wait music_pattern*16*4+music_pattern*4-1	; /2
		_poke words_tiles_vert_glitch+1,on

// ------------------
/*

		_init mask_bw_inits
		_rnd_screen
		_poke words_t0_glitch_switch+1,on	; 0 - glitch, 1 - static
		_poke mask_bw_fader+1, on
		_poke fade_mask_bw+1, on
		_call mask_unsync
		_wait music_pattern*16*4+music_pattern*4	; /2
		_pal 0, mask_bw_pal_bin
		_poke fade_mask_bw+1, off
		_mask_pos center
		_mask 7
*/		
		
		_init clear_t1

		_pal 0, white_pal
		_pal_layer 0
		_poke mask_bw_fader+1, off
		_poke fade_mask_bw+1, off
		_mask_pos center
		_call mask_unsync
		_mask 7
		_wait music_pattern*16*5-music_pattern*4*2	; /2
		

		_poke words_cur+1, low words_text	; text adress init
		_poke words_cur+2, high words_text

;		_init mask_bw_inits

;		_pal 0, white_pal
		_mask 0
		_mask_pos center-#40
		
		db #ff


int_intro	push af
		push hl
		push de
		push bc
		ld a,(frame_int+1)
		inc a
		ld (frame_int+1),a
		jp line_int_sw_ex

int		push af
		push hl
		push de
		push bc
frame_int	ld a,0
		inc a
		ld (frame_int+1),a
		ld bc,INTMASK
		out (c),a

frames		ld hl,0
		inc hl
		ld (frames+1),hl
frames_wait	ld de,1
		or a
		sbc hl,de
		jp c,en_ex		

en_proc		ld hl,proc_db
		ld a,(hl)
		cp #ff
		jr nz,en_proc0
;		ld hl,(frames+1)
		ld hl,0
		ld (frames+1),hl
		inc l
		ld (frames_wait+1),hl
		ld hl,proc_loop
		ld (en_proc+1),hl
		jr en_proc

en_proc0	or a		; _wait
		jr nz,en_proc1
		call en_pop
;		push hl
		ex de,hl
;cycle_add	ld de,0
;		add hl,de
		ld (frames_wait+1),hl
		ex de,hl
;		pop hl
		jr en_proc_ex

en_proc1	dec a		; _poke
		jr nz,en_proc2
		call en_pop
		ld a,(hl)
		ld (de),a
en_proc_cycle	inc hl
		ld (en_proc+1),hl
		jr en_proc

en_proc2	dec a		; _call
		jr nz,en_proc3
		call en_pop
		ex de,hl
		ld (main_proc+1),hl
		ex de,hl
		jr en_proc_ex

en_proc3	dec a		; _init
		jr nz,en_proc4
		call en_pop	
		ld (en_proc+1),hl
		ex de,hl
		ld (main_proc+1),hl
		jr en_ex

en_proc4	dec a		; _pal
		jr nz,en_proc5
		inc hl
		ld a,(hl)
		call en_pop
		ld (en_proc+1),hl
		call set_pal
		jr en_proc

en_proc5	dec a		; _mask
		jr nz,en_proc6
		inc hl
		ld a,(hl)
		add a
		add a
		add a
		add mask_vpage
		ld bc,VPAGE
		out (c),a
		jr en_proc_cycle

en_proc6	dec a		; _rnd_screen
		jr nz,en_proc7
		ld a,noise_screen_Vid_page
		ld bc,VPAGE
		out (c),a
		jr en_proc_cycle

en_proc7	dec a		; _mask_pos
		jr nz,en_proc8
		call en_pop
		ld bc,GXOFFSL
		out (c),e
		inc b
		out (c),d
		jr en_proc_cycle+1

en_proc8	dec a		; _pal_layer
		jr nz,en_proc9
		inc hl
		ld a,(hl)
		ld de,colorz_glith_pos
1		ld (de),a
		inc e
		jr nz,1b
		jr en_proc_cycle


en_proc9	inc hl
en_proc_ex	ld (en_proc+1),hl

en_ex
		call words
		call noise_screen_unsync
int_ex		ld	hl,30+24
		ld	bc,VSINTL
		out	(c),l
		ld	bc,VSINTH
		out	(c),h
		ld	hl,im_blank_off
		ld	(#beff),hl

line_int_sw_ex	pop bc
		pop de
		pop hl
		pop af
		ei
		ret


en_pop		inc hl
		ld e,(hl)
		inc hl
		ld d,(hl)
		inc hl
en_pop_ex	ret

intro_line_proc
		ex af,af
		exx
		ld a,(hl)
		ld b,high GXOFFSL
		out (c),a
		inc l
		exx
		ex af,af
		ei
		ret

frstartr_line_proc
		ex af,af
		exx
		ld h,high frstartr_glith_pos
		ld a,(hl)
		ld b,high T0XOFFSL
		out (c),a
		inc h
		ld a,(hl)
		ld b,high T1XOFFSL
		out (c),a
;		inc h
		ld b,high GXOFFSL
		out (c),d
		inc d
		inc l
		exx
		ex af,af
		ei
		ret

stains_line_proc
		ex af,af
		exx
		ld h,high frstartr_glith_pos

;		ld a,(hl)
;		ld b,high PALSEL
;		out (c),a
;		dec h
;		dec h
		ld a,(hl)
		ld b,high T0XOFFSL
		out (c),a
		inc l

		ld b,high GXOFFSL
		out (c),d
		inc d
		exx
		ex af,af
		ei
		ret


redmask_line_proc
		ex af,af
		exx
		ld h,high mask_glith_pos+2
		ld a,(hl)
		ld b,high GXOFFSL
		out (c),a
		jr mask_lp_ex

mask_line_proc
		ex af,af
		exx
		ld h,high mask_glith_pos+2
		ld a,(hl)
		ld b,high PALSEL
		out (c),a
mask_lp_ex
		dec h
		ld a,(hl)
t0x_slide	add 0
		ld b,high T0XOFFSL
		out (c),a
		ld a,(hl)
		ld b,high T1XOFFSL
		out (c),a
		dec h
		ld a,(hl)
		ld b,high GYOFFSL
		out (c),a
		inc l
		exx
		ex af,af
		ei
		ret


/*
mask_line_proc
		ex af,af
		exx
		ld h,high mask_glith_pos
		ld a,(hl)
		ld b,high GYOFFSL
		out (c),a
		inc h
		ld a,(hl)
		ld b,high T1XOFFSL
		out (c),a
t0x_slide	add 0
		ld b,high T0XOFFSL
		out (c),a
		inc h
		ld a,(hl)
		ld b,high PALSEL
		out (c),a
		inc l
		exx
		ex af,af
		ei
		ret
*/

/*
		exx
		ld c,low T0XOFFSL
		exx
*/
noise_screen_unsync_line_proc

		ex af,af
		exx
;		ld a,r

;		ld b,high GXOFFSL
;		out (c),a
		ld a,(hl)
		ld b,high T1XOFFSL
		out (c),a

		ld b,high T0XOFFSL
		out (c),a

		inc hl
		exx
		ex af,af
		ei
		ret

words		ld a,1
		dec a
		ld (words+1),a
		ret nz
		ld a,music_pattern/2
		ld (words+1),a
		call clear_words_spr
	
words_cur	ld hl,words_text
		ld a,(hl)
		cp #ff
		jr nz,0f
		inc hl
		ld (words_cur+1),hl

bigword_cnt	ld a,#ff
		inc a
		and 3
		ld (bigword_cnt+1),a
		ld e,0
		bit 0,a
		jr z,bigword1
		ld e,#80
		
bigword1	ld d,#f0
		ld c,alphabet_page		;bank page
		bit 1,a
		jr z,bigword2
		ld d,#d0
		inc c
bigword2	
		ld a,c		; first BigWord sprite #3000, next: #5000
		ld bc,DMASADDRL
		out (c),e
		inc b
		out (c),d
		inc b
		out (c),a

		ld a,#18
		ld b,high DMADADDRL
		out (c),a
		inc b
		ld a,(word_v_pos+1)
		out (c),a
		inc b
		ld a,words_spr_page
		out (c),a

		ld e,224/4-1
		ld b,high DMALEN
		out (c),e
		ld a,32-1	
		ld b,high DMANUM
		out (c),a
		dec b
		ld a,DMA_DALGN+DMA_SALGN+DMA_BLT
		out (c),a
		jp dma_stats


0		push hl
		ld c,#ff
		ld d,0
1		ld a,(hl)
		cp #30
		jr nc,2f
		xor a
		jr 3f

2		sub #60
3		ld ix,alph_width
		ld e,a
		add ix,de
		ld a,(ix+0)
		add c
		ld c,a

		ld a,(hl)
		inc hl
		cp "/"
		jr nz,1b
		srl c
		ld a,320/4
		sub c
		add #4
		ld (word_start_pos+1),a
		pop hl
words_cur1	ld a,(hl)
		inc hl
		ld (words_cur+1),hl
		cp "/"
		ret z

		ld de,#c000		; " " tile num
		cp " "
		jr nz,1f
		ld a,#60
1		sub #60
		cp #10
		jr c,words_cur2
		ld d,#d8		; alphabet row 2
words_cur2	push hl
		ld l,a
		add a,a	; x16 px
		add a,a
		add a,a
		add a,a
		ld e,a

words_cur3
		ld bc,DMASADDRL
		out (c),e
		inc b
		out (c),d
		inc b
		ld a,alphabet_page
		out (c),a
/*
		ld e,(hl)	; width
		inc hl
		ld a,(hl)	; page
		out (c),a

		ld a,320/4
		sub e
;		rla
;		rla 
*/
		ld ix,alph_width
		ld e,l
		ld d,0
		add ix,de

word_start_pos	ld a,0
		ld b,high DMADADDRL
		out (c),a
		ld e,(ix)
		add e
		ld (word_start_pos+1),a

		inc b
word_v_pos	ld a,#c0
		out (c),a
		inc b
		ld a,words_spr_page
		out (c),a
		ld e,8-1
		ld b,high DMALEN
		out (c),e
		ld a,24-1	
		ld b,high DMANUM
		out (c),a
		dec b
		ld a,DMA_DALGN+DMA_SALGN+DMA_BLT
		out (c),a
		call dma_stats
		pop hl
		jr words_cur1

;		  . ,a, b, c, d, e, f, g, h, i, j, k,l, m, n, o, p, q, r, s, t, u, v, w, x,y, z,{-' }-?
alph_width	db 4,12,12,12,12,10,10,12,12,4,10,12,8,16,12,12,12,12,10,12,10,12,10,14,12,8,12, 4, 14
		db 0

words_text	
/*		db "abcdefghij|"
		db 'klmnopqrst|'
		db "uvwxyz|"
*/
;/ Pt.1: Each message is synchronized with the kick beat
;		db "motherfucking/motherfucking/"
		db "hi/hi there/name{s/stan/"
		db "listen/i{m/very/excited/"
		db "i{ve got/this/great/new thing/"
		db "it is/very/cool/i believe/"
		
		db "i hope/you/like it/",#ff
		db "lots of/very/hard/work/"
		db "are/you/actually/listening|/"
		db "is there/anyone/here|/ /"
; Pt.2: Each message is synchronized with the kick beat
		db "strange/it is/so quiet/in here/"
		db "no/no way/i can{t be/alone/"
		db "why/won{t you/say/something|/"
		db "how/hard/can it/be|/"
		
		db "look/i{m really/trying/here/"
		db "you don{t/want me/to go/",#ff
		db "please/don{t/push me/so hard/"
		db "just/say/a word/one word/"

; Pt.3: Each message is synchronized with the kick beat
		db "this/is/not/cool/"
		db "fuck/forget it/forget that/i tried/"
		db "i/should/have known/better/"
		db "you/do not/deserve it/anyway/"
		
		db "all/these/times/i tried/"
		db "you/never/saw me/never/"
		db "heard me/never/listened/",#ff
		db "bloody/joke/how funny/lol/"

; Pt.4: Each message is synchronized with the synths beat

		db "you know/what/fuck/fuck you/"
		db "you/and your/bloody/opinions/"
		db "motherfucking/morons/you/lot/"
		db "shut up/just shut/the fuck/up/"
		
		db "i am/done/with this/shit/"
		db "that{s it/finished/done/",#ff
		db "happy now/are you|/i{m sure/happy/"
		db "thought so/bastards/lame/bastards/"

; Pt.5: Emptyness
		db " / / / /"
		db " / / / /"
		db " / / / /"
		db " / / / /"

		db 0


words_init
		ld hl,#d306	;-#102	; +8
		ld de,#3004
		ld bc,#2605	; 128x160
		ld a,Tile_page
		call tile_filler
		ld hl,#d386	; +8
		ld de,#2004
		ld bc,#2605	; 128x160
		ld a,Tile_page
		call tile_filler
		call clear_words_spr
		ld a,words_spr_page
		ld bc,T0GPAGE
		out (c),a
		inc b
		out (c),a
		call set_Y
		ld a,1
		ld (words_t0_glitch_switch+1),a	; 0 - glitch, 1 - static

;!!!!
		exx
		ld c,low T0XOFFSL
		exx
;!!!!
		ld hl,words_glith_pos	; #c908 tile

		ld a,1
1		ld (hl),a
		inc l
		jr nz,1b
;		ld a,b
;		ld (line_int_sw+1),a
;		ld hl,noise_screen_unsync_line_proc
;		ld (#befd),hl
;		ld hl,logo_pal
;		jp set_ports
		ret

clear_words_spr
		ld bc,PAGE3
		ld a,words_spr_page
		out (c),a
		ld hl,0
		ld (#c000),hl
		ld hl,words_page_clr
		jp set_ports

frstartr_line_init
		call rnd
		push af
		exx
		ld l,0
		pop de
;		ld de,words_glith_pos
		exx

frstartr_line_glitch

		cp #f8
		jr c,frstartr_line_glitch_dec

		call rnd
		and #0f
		inc a
		ld b,a
		ld a,h
		and #7f
		add #20
		ld l,a
		ld h,high frstartr_glith_pos	;+140
		ld e,l
		ld d,h
		dec e
		ld a,b
;		add #10
		bit 4,a
		jr nz,4f
		add #8
		jr 3f
4		sub #8
3		ld (hl),a
		ld (de),a
;		inc a
		dec e
		inc l
		djnz 3b

frstartr_line_glitch_dec
		ld hl,frstartr_glith_pos;+140-#0f
2		ld a,(hl)
		cp #10
		jr c,3f
;		cp #f0
;		jr nc,3f
		dec (hl)
		jr 1f
3		inc (hl)
1		inc l
		jr nz,2b
;		djnz 2b
		ret

frstartr
		call frstartr_line_init
frstartr_tile_glitch_count
		ld a,music_pattern/2
		dec a
		ld (frstartr_tile_glitch_count+1),a
		or a
		jr nz,frstartr_in
		ld a,music_pattern/2
		ld (frstartr_tile_glitch_count+1),a

		ld a,Tile_page
		ld bc,PAGE3
		out (c),a

		call rnd	; 248 x 164 / 1f x 14
/*
rnd:		ld de,#0d52
rnd:		ld hl,#b20c


		ld hl,#c40c		; 248x164
		ld de,#0000
		ld bc,#1f15
*/		
		and #0f
		add a	;#7c
		add #0c
		ld l,a
		ld a,h
		and #0f
		add #c4
		ld h,a
;		push hl
;		call rnd
		ld a,e
		and #3e	;7c
;		add a
;		add #0c
		ld e,a
		ld a,d
		and #1f
		add #c0
		ld d,a

		ld a,h
		and #0f
		inc a
		ld b,a
		ld a,l
		and #0f
		inc a
		ld c,a
;		pop hl


2		push bc
		push de
		push hl
1		dup 2
		ld a,(hl)
		ld (de),a
		inc hl
		inc de
		edup
		bit 7,e
		jr nz,3f
		djnz 1b
3		pop hl
		pop de
		pop bc
		inc h
		inc d
		dec c
		jr nz,2b


/*		
;		ld b,#10
1		ld a,(hl)
		xor #f
		ld (hl),a
		inc l
		inc l
		bit 7,l
		jr z,1b
*/





frstartr_in	ld a,0
		inc a
		and 3
		ld (frstartr_in+1),a
		ret nz

frstartr_cnt	ld a,24-1
		inc a
		cp 24
		jr nz,1f
		ld a,frstartr_page-1
		ld (frstartr_frame_page+1),a
		ld hl,#c000-20336+16384
		ld (frstartr_frame_adr+1),hl
		xor a
1		ld (frstartr_cnt+1),a

frstartr_frame_adr
		ld hl,0
frstartr_frame_page
		ld a,0

		ld de,20336-16384
		add hl,de
		jr nc,2f
		set 6,h
		set 7,h
		inc a
2		inc a
		ld (frstartr_frame_adr+1),hl
		ld (frstartr_frame_page+1),a
		ld bc,DMASADDRX
		out (c),a
		dec b
		out (c),h
		dec b
		out (c),l
		ld hl,frstartr_set_dma
		call set_ports
		ret

frstartr_set_dma
;		db #1a,0	;1
;	        db #1b,0	;3
;		db #1c,0	;5
	        db #1d,4;18	;7
	        db #1e,0;38	;9
	        db #1f,Tilegfx_temp_page
	        db #26,248/4-1	
	        db #28,164-1
		db #27,DMA_RAM + DMA_DALGN	;DMA_RAM + DMA_DALGN + DMA_SALGN	;
		db #ff

or_palsel	or #10	; 4 frstartr_pal
set_palsel	ld bc,PALSEL
		out (c),a
		ret

frstartr_init
		ld hl,frstartr_line_proc
		ld (#befd),hl

		call set_Y
		exx
		ld l,0
		exx
		/*
mask_glith_pos		equ #7d00
words_glith_pos		equ #7e00
frstartr_glith_pos	equ mask_glith_pos
*/
		ld hl,frstartr_glith_pos
		ld de,frstartr_glith_pos+1
		ld bc,#ff
		ld a,#10
		ld (hl),a
		ldir
		call cls
		xor a
		call or_palsel
		xor a
		ld (words_t0_glitch_switch+1),a	; 0 - glitch, 1 - static

		ld a,Tilegfx_temp_page
		ld bc,T0GPAGE
		out (c),a

		call clear_t0
		ld hl,#c40c		; 248x164
		ld de,#0000
		ld bc,#1f15
		ld a,Tile_page
		jp tile_filler


cls		ld bc,PAGE3
		ld a,Vid_page
		out (c),a
		ld hl,#0		;1111 - white
		ld (#c000),hl
		ld hl,clr_screen
		jp set_ports		

stains_play	
		call rnd
		exx
		ld d,a
		ld l,0
		exx
		call frstartr_line_glitch

stains_cnt	ld a,1
		dec a
		and 3		;	3 / 7?
		ld (stains_cnt+1),a
		jp nz,stains_ex
;		ld a,music_pattern/#10
;		ld (stains+1),a
		call rnd
		ld c,a
		and #c0
		ld l,a
		ld ix,stain_set_dma
		ld h,#c0	; stain_adr
		ld a,c
		and 3
		add stains_page
		ld (ix+1),l
		ld (ix+3),h
		ld (ix+5),a
		call rnd
		ld a,l
		and #fe

		ld (ix+7),a
		ld a,h
		or #c0
		ld (ix+9),a

		ld a,h
		and 3
		add Stains_gfx_temp_page
		ld (ix+#b),a ;tilegfx page
		ld hl,stain_set_dma
		call set_ports
stains_ex	jp frstartr_in


stain_set_dma
		db #1a,0	;1
	        db #1b,0	;3
		db #1c,0	;5
	        db #1d,0	;7
	        db #1e,0	;9
	        db #1f,0	;b
	        db #26,128/4-1	
	        db #28,64-1
		db #27,DMA_BLT + DMA_DALGN + DMA_SALGN	;DMA_RAM + DMA_DALGN + DMA_SALGN	;
		db #ff
		

mask_unsync	ld a,music_pattern*2-1
		inc a
		ld (mask_unsync+1),a
		exx
		ld l,0
		exx
		cp music_pattern*2
		jr nz,fade_mask_bw
;		ld a,music_pattern*2
		xor a
		ld (mask_unsync+1),a
mask_glitch_init
		ld ix,mask_glith_pos
		ld b,240
1		call rnd
glitch_level	and #3f
m_bw_glitch	add 0
		ld (ix+0),a
		inc ix
		djnz 1b
		ld a,h
		ld (m_bw_glitch+1),a
		ret


fade_mask_bw	ld a,0		; 1- MASSIVE glitch
		or a
		jr z,4f

fade_mask_bw_cnt
		ld a,#ff
		inc a
		ld (fade_mask_bw_cnt+1),a
;		and #3f
;		cp #2e

		cp #30
		jr nz,4f
		xor a
		ld (fade_mask_bw_cnt+1),a
		ld hl,mask_glith_pos
		ld b,#f0
5		ld a,(hl)
		cpl
		ld (hl),a
		inc l
		djnz 5b
4
		ld hl,mask_glith_pos
		ld a,0

2		cp (hl)
		jr z,1f
		jr nc,3f
		dec (hl)
		jr 1f
3		inc (hl)

1		inc l
		inc a
		cp 240
		jr nz,2b

red_heat_switch	ld a,0
		or a
		jr z,mask_bw_fader
		call rnd
		ld hl,colorz_glith_pos
		ld d,high faded_sin
		ld e,a
6		ld a,(de)
red_heat_level	and 1
		ld (hl),a
		inc e
		inc l
		jr nz,6b


mask_bw_fader	ld a,0
		or a
		ret z
		ld a,(mask_unsync+1)
;		cp #40
;		jr c,5f
;		call rnd
5		ld hl,colorz_glith_pos
		ld d,high faded_sin
		ld e,a
4		ld a,(de)
		ld (hl),a
		inc e
		inc l
		jr nz,4b

		ret


set_Y		xor a
		ld bc,T0YOFFSL
		out (c),a
		ld b,high T1YOFFSL
		out (c),a
		ld b,high GYOFFSL
		out (c),a
		ld b,high GXOFFSL
		out (c),a
		ret

mask_red_inits
		ld hl,redmask_line_proc
		call mask_bw_inits_ex

		ld a,1
		call set_palsel
		ld (fade_mask_bw+1),a
		call clear_t0_words
		call set_Y
		jp mask_glitch_init

mask_bw_inits
		ld hl,0
		call clear_tileset
		call words_init
		ld hl,mask_line_proc
		call mask_bw_inits_ex
		xor a
		call set_palsel

;		call cls		

;		call clear_t0_words 
		call set_Y
		ret

mask_bw_inits_ex
		ld (#befd),hl
		exx
		ld l,0
		exx
		ld hl,mask_glith_pos	; #c908 tile
1		ld (hl),l
		inc l
		jr nz,1b
		inc h
		ld a,1
1		ld (hl),a
		inc l
		jr nz,1b
;		ld a,music_pattern*2-1
;		ld (mask_unsync+1),a
		ld a,#ff
		ld (fade_mask_bw_cnt+1),a

;		ld de,mask_glith_pos+1
;		ld bc,#0ff
;		ld (hl),e
;		ldir

		ret

stains_init
;		ld hl,stains_pal
;		call set_ports
;		call mask_bw_inits_ex		
		ld hl,stains_line_proc
		ld (#befd),hl
		ld a,#10
		ld bc,T0XOFFSL
		out (c),a

		ld bc,T1YOFFSL
		xor a
		out (c),a		
		ld a,#40
		call or_palsel		
		ld a,Stains_gfx_temp_page
		ld bc,T1GPAGE
		out (c),a
		ld hl,frstartr_glith_pos
		ld de,frstartr_glith_pos+1
		ld bc,#ff
		ld a,#10
		ld (hl),a
		ldir
		ld hl,#c080
		ld de,#1000
		ld bc,#281e	
		ld a,Tile_page
		call tile_filler
		ret
;		jp clear_tilegfx

clear_tilegfx	ld bc,PAGE3
		out (c),a
		ld (tilegfx_clr_p2+1),a
		ld (tilegfx_clr_p1+1),a
		ld hl,0
		ld (#c000),hl
		ld hl,tilegfx_clr
		jp set_ports

clear_t0_words  call clear_t0
		ld a,words_spr_page
		ld bc,T0GPAGE
		out (c),a
		inc b
		out (c),a

		ld hl,#d308	;-#102	; +8
		ld de,#3004
		ld bc,#2405	; 128x160
		ld a,Tile_page
		jp tile_filler
		

clear_t0	ld bc,PAGE3
		ld a,Tile_page
		out (c),a
		ld hl,#c000
		ld c,#20
		xor a
2		ld b,#40
1		ld (hl),a
		inc l
		ld (hl),a
		inc l
		djnz 1b
		ld l,0
		inc h
		dec c
		jr nz,2b
		ret

clear_t1	ld bc,PAGE3
		ld a,Tile_page
		out (c),a
		ld hl,#c080
		ld c,#20
		xor a
4		ld b,#40
3		ld (hl),a
		inc l
		ld (hl),a
		inc l
		djnz 3b
		ld l,#80
		inc h
		dec c
		jr nz,4b
		ld a,Stains_gfx_temp_page
		call clear_tilegfx
		call mask_bw_inits
		jp mask_glitch_init

noise_screen_unsync
cnt1		ld a,#30/2+6
		dec a
		ld (cnt1+1),a
		call z,rnd_logo_gen

		call rnd
		ld e,a


words_tiles_vert_glitch
		ld a,0
		or a
		jr z,5f		; 0 - glitch, 1 - static

words_t0_glitch_switch		; 0 - glitch, 1 - static
		ld a,0
		or a
		jr z,words_t1_glitch_switch		
		ld a,e
		and 3
		add 3
		ld bc,T0YOFFSL
		out (c),a
		ld (t0x_slide+1),a

words_t1_glitch_switch
		ld a,0
		or a
		jr z,5f	
		ld a,e
		rra
		and 3
		ld bc,T1YOFFSL
		out (c),a

5		exx
		ld de,words_glith_pos
		exx
		ld hl,words_glith_pos+#13*8-4	; #c908 tile
		ld b,40
2		dec (hl)
		jr nz,3f
		inc (hl)
3		inc hl
		djnz 2b
		ret

noise_screen_inits
		ld hl,logo_pal_bin	;mask_bw_pal_bin	;
		ld de,logo_shade
		ld b,16
1		ld a,(hl)
		and #0f
		ld (de),a
		inc hl
		inc de
		ld a,(hl)
		and #2c
		ld (de),a
		inc hl
		inc de
		djnz 1b
;		ld hl,logo_copy
;		call set_ports
;		ld hl,logo_pal
;		call set_ports

		call fill_noise_screen

;		ld a,Tile_page
;		ld bc,PAGE3
;		out (c),a

		ld hl,#c908	; +8
		ld de,#1001
		ld bc,#2005	; 128x160
		ld a,Tile_page
		call tile_filler
		ld hl,#c988	; +8
		ld de,#0001
		ld bc,#2005	; 128x160
		ld a,Tile_page
		call tile_filler
		exx
		ld c,low T0XOFFSL
		exx
;		ld a,b
;		ld (line_int_sw+1),a
		ld hl,noise_screen_unsync_line_proc
		ld (#befd),hl
		ret

rnd_logo_gen	
		ld a,#ff
		cpl 
		ld (rnd_logo_gen+1),a
		ld c,(#10-8)*6
		or a
		jr z,rlg1
		ld c,8*6
rlg1		ld a,c
		ld (cnt1+1),a

		ld ix,words_glith_pos+#13*8-4	; #c908 tile
		ld b,40
1		call rnd
		and #0f
		add #0c
		inc a
		ld (ix+0),a
		inc ix
		djnz 1b
		ret


im_blank_off
		di
		push af
		push bc
		push hl
		ld bc,INTMASK
		ld a,3
		out (c),a

;		ld hl,31+24+240
		ld hl,31+24+240
		ld bc,VSINTL
		out (c),l
		ld bc,VSINTH
		out (c),h
		ld hl,im_blank_ex
		ld (#beff),hl		
		pop hl
		pop bc
		pop af
		ei
		ret

im_blank_ex
		di
		push af
		push bc
		push de
		push hl
		xor a
		ld bc,VSINTL
		out (c),a
		ld bc,VSINTH
		out (c),a
		inc a
		ld bc,INTMASK
		out (c),a

		ld hl,int
		ld (#beff),hl		

		ld a,mus_page
		ld bc,PAGE3
		out (c),a
		call #c000+5	
cur_page	ld a,0	
		ld bc,PAGE3
		out (c),a

		pop hl
		pop de
		pop bc
		pop af
		ei
		ret


mask_vpages_init
; clear vpages for mask

		ld bc,PAGE3
		ld a,mask_vpage
		out (c),a
		ld hl,0
		ld (#c000),hl
		ld hl,vpages_clr
		call set_ports
		ld e,8
1		ld b,#27
		ld a,%00000100
		out (c),a
		call dma_stats
		dec e
		jr nz,1b

		ld hl,mask_red_copy
		call set_ports
		ld hl,mask_phone_copy
		call set_ports

		ld bc, DMASADDRL
		xor a
		out (c),a
		inc b
		out (c),a
		inc b
		ld a,mask_pics_page
		out (c),a

		ld hl,mask_db
		exa
		ld a,6
2		exa
		ld d,(hl)	; width
		inc hl
		ld a,320/4
		sub d
		ld b,high DMADADDRL
		out (c),a
		inc b
		xor a
		out (c),a
		inc b
mask_vpage_cnt	ld a,mask_vpage
		out (c),a
;		ld b,high VPAGE
;		out (c),a
		add 8
		ld (mask_vpage_cnt+1),a
		dec d
		ld b,high DMALEN
		out (c),d
		ld a,(hl)	; height
		inc hl
		dec a
		ld b,high DMANUM
		out (c),a
		dec b
		ld a,DMA_DALGN+DMA_RAM
		out (c),a
		call dma_stats

		exa
		dec a
		jr nz,2b
		exa

fill_noise_screen
		ld a,noise_screen_Vid_page
fill_rnd0	ld bc,PAGE3
		out (c),a
		push af
		ld hl,#c000
		ld c,#33
fill_rnd	push hl
		call rnd
		pop hl
		ld a,e
		and c
		ld (hl),a
		inc l
		ld a,d
		and c
		ld (hl),a
		inc hl
		ld a,h
		or a
		jr nz,fill_rnd
		pop af
		inc a
		cp noise_screen_Vid_page+4	;16
		jr nz,fill_rnd0
		ret

		; width/height
mask_db		db 232/4,214,  240/4,220,  248/4,224,  260/4,228,  268/4,232,  276/4,240


wait_frame	ld a,(frame_int+1)
		or a
		jr z,wait_frame
		dec a
		ld (frame_int+1),a
		ret


all_init	
		ld hl,0
		call clear_tileset
		ld a,Tilegfx_temp_page
		call clear_tilegfx
		ld a,Stains_gfx_temp_page
		call clear_tilegfx
; Ìכ.באיע: gggB Bbbb
; Ñע.באיע: 0RRr rrGG - Ìכ.באיע: gggB Bbbb
		ld hl,logo_pal_bin	;mask_bw_pal_bin	;
		ld de,logo_shade
		ld b,16
1		ld a,(hl)
		ld a,%01000010
;		and #00		; #0f
		ld (de),a
		inc hl
		inc de
		ld a,(hl)
		ld a,%00001000
;		and #ff-#10		; #2c
		ld (de),a
		inc hl
		inc de
		djnz 1b
		ld hl,all_pals
		call set_ports
		ld bc,PAGE3
		ld a,Vid_page
		out (c),a
		ld hl,#0		;1111 - white
		ld (#c000),hl
		ld hl,init_ts
		jp set_ports

set_pal		or a	; a: pal_number, de: palitra, 32 bytes
		rla
		rla
		rla
		rla
		ld (set_pal_by_num+7),a
		ld hl,set_pal_by_num+1
		ld (hl),e
		inc hl
		inc hl
		ld (hl),d
		ld hl,set_pal_by_num
		jp set_ports

set_pal_by_num
		db #1a,0
	        db #1b,0
		db #1c,2
	        db #1d,0
	        db #1e,0
	        db #1f,0
	        db #26,#10
	        db #28,0
		db #27,#84
		db #ff

init_ts		db #00,VID_16C+VID_320X240 ;VID_NOGFX+
		db #01,Vid_page	;VPAGE
		db #20,6	; SYSCONFIG
		db #0f,0	; border
		db high TSCONFIG,TSU_T0EN+TSU_T1EN;+TSU_T0ZEN +TSU_T1ZEN		; TSConfig
		db 7,6; 0 	; palsel
		db high TMPAGE, Tile_page
		db high T0GPAGE,Tile0_spr_page
		db high T1GPAGE,Tile0_spr_page

		db high T1YOFFSL,0
		db high T0XOFFSL,0
clr_screen
		defb #1a,0	;
		defb #1b,0	;
		defb #1c,Vid_page	;
		defb #1d,0	;
		defb #1e,0	;
		defb #1f,Vid_page	;

		defb #28,200	;
		defb #26,#ff	;
		defb #27,%00000100

		db #ff

vpages_clr
		defb #1a,0	;
		defb #1b,0	;
		defb #1c,mask_vpage	;
		defb #1d,0	;
		defb #1e,0	;
		defb #1f,mask_vpage	;
		defb #28,#ff	;
		defb #26,#ff	;
		defb #27,%00000100
		db #ff

tilegfx_clr
		defb #1a,0	;
		defb #1b,0	;
tilegfx_clr_p1	defb #1c,Tilegfx_temp_page
		defb #1d,0	;
		defb #1e,0	;
tilegfx_clr_p2	defb #1f,Tilegfx_temp_page
		defb high DMANUM,#7f	; 4 pages clear; #1f - 1 page
		defb high DMALEN,#ff	;
		defb #27,%00000100
		db #ff
tileset_clr
		defb #1a,0	;
		defb #1b,0	;
		defb #1c,Tile_page	;
		defb #1d,0	;
		defb #1e,0	;
		defb #1f,Tile_page	;
		defb #28,#ff	;
		defb #26,#1f	;
		defb #27,%00000100
		db #ff

all_pals
		db #1a,low all_pal_bin
	        db #1b,high all_pal_bin
		db #1c,2
	        db #1d,0
	        db #1e,0
	        db #1f,0
	        db #26,#ff
	        db #28,0
		db #27,#84
		db #ff

mask_red_copy
		db #1a,low mask_red_pic
	        db #1b,high mask_red_pic
		db #1c,mask_red_page
;	        db #1d,0
;	        db #1e,0
	        db #1f,mask_vpage+6*8
	        db #26,320/4-1
	        db #28,240-1
		db #27,DMA_RAM + DMA_DALGN
		db #ff

mask_phone_copy
		db #1a,low mask_phone_pic
	        db #1b,high mask_phone_pic
		db #1c,mask_phone_page
	        db #1d,19
	        db #1e,0
	        db #1f,mask_vpage+7*8
	        db #26,244/4-1
	        db #28,240-1
		db #27,DMA_RAM + DMA_DALGN
		db #ff
im2_init	
		xor a	
		ld bc,HSINT
		out (c),a
		ld bc,VSINTL
		out (c),a
		ld bc,VSINTH
		out (c),a
		ld e,7
		ld b,#40
		out (c),a
		inc b
		dec e
		jr nz,$-4
		call spr_off
		ld a,#be
		ld i,a
		ld hl,int_intro
		ld (#beff),hl
		im 2
		ret


words_page_clr
		db #1a,0
		db #1b,0
		db #1c,words_spr_page
		db #1d,0
		db #1e,0
		db #1f,words_spr_page
		db high DMANUM,40-1
		db high DMALEN,340/4-1
		db #27,%00010100
		db #ff

logo_adr	equ #E8C8
intro2
		db #1a,low logo_adr
	        db #1b,high logo_adr
		db #1c,intro_page
	        db #1d,4
	        db #1e,#0a
	        db #1f,Vid_page+1
	        db #26,304/4-1
	        db #28,46-1
		db #27,DMA_RAM + DMA_DALGN
		db #ff

intro1
		db #1a,0
	        db #1b,0
		db #1c,intro_page
	        db #1d,0
	        db #1e,#0a
	        db #1f,Vid_page
	        db #26,320/4-1
	        db #28,27-1
		db #27,DMA_RAM + DMA_DALGN
		db #ff

intro3
;		db #1a,0
;		db #1b,0
;		db #1c,intro_page
	        db #1d,0
	        db #1e,#0a
	        db #1f,Vid_page+2
	        db #26,320/4-1
	        db #28,30-1
		db #27,DMA_RAM + DMA_DALGN
		db #ff


intro4
;		db #1a,0
;		db #1b,0
;		db #1c,intro_page
	        db #1d,#80
	        db #1e,#0
	        db #1f,Vid_page+3
	        db #26,60/4-1
	        db #28,44-1
		db #27,DMA_RAM + DMA_DALGN
		db #ff

			align 2

all_pal_bin
; palsel 
mask_bw_pal_bin		incbin "_spg/mask.tga.pal"
mask_red_pal_bin	incbin "_spg/mask_red.tga.pal"
logo_pal_bin		incbin "_spg/logo.tga.pal"
logo_shade		ds 32

; palsel 
frstrtr_pal_bin 	incbin "_spg/f_red_pal.tga.pal"
stains_pal_bin 		incbin "_spg/stains.tga.pal"
intro_pal_bin 		incbin "_spg/intro.tga.pal"
white_pal		incbin "_spg/maskw.tga.pal"

faded_pals		incbin "_spg/mask.tga.pal"
			ds 256-32

			align 256
faded_sin		incbin "_spg/faded_sin.bin"

			include "includes.asm"
			include "tsconfig.asm"
end
	SAVEBIN "_spg/unhinged.bin",start, end-start