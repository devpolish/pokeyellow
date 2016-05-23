PlayerStepOutFromDoor: ; 1a3e0 (6:63e0)
	ld hl, wd730
	res 1, [hl]
	call IsPlayerStandingOnDoorTile
	jr nc, .notStandingOnDoor
	ld a, $fc
	ld [wJoyIgnore], a
	ld hl, wd736
	set 1, [hl]
	ld a, $1
	ld [wSimulatedJoypadStatesIndex], a
	ld a, D_DOWN
	ld [wSimulatedJoypadStatesEnd], a
	xor a
	ld [wSpriteStateData1 + 2], a
	call StartSimulatingJoypadStates
	ret
.notStandingOnDoor
	xor a
	ld [wWastedByteCD3A], a
	ld [wSimulatedJoypadStatesIndex], a
	ld [wSimulatedJoypadStatesEnd], a
	ld hl, wd736
	res 0, [hl]
	res 1, [hl]
	ld hl, wd730
	res 7, [hl]
	ret

_EndNPCMovementScript: ; 1a527 (6:6527)
	ld hl, wd730
	res 7, [hl]
	ld hl, wd72e
	res 7, [hl]
	ld hl, wd736
	res 0, [hl]
	res 1, [hl]
	xor a
	ld [wNPCMovementScriptSpriteOffset], a
	ld [wNPCMovementScriptFunctionNum], a
	ld [wNPCMovementScriptPointerTableNum], a
	ld [wWastedByteCD3A], a
	ld [wSimulatedJoypadStatesIndex], a
	ld [wSimulatedJoypadStatesEnd], a
	ret

PalletMovementScriptPointerTable: ; 1a54c (6:654c)
	dw PalletMovementScript_OakMoveLeft
	dw PalletMovementScript_PlayerMoveLeft
	dw PalletMovementScript_WaitAndWalkToLab
	dw PalletMovementScript_WalkToLab
	dw PalletMovementScript_Done

PalletMovementScript_OakMoveLeft: ; 1a556 (6:6556)
	ld a, [wXCoord]
	sub $a
	ld [wNumStepsToTake], a
	jr z, .playerOnLeftTile
; The player is on the right tile of the northern path out of Pallet Town and
; Prof. Oak is below.
; Make Prof. Oak step to the left.
	ld b, 0
	ld c, a
	ld hl, wNPCMovementDirections2
	ld a, NPC_MOVEMENT_LEFT
	call FillMemory
	ld [hl], $ff
	ld a, [wSpriteIndex]
	ld [H_SPRITEINDEX], a
	ld de, wNPCMovementDirections2
	call MoveSprite
	ld a, $1
	ld [wNPCMovementScriptFunctionNum], a
	jr .done
; The player is on the left tile of the northern path out of Pallet Town and
; Prof. Oak is below.
; Prof. Oak is already where he needs to be.
.playerOnLeftTile
	ld a, $3
	ld [wNPCMovementScriptFunctionNum], a
.done
	ld a, BANK(Music_MuseumGuy)
	ld c, a
	ld a, MUSIC_MUSEUM_GUY
	call PlayMusic
	ld hl, wFlags_D733
	set 1, [hl]
	ld a, $fc
	ld [wJoyIgnore], a
	ret

PalletMovementScript_PlayerMoveLeft: ; 1a597 (6:6597)
	ld a, [wd730]
	bit 0, a ; is an NPC being moved by a script?
	ret nz ; return if Oak is still moving
	ld a, [wNumStepsToTake]
	ld [wSimulatedJoypadStatesIndex], a
	ld [hNPCMovementDirections2Index], a
	predef ConvertNPCMovementDirectionsToJoypadMasks
	call StartSimulatingJoypadStates
	ld a, $2
	ld [wNPCMovementScriptFunctionNum], a
	ret

PalletMovementScript_WaitAndWalkToLab: ; 1a5b3 (6:65b3)
	ld a, [wSimulatedJoypadStatesIndex]
	and a ; is the player done moving left yet?
	ret nz

PalletMovementScript_WalkToLab: ; 1a5b8 (6:65b8)
	xor a
	ld [wOverrideSimulatedJoypadStatesMask], a
	ld a, [wSpriteIndex]
	swap a
	ld [wNPCMovementScriptSpriteOffset], a
	xor a
	ld [wSpriteStateData2 + $06], a
	ld hl, wSimulatedJoypadStatesEnd
	ld de, RLEList_PlayerWalkToLab
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	ld hl, wNPCMovementDirections2
	ld de, RLEList_ProfOakWalkToLab
	call DecodeRLEList
	ld hl, wd72e
	res 7, [hl]
	ld hl, wd730
	set 7, [hl]
	ld a, $4
	ld [wNPCMovementScriptFunctionNum], a
	ret


RLEList_ProfOakWalkToLab: ; 1a5ee (6:65ee)
	db NPC_MOVEMENT_DOWN, $06 ; differs from red
	db NPC_MOVEMENT_LEFT, $01
	db NPC_MOVEMENT_DOWN, $05
	db NPC_MOVEMENT_RIGHT, $03
	db NPC_MOVEMENT_UP, $01
	db $E0, $01 ; stand still
	db $FF

RLEList_PlayerWalkToLab: ; 1a5fb (6:65fb)
	db D_UP, $02
	db D_RIGHT, $03
	db D_DOWN, $05
	db D_LEFT, $01
	db D_DOWN, $07 ; differs from red
	db $FF

PalletMovementScript_Done: ; 1a606 (6:6606)
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	ld a, $0
	ld [wMissableObjectIndex], a
	predef HideObject
	ld hl, wd730
	res 7, [hl]
	ld hl, wd72e
	res 7, [hl]
	jp EndNPCMovementScript

PewterMuseumGuyMovementScriptPointerTable: ; 1a622 (6:6622)
	dw PewterMovementScript_WalkToMuseum
	dw PewterMovementScript_Done

PewterMovementScript_WalkToMuseum: ; 1a626 (6:6626)
	ld a, BANK(Music_MuseumGuy)
	ld c, a
	ld a, MUSIC_MUSEUM_GUY
	call PlayMusic
	ld a, [wSpriteIndex]
	swap a
	ld [wNPCMovementScriptSpriteOffset], a
	call StartSimulatingJoypadStates
	ld hl, wSimulatedJoypadStatesEnd
	ld de, RLEList_PewterMuseumPlayer
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	xor a
	ld [wWhichPewterGuy], a
	call PewterGuys
	ld hl, wNPCMovementDirections2
	ld de, RLEList_PewterMuseumGuy
	call DecodeRLEList
	ld hl, wd72e
	res 7, [hl]
	ld a, $1
	ld [wNPCMovementScriptFunctionNum], a
	ret

RLEList_PewterMuseumPlayer: ; 1a661 (6:6661)
	db 0, $01
	db D_UP, $03
	db D_LEFT, $0D
	db D_UP, $06
	db $FF

RLEList_PewterMuseumGuy: ; 1a66a (6:666a)
	db NPC_MOVEMENT_UP, $06
	db NPC_MOVEMENT_LEFT, $0D
	db NPC_MOVEMENT_UP, $03
	db NPC_MOVEMENT_LEFT, $01
	db $FF

PewterMovementScript_Done: ; 1a673 (6:6673)
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	ld hl, wd730
	res 7, [hl]
	ld hl, wd72e
	res 7, [hl]
	jp EndNPCMovementScript

PewterGymGuyMovementScriptPointerTable: ; 1a685 (6:6685)
	dw PewterMovementScript_WalkToGym
	dw PewterMovementScript_Done

PewterMovementScript_WalkToGym: ; 1a689 (6:6689)
	ld a, BANK(Music_MuseumGuy)
	ld c, a
	ld a, MUSIC_MUSEUM_GUY
	call PlayMusic
	ld a, [wSpriteIndex]
	swap a
	ld [wNPCMovementScriptSpriteOffset], a
	xor a
	ld [wSpriteStateData2 + $06], a
	ld hl, wSimulatedJoypadStatesEnd
	ld de, RLEList_PewterGymPlayer
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	ld a, 1
	ld [wWhichPewterGuy], a
	call PewterGuys
	ld hl, wNPCMovementDirections2
	ld de, RLEList_PewterGymGuy
	call DecodeRLEList
	ld hl, wd72e
	res 7, [hl]
	ld hl, wd730
	set 7, [hl]
	ld a, $1
	ld [wNPCMovementScriptFunctionNum], a
	ret

RLEList_PewterGymPlayer: ; 1a6cb (6:66cb)
	db 0, $01
	db D_RIGHT, $02
	db D_DOWN, $05
	db D_LEFT, $0B
	db D_UP, $05
	db D_LEFT, $0F
	db $FF

RLEList_PewterGymGuy: ; 1a6cd8(6:66d8)
	db NPC_MOVEMENT_DOWN, $02
	db NPC_MOVEMENT_LEFT, $0F
	db NPC_MOVEMENT_UP, $05
	db NPC_MOVEMENT_LEFT, $0B
	db NPC_MOVEMENT_DOWN, $05
	db NPC_MOVEMENT_RIGHT, $03
	db $FF

INCLUDE "engine/overworld/pewter_guys.asm"
