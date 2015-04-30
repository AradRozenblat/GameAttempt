.486 ; create 32 bit code
.model flat, stdcall ; 32 bit memory model
option casemap :none ; case sensitive

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\gdi32.inc
include \masm32\include\Advapi32.inc
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib
include \masm32\include\dialogs.inc ; macro file for dialogs
include \masm32\macros\macros.asm ; masm32 macro file
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\Comctl32.lib
includelib \masm32\lib\comdlg32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\oleaut32.lib
includelib \masm32\lib\ole32.lib
includelib \masm32\lib\msvcrt.lib
 
.const
MAIN_TIMER_ID equ 0
MYD	equ	5

REALWIDTH equ WINDOW_WIDTH+15
REALHEIGHT equ WINDOW_HEIGHT+40
WINDOW_WIDTH equ 1000
WINDOW_HEIGHT equ 750
RIGHT equ 1
DOWN equ 2
LEFT equ 3
UP  equ 4
STOP equ 5

SPEED equ MYD
BOOST equ MYD*2

FACING1 equ 3
FACING2 equ 1
VERTICAL1 equ 0
HORIZONTAL1 equ 1
VERTICAL2 equ 0
HORIZONTAL2 equ 1

STARTX1 equ (WINDOW_WIDTH/MYD*3/4)
STARTY1 equ (WINDOW_HEIGHT/MYD/2)
STARTX2 equ (WINDOW_WIDTH/MYD*1/4)
STARTY2 equ (WINDOW_HEIGHT/MYD/2)

GAME equ 1
SETTINGS equ 2
START equ 3
COLOR1 equ 4
COLOR1CHOSE equ 5
COLOR2 equ 6
COLOR2CHOSE equ 7
PAUSING equ 8
ENDING equ 9
EXITING equ 10
HELPING equ 11
CREDITS equ 12

REG1 equ 1
DARK1 equ 3
REG2 equ 2
DARK2 equ 4

BOOSTS1 equ 3
BOOSTS2 equ 3

.data

Player STRUCT
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	id dd ?
	color dd ?
	x dd ?
	y dd ?
	speed dd ?
	facing dd ?
	vertical db ?
	horizontal db ?
	boosts db ?
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Player ENDS

Color1 DWORD 000000ff0000h
Color2 DWORD 0000000000ffh
Darker1 DWORD ?
Darker2 DWORD ?
P1 Player <1, Color1, STARTX1, STARTY1, SPEED, LEFT, 0, 1, BOOSTS1>
P2 Player <2, Color2, STARTX2, STARTY2, SPEED, RIGHT, 0, 1, BOOSTS2>
ClassName DB "TheClass",0
windowTitle DB "TRON: REASSEMBLED",0
backupecx	DWORD	?
grid DB WINDOW_WIDTH/MYD*WINDOW_HEIGHT/MYD dup(0)
GameBMH HBITMAP ?
OptionsBMH HBITMAP ?
StartBMH HBITMAP ?
PausingBMH HBITMAP ?
EndingBMH HBITMAP ?
status DWORD START
LastKey1 DWORD ?
LastKey2 DWORD ?
NowKey1 DWORD ?
NowKey2 DWORD ?
LastTime1 DWORD ?
LastTime2 DWORD ?
NowTime1 DWORD ?
NowTime2 DWORD ?
BoostTime1 DWORD ?
BoostTime2 DWORD ?
Selected DWORD 1
 
.code

DrawBG PROC, mystatus:DWORD, myrect:RECT, myhdc:HDC, hWnd:HWND
;----------------------------------------------------------------------------
	local mem_hdc:HDC
	local OldHandle:HBITMAP

	invoke CreateCompatibleDC, myhdc
	mov mem_hdc, eax

	cmp mystatus, GAME
	je gamedraw
	cmp mystatus, START
	je startdraw
	cmp mystatus, SETTINGS
	je optionsdraw
	cmp mystatus, PAUSING
	je pausingdraw
	cmp mystatus, ENDING
	je endingdraw
	invoke ExitProcess, 0

gamedraw:
	invoke SelectObject, mem_hdc, GameBMH
	mov OldHandle, eax
	invoke GetClientRect, hWnd, addr myrect
	;invoke StretchBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, 3944, 2245, SRCCOPY
	invoke BitBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, SRCCOPY			   ;first zeroes are dest and second zeroes are src
	invoke SelectObject, mem_hdc, OldHandle
	invoke DeleteDC, mem_hdc
	ret

startdraw:
	invoke SelectObject, mem_hdc, StartBMH
	mov OldHandle, eax
	invoke GetClientRect, hWnd, addr myrect
	;invoke StretchBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, 3944, 2245, SRCCOPY
	invoke BitBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, SRCCOPY			   ;first zeroes are dest and second zeroes are src
	invoke SelectObject, mem_hdc, OldHandle
	invoke DeleteDC, mem_hdc
	ret

optionsdraw:
	invoke SelectObject, mem_hdc, OptionsBMH
	mov OldHandle, eax
	invoke GetClientRect, hWnd, addr myrect
	;invoke StretchBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, 3944, 2245, SRCCOPY
	invoke BitBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, SRCCOPY			   ;first zeroes are dest and second zeroes are src
	invoke SelectObject, mem_hdc, OldHandle
	invoke DeleteDC, mem_hdc
	ret

pausingdraw:
	invoke SelectObject, mem_hdc, PausingBMH
	mov OldHandle, eax
	invoke GetClientRect, hWnd, addr myrect
	;invoke StretchBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, 3944, 2245, SRCCOPY
	invoke BitBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, SRCCOPY			   ;first zeroes are dest and second zeroes are src
	invoke SelectObject, mem_hdc, OldHandle
	invoke DeleteDC, mem_hdc
	ret

endingdraw:
	invoke SelectObject, mem_hdc, EndingBMH
	mov OldHandle, eax
	invoke GetClientRect, hWnd, addr myrect
	;invoke StretchBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, 3944, 2245, SRCCOPY
	invoke BitBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, SRCCOPY			   ;first zeroes are dest and second zeroes are src
	invoke SelectObject, mem_hdc, OldHandle
	invoke DeleteDC, mem_hdc
	ret
;============================================================================
DrawBG ENDP

BUILDRECT PROC, x:DWORD, y:DWORD, h:DWORD, w:DWORD, hdc:HDC, brush:HBRUSH
;----------------------------------------------------------------------------
LOCAL rectangle:RECT
mov eax, x
mov rectangle.left, eax
add eax, w
mov rectangle.right, eax
 
mov eax, y
mov rectangle.top, eax
add eax, h
mov rectangle.bottom, eax
 
invoke FillRect, hdc, addr rectangle, brush
ret
;============================================================================
BUILDRECT ENDP

WhichPlayer PROC, parameter:WPARAM
;----------------------------------------------------------------------------
	cmp parameter, VK_LEFT
	je PlayerOne
	cmp parameter, VK_RIGHT
	je PlayerOne
	cmp parameter, VK_UP
	je PlayerOne
	cmp parameter, VK_DOWN
	je PlayerOne
	cmp parameter, VK_W
	je PlayerTwo
	cmp parameter, VK_A
	je PlayerTwo
	cmp parameter, VK_S
	je PlayerTwo
	cmp parameter, VK_D
	je PlayerTwo
	jmp unknown
PlayerOne:
	mov eax, 1
	ret
PlayerTwo:
	mov eax, 2
	ret
unknown:
	mov eax, -1
	ret
;============================================================================
WhichPlayer ENDP

GetColor PROC, playerid:BYTE
;----------------------------------------------------------------------------
	cmp playerid, 0
	je noplayercolor
	cmp playerid, 1
	je player1color
	cmp playerid, 2
	je player2color
	cmp playerid, 3
	je player1boost
	cmp playerid, 4
	je player2boost
noplayercolor:
	mov eax, NULL
	ret
player1color:
	mov eax, Color1
	ret
player2color:
	mov eax, Color2
	ret
player1boost:
	mov eax, Darker1
	ret
player2boost:
	mov eax, Darker2
	ret
;============================================================================
GetColor ENDP

Restart PROC
;----------------------------------------------------------------------------
	mov ebx, offset grid
	mov ecx, WINDOW_WIDTH/MYD*WINDOW_HEIGHT/MYD
clear:
	mov BYTE ptr [ebx], 0
	inc ebx
	loop clear
	mov eax, STARTX1
	mov P1.x, eax
	mov eax, STARTY1
	mov P1.y, eax
	mov eax, STARTX2
	mov P2.x, eax
	mov eax, STARTY2
	mov P2.y, eax
	mov eax, FACING1
	mov P1.facing, eax
	mov eax, FACING2
	mov P2.facing, eax
	mov al, VERTICAL1
	mov P1.vertical, al
	mov al, HORIZONTAL1
	mov P1.horizontal, al
	mov al, VERTICAL2
	mov P2.vertical, al
	mov al, HORIZONTAL1
	mov P2.horizontal, al
	mov eax, SPEED
	mov P1.speed, eax
	mov P2.speed, eax
	mov al, BOOSTS1
	mov P1.boosts, al
	mov al, BOOSTS2
	mov P2.boosts, al
	ret
;============================================================================
Restart ENDP

ReadGrid PROC, XIndex:DWORD, YIndex:DWORD
;----------------------------------------------------------------------------
checkup:
	cmp YIndex, 0
	jl returndead
checkdown:
	cmp YIndex, WINDOW_HEIGHT/MYD-1
	jg returndead
checkleft:
	cmp XIndex, 0
	jl returndead
checkright:
	cmp XIndex, WINDOW_WIDTH/MYD-1
	jg returndead
checkoccupancy:
	mov ebx, offset grid
	mov eax, YIndex
	mov edx, WINDOW_WIDTH/MYD
	imul edx
	add ebx, eax
	add ebx, XIndex
	xor eax, eax
	mov al, BYTE ptr [ebx]
	ret
returndead:
	xor eax, eax
	mov al, -99
;============================================================================
ReadGrid ENDP

DrawGrid PROC, hdc:HDC
;----------------------------------------------------------------------------
local brush:HBRUSH
	mov ebx, 0
	mov edx, 0
	mov ecx, WINDOW_HEIGHT/MYD
loop00:
	mov backupecx, ecx
	mov ecx, WINDOW_WIDTH/MYD
	mov ebx, 0
loop01:
	pusha
	pusha
	invoke ReadGrid, ebx, edx
	cmp al, 0
	je skipdrawpopa
	invoke GetColor, al
	pusha
	invoke GetStockObject, DC_BRUSH
	mov brush, eax
	invoke SelectObject, hdc, brush
	popa
	invoke SetDCBrushColor, hdc, eax
	mov brush, eax
	popa
	imul ebx, MYD
	imul edx, MYD
	invoke BUILDRECT, ebx, edx, MYD, MYD, hdc, brush
	jmp skipdraw
skipdrawpopa:
	popa
skipdraw:
	popa
	inc ebx
	loop loop01
	mov ecx, backupecx
	inc edx
	loop loop00
	ret
;============================================================================
DrawGrid ENDP

SetGrid PROC, XIndex:DWORD, YIndex:DWORD, data:BYTE
;----------------------------------------------------------------------------
local realdata:BYTE
	
	cmp data, 1
	je player1set
	cmp data, 2
	je player2set
	jmp returning
player1set:
	cmp P1.speed, SPEED
	je noboostset1
boostset1:
	mov al, DARK1
	mov realdata, al
	jmp nextset
noboostset1:
	mov al, REG1
	mov realdata, al
	jmp nextset
player2set:
	cmp P2.speed, SPEED
	je noboostset2
boostset2:
	mov al, DARK2
	mov realdata, al
	jmp nextset
noboostset2:
	mov al, REG2
	mov realdata, al
	jmp nextset

nextset:
	cmp YIndex, 0
	jl returning
	cmp YIndex, WINDOW_HEIGHT/MYD-1
	jg returning
	cmp XIndex, 0
	jl returning
	cmp XIndex, WINDOW_WIDTH/MYD-1
	jg returning
	mov ebx, offset grid
	mov eax, YIndex
	mov edx, WINDOW_WIDTH/MYD
	imul edx
	add ebx, eax
	add ebx, XIndex
	mov al, realdata
	mov BYTE ptr [ebx], al
returning:
	ret
;============================================================================
SetGrid ENDP

ProjectWndProc PROC, hWnd:HWND, message:UINT, wParam:WPARAM, lParam:LPARAM
;----------------------------------------------------------------------------
local paint:PAINTSTRUCT
local hdc:HDC
local brushcolouring1:HBRUSH
local brushcolouring2:HBRUSH
local mem_hdc:HDC
local mem_hbm:HBITMAP
local OldHandle:HBITMAP
local rect:RECT
	cmp message, WM_ERASEBKGND
	je noterasing
	cmp message, WM_CLOSE
	je closing
	cmp message, WM_KEYDOWN
	je statuskey
	cmp message, WM_PAINT
	je statuspainting
	cmp message, WM_TIMER
	je timing
	jmp OtherInstances

noterasing:
	mov eax, 1
	ret

closing:
	invoke ExitProcess, 0

newgame:
	mov eax, GAME
	mov status, eax
	invoke Restart
	ret

settings:
	mov eax, SETTINGS
	mov status, eax
	ret

help:
	mov eax, HELPING
	mov status, eax
	ret

exiting:
	mov eax, EXITING
	mov status, eax
	ret

resume:
	mov eax, GAME
	mov status, eax
	ret

credits:
	mov eax, CREDITS
	mov status, eax
	ret
	
pausing:
	mov eax, PAUSING
	mov status, eax
	ret

statuskey:
	cmp status, GAME
	je gamemovement
	cmp status, START
	je startmovement
	cmp status, SETTINGS
	je optionsmovement
	cmp status, PAUSING
	je pausingmovement
	cmp status, ENDING
	je endingmovement
	ret

pausingmovement:
	cmp wParam, VK_P
	je resume
	cmp wParam, VK_UP
	je pausingupselect
	cmp wParam, VK_DOWN
	je pausingdownselect
	cmp wParam, VK_RETURN
	je pausingselect
	cmp wParam, VK_ESCAPE
	je closing
pausingupselect:
	cmp Selected, 1
	jl pausingselectbot
	dec Selected
	ret
pausingdownselect:
	cmp Selected, 5			;number of buttons: resume, new game, options, help, exit
	jg pausingselecttop
	inc Selected
	ret
pausingselect:
	cmp Selected, 1
	je resume
	cmp Selected, 2
	je newgame
	cmp Selected, 3
	je settings
	cmp Selected, 4
	je help
	cmp Selected, 5
	je exiting
	ret
pausingselecttop:
	mov eax, 1
	mov Selected, eax
	ret
pausingselectbot:
	mov eax, 4
	mov Selected, eax
	ret
	
endingmovement:
	cmp wParam, VK_ESCAPE
	je closing
	cmp wParam, VK_RETURN
	je newgame
	ret

startmovement:
	cmp wParam, VK_UP
	je startupselect
	cmp wParam, VK_DOWN
	je startdownselect
	cmp wParam, VK_RETURN
	je startselect
	cmp wParam, VK_ESCAPE
	je closing
startupselect:
	dec Selected
	cmp Selected, 1
	jl startselectbot
	ret
startdownselect:
	inc Selected
	cmp Selected, 5			;number of buttons: new game, options, help, credits, exit
	jg startselecttop
	ret
startselect:
	cmp Selected, 1
	je newgame
	cmp Selected, 2
	je settings
	cmp Selected, 3
	je help
	cmp Selected, 4
	je credits
	cmp Selected, 5
	je exiting
	ret
startselecttop:
	mov eax, 1
	mov Selected, eax
	ret
startselectbot:
	mov eax, 4
	mov Selected, eax
	ret

optionsmovement:
	cmp wParam, VK_UP
	je optionsupselect
	cmp wParam, VK_DOWN
	je optionsdownselect
	cmp wParam, VK_RETURN
	je optionsselect
	cmp wParam, VK_ESCAPE
	je closing
optionsupselect:
	dec Selected
	cmp Selected, 1
	jl optionsselectbot
	ret
optionsdownselect:
	inc Selected
	cmp Selected, 3			;number of buttons: audio, graphics, back
	jg optionsselecttop
	ret
optionsselect:
	cmp Selected, 1
	je audio
	cmp Selected, 2
	je graphics
	cmp Selected, 3
	je pausing
	ret
optionsselecttop:
	mov eax, 1
	mov Selected, eax
	ret
optionsselectbot:
	mov eax, 3
	mov Selected, eax
	ret
	ret

gamemovement:
	cmp wParam, VK_ESCAPE
	je closing
	cmp wParam, VK_P
	je pausing
	cmp wParam, VK_R
	je newgame
	cmp wParam, VK_RSHIFT
	je startboost1
	cmp wParam, VK_LSHIFT
	je startboost2
	invoke WhichPlayer, wParam
	cmp eax, 1
	je gamemovement1
	cmp eax, 2
	je gamemovement2
	cmp eax, -1
	je theend

startboost1:
	cmp P1.speed, SPEED
	jne boostret1
	cmp P1.boosts, 0
	je boostret1
	invoke GetTickCount
	mov BoostTime1, eax
	mov eax, BOOST
	mov P1.speed, eax
	dec P1.boosts
boostret1:
	ret

endboost1:
	mov eax, SPEED
	mov P1.speed, eax
	ret

startboost2:
	cmp P2.speed, SPEED
	jne boostret2
	cmp P2.boosts, 0
	je boostret2
	invoke GetTickCount
	mov BoostTime2, eax
	mov eax, BOOST
	mov P2.speed, eax
	dec P2.boosts
boostret2:
	ret

endboost2:
	mov eax, SPEED
	mov P2.speed, eax
	ret

gamemovement1:
	mov eax, NowKey1
	mov LastKey1, eax
	mov eax, wParam
	mov NowKey1, eax
	mov eax, NowTime1
	mov LastTime1, eax
	invoke GetTickCount
	mov NowTime1, eax
	mov eax, NowKey1
	cmp LastKey1, eax
	jne notboost1
	mov eax, NowTime1
	sub eax, LastTime1
	cmp eax, 500
	jle startboost1
	jmp notboost1

notboost1:
	cmp P1.horizontal, 0
	jne Vertically1
 
Horizontally1:
	cmp wParam, VK_LEFT
	je left1
	cmp wParam, VK_RIGHT
	je right1
 
	cmp P1.vertical, 0
	jne theend
 
Vertically1:
	cmp wParam, VK_UP
	je up1
	cmp wParam, VK_DOWN
	je down1
	ret
 
left1:
	mov eax, LEFT
	mov P1.facing, eax
	mov P1.horizontal, 1
	mov P1.vertical, 0
	ret

right1:
	mov eax, RIGHT
	mov P1.facing, eax
	mov P1.horizontal, 1
	mov P1.vertical, 0
	ret

down1:
	mov eax, DOWN
	mov P1.facing, eax
	mov P1.horizontal, 0
	mov P1.vertical, 1
	ret
 
up1:
	mov eax, UP
	mov P1.facing, eax
	mov P1.horizontal, 0
	mov P1.vertical, 1
	ret
 
gamemovement2:
	mov eax, NowKey2
	mov LastKey2, eax
	mov eax, wParam
	mov NowKey2, eax
	mov eax, NowTime2
	mov LastTime2, eax
	invoke GetTickCount
	mov NowTime2, eax
	mov eax, NowKey2
	cmp LastKey2, eax
	jne notboost2
	mov eax, NowTime2
	sub eax, LastTime2
	cmp eax, 500
	jle startboost2
	jmp notboost2

notboost2:
	cmp P2.horizontal, 0
	jne Vertically2

Horizontally2:
	cmp wParam, VK_A
	je left2
	cmp wParam, VK_D
	je right2
 
	cmp P2.vertical, 0
	jne theend
 
Vertically2:
	cmp wParam, VK_W
	je up2
	cmp wParam, VK_S
	je down2
	ret
 
left2:
	mov eax, LEFT
	mov P2.facing, eax
	mov P2.horizontal, 1
	mov P2.vertical, 0
	ret
 
right2:
	mov eax, RIGHT
	mov P2.facing, eax
	mov P2.horizontal, 1
	mov P2.vertical, 0
	ret
 
down2:
	mov eax, DOWN
	mov P2.facing, eax
	mov P2.horizontal, 0
	mov P2.vertical, 1
	ret
 
up2:
	mov eax, UP
	mov P2.facing, eax
	mov P2.horizontal, 0
	mov P2.vertical, 1
	ret
 
theend:
   ret
 
statuspainting:
	cmp status, GAME
	je gamepaint
	cmp status, START
	je startpaint
	cmp status, SETTINGS
	je optionspaint
	cmp status, PAUSING
	je pausingpaint
	cmp status, ENDING
	je endingpaint
	jmp closing

pausingpaint:
	invoke BeginPaint, hWnd, addr paint
	mov hdc, eax
	invoke DrawBG, status, rect, hdc, hWnd
	invoke EndPaint, hWnd, addr paint
	ret

endingpaint:
	invoke BeginPaint, hWnd, addr paint
	mov hdc, eax
	invoke DrawBG, status, rect, hdc, hWnd
	invoke EndPaint, hWnd, addr paint
	ret

startpaint:
	invoke BeginPaint, hWnd, addr paint
	mov hdc, eax
	invoke DrawBG, status, rect, hdc, hWnd
	invoke EndPaint, hWnd, addr paint
	ret

optionspaint:
	jmp OtherInstances

gamepaint:
	mov eax, SPEED
	cmp P1.speed, eax
	je notboosting1
	invoke GetTickCount
	sub eax, BoostTime1
	cmp eax, 500
	jg endboost1
notboosting1:
	mov eax, P1.speed
	mov ecx, MYD
	div ecx
	mov ecx, eax
gamepaint1:
	push ecx
	cmp P1.facing, LEFT
	je moveleft1
	cmp P1.facing, RIGHT
	je moveright1
	cmp P1.facing, DOWN
	je movedown1
	cmp P1.facing, UP
	je moveup1
	pusha
	cmp P1.facing, STOP
	je notdead1

moveleft1:
	mov eax, SPEED
	mov ebx, MYD
	idiv ebx
	sub P1.x, eax
	jmp checkalive1
 
moveright1:
	mov eax, SPEED
	mov ebx, MYD
	idiv ebx
	add P1.x, eax
	jmp checkalive1
 
movedown1:
	mov eax, SPEED
	mov ebx, MYD
	idiv ebx
	add P1.y, eax
	jmp checkalive1
 
moveup1:
	mov eax, SPEED
	mov ebx, MYD
	idiv ebx
	sub P1.y, eax
	jmp checkalive1

checkalive1:
	pusha
	cmp P1.x, 0
	jl dead1
	cmp P1.x, WINDOW_WIDTH/MYD-1
	jg dead1
	cmp P1.y, 0
	jl dead1
	cmp P1.y, WINDOW_HEIGHT/MYD-1
	jg dead1
	mov eax, P2.x
	cmp P1.x, eax
	jne nottied1
	mov eax, P2.y
	cmp P1.y, eax
	je tied
nottied1:
	invoke ReadGrid, P1.x, P1.y
	cmp al, -99
	je dead1
	cmp al, 0
	je notdead1
	jmp dead1

dead1:
	popa
	mov eax, ENDING
	mov status, eax
	ret

notdead1:
	invoke SetGrid, P1.x, P1.y, 1
	popa
	pop ecx
	dec ecx
	cmp ecx, 0
	jne gamepaint1

	mov eax, SPEED
	cmp P2.speed, eax
	je notboosting2
	invoke GetTickCount
	sub eax, BoostTime2
	cmp eax, 500
	jg endboost2
notboosting2:
	mov eax, P2.speed
	mov ecx, MYD
	div ecx
	mov ecx, eax
gamepaint2:
	push ecx
	cmp P2.facing, LEFT
	je moveleft2
	cmp P2.facing, RIGHT
	je moveright2
	cmp P2.facing, DOWN
	je movedown2
	cmp P2.facing, UP
	je moveup2
	pusha
	cmp P2.facing, STOP
	je notdead2
 
moveleft2:
	mov eax, SPEED
	mov ebx, MYD
	idiv ebx
	sub P2.x, eax
	jmp checkalive2
 
moveright2:
	mov eax, SPEED
	mov ebx, MYD
	idiv ebx
	add P2.x, eax
	jmp checkalive2
 
movedown2:
	mov eax, SPEED
	mov ebx, MYD
	idiv ebx
	add P2.y, eax
	jmp checkalive2
 
moveup2:
	mov eax, SPEED
	mov ebx, MYD
	idiv ebx
	sub P2.y, eax
	jmp checkalive2

checkalive2:
	pusha
	cmp P2.x, 0
	jl dead2
	cmp P2.x, WINDOW_WIDTH/MYD-1
	jg dead2
	cmp P2.y, 0
	jl dead2
	cmp P2.y, WINDOW_HEIGHT/MYD-1
	jg dead2
	mov eax, P2.x
	cmp P1.x, eax
	jne nottied2
	mov eax, P2.y
	cmp P1.y, eax
	je tied

nottied2:
	invoke ReadGrid, P2.x, P2.y
	cmp al, -99
	je dead2
	cmp al, 0
	je notdead2
	jmp dead2

dead2:
	popa
	mov eax, ENDING
	mov status, eax
	ret
 
notdead2:
	invoke SetGrid, P2.x, P2.y, 2
	popa
	pop ecx
	dec ecx
	cmp ecx, 0
	jne gamepaint2

	invoke BeginPaint, hWnd, addr paint
	mov hdc, eax
	invoke CreateCompatibleDC, hdc
	mov mem_hdc, eax
	invoke CreateCompatibleBitmap, hdc, WINDOW_WIDTH, WINDOW_HEIGHT
	mov mem_hbm, eax
	invoke SelectObject, mem_hdc, mem_hbm
	mov OldHandle, eax
	invoke DrawBG, status, rect, mem_hdc, hWnd
	invoke DrawGrid, mem_hdc
	invoke BitBlt, hdc, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, mem_hdc, 0, 0, SRCCOPY
	invoke SelectObject, mem_hdc, OldHandle
	invoke DeleteObject, mem_hbm
	invoke DeleteDC, mem_hdc
	invoke EndPaint, hWnd, addr paint
	ret

tied:
	popa
	mov eax, ENDING
	mov status, eax
	ret

timing:
	invoke InvalidateRect, hWnd, NULL, TRUE
	ret

OtherInstances:
	invoke DefWindowProc, hWnd, message, wParam, lParam
	ret
;============================================================================
ProjectWndProc ENDP
 
main PROC
LOCAL wndcls:WNDCLASSA ; Class struct for the window
LOCAL hWnd:HWND ;Handle to the window
LOCAL msg:MSG
invoke RtlZeroMemory, addr wndcls, SIZEOF wndcls ;Empty the window class
mov eax, offset ClassName
mov wndcls.lpszClassName, eax ;Set the class name
invoke GetStockObject, BLACK_BRUSH
mov wndcls.hbrBackground, eax ;Set the background color as black
mov eax, ProjectWndProc
mov wndcls.lpfnWndProc, eax ;Set the procedure that handles the window messages
invoke RegisterClassA, addr wndcls ;Register the class
invoke CreateWindowExA, WS_EX_COMPOSITED, addr ClassName, addr windowTitle, WS_SYSMENU, 0, 0, REALWIDTH, REALHEIGHT, 0, 0, 0, 0 ;Create the window
mov hWnd, eax ;Save the handle

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, GAME
mov GameBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, START
mov StartBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, SETTINGS
mov OptionsBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, ENDING
mov EndingBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, PAUSING
mov PausingBMH, eax

mov eax, Color1
and eax, 07E7E7Eh
shr eax, 1
mov ebx, Color1
and ebx, 0808080h
or eax, ebx
mov Darker1, eax

mov eax, Color2
and eax, 07E7E7Eh
shr eax, 1
mov ebx, Color2
and ebx, 0808080h
or eax, ebx
mov Darker2, eax

invoke ShowWindow, hWnd, SW_SHOW ;Show it 
invoke SetTimer, hWnd, MAIN_TIMER_ID, 20, NULL ;Set the repaint timer

msgLoop:
invoke GetMessage, addr msg, hWnd, 0, 0 ;Retrieve the messages from the window 
invoke DispatchMessage, addr msg ;Dispatches a message to the window procedure
jmp msgLoop
invoke ExitProcess, 1
main ENDP
end main