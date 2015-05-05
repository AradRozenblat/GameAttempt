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
include \masm32\include\dialogs.inc ;macro file for dialogs
include \masm32\macros\macros.asm ;masm32 macro file
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
UP	equ 4
STOP equ 5

SPEED equ MYD
BOOST equ MYD*2

FACING1 equ 3
FACING2 equ 1
VERTICAL1 equ 0
HORIZONTAL1 equ 1
VERTICAL2 equ 0
HORIZONTAL2 equ 1

MAINMENUX1 equ (WINDOW_WIDTH/MYD*3/4)
MAINMENUY1 equ (WINDOW_HEIGHT/MYD/2)
MAINMENUX2 equ (WINDOW_WIDTH/MYD*1/4)
MAINMENUY2 equ (WINDOW_HEIGHT/MYD/2)

GAME equ 1
SETTINGS equ 2
MAINMENU equ 3
COLOR1 equ 4
COLOR1CHOSE equ 5
COLOR2 equ 6
COLOR2CHOSE equ 7
PAUSING equ 8
ENDING equ 9
EXITING equ 10
HELPING equ 11
CREDITS equ 12
AUDIO equ 13
GRAPHICS equ 14
NEWGAMEBUTTON equ 15
MAINMENUBUTTON equ 16
BACKBUTTON equ 17
SETTINGSBUTTON equ 18
AUDIOBUTTON equ 19
GRAPHICSBUTTON equ 20
RESUMEBUTTON equ 21
HELPBUTTON equ 22
CREDITSBUTTON equ 23
EXITBUTTON equ 24
HIGHLIGHT equ 25

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
P1 Player <1, Color1, MAINMENUX1, MAINMENUY1, SPEED, LEFT, 0, 1, BOOSTS1>
P2 Player <2, Color2, MAINMENUX2, MAINMENUY2, SPEED, RIGHT, 0, 1, BOOSTS2>
ClassName DB "TheClass", 0
windowTitle DB "TRON: REASSEMBLED", 0
backupecx	DWORD	?
grid DB WINDOW_WIDTH/MYD*WINDOW_HEIGHT/MYD dup(0)
GameBMH HBITMAP ?
SettingsBMH HBITMAP ?
MainMenuBMH HBITMAP ?
PausingBMH HBITMAP ?
EndingBMH HBITMAP ?
Color1BMH HBITMAP ?
Color1ChoseBMH HBITMAP ?
Color2BMH HBITMAP ?
Color2ChoseBMH HBITMAP ?
ExitingBMH HBITMAP ?
HelpingBMH HBITMAP ?
CreditsBMH HBITMAP ?
AudioBMH HBITMAP ?
GraphicsBMH HBITMAP ?
NewGameButtonBMH HBITMAP ?
NewGameButtonMaskBMH HBITMAP ?
MainMenuButtonBMH HBITMAP ?
MainMenuButtonMaskBMH HBITMAP ?
BackButtonBMH HBITMAP ?
BackButtonMaskBMH HBITMAP ?
SettingsButtonBMH HBITMAP ?
SettingsButtonMaskBMH HBITMAP ?
AudioButtonBMH HBITMAP ?
AudioButtonMaskBMH HBITMAP ?
GraphicsButtonBMH HBITMAP ?
GraphicsButtonMaskBMH HBITMAP ?
ResumeButtonBMH HBITMAP ?
ResumeButtonMaskBMH HBITMAP ?
HelpButtonBMH HBITMAP ?
HelpButtonMaskBMH HBITMAP ?
CreditsButtonBMH HBITMAP ?
CreditsButtonMaskBMH HBITMAP ?
ExitButtonBMH HBITMAP ?
ExitButtonMaskBMH HBITMAP ?
HighlightBMH HBITMAP ?
HighlightMaskBMH HBITMAP ?
status DWORD MAINMENU
laststatus DWORD ?
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

DrawImage_WithMask PROC, hdc:HDC, img:HBITMAP, maskedimg:HBITMAP, 	destx:DWORD, desty:DWORD, srcx:DWORD, srcy:DWORD, destw:DWORD, desth:DWORD, srcw:DWORD, srch:DWORD
;--------------------------------------------------------------------------------
local hdcMem:HDC
local HOld:HDC
	invoke CreateCompatibleDC, hdc
	mov hdcMem, eax
	invoke SelectObject, hdcMem, maskedimg
	invoke SetStretchBltMode, hdc, COLORONCOLOR
	invoke StretchBlt , hdc, destx, desty, destw, desth, hdcMem, srcx, srcy, srcw, srch, SRCAND
	
	invoke SelectObject, hdcMem, img
	invoke StretchBlt , hdc, destx, desty, destw, desth, hdcMem, srcx, srcy, srcw, srch, SRCPAINT
	invoke DeleteDC, hdcMem
	ret
;================================================================================
DrawImage_WithMask ENDP

DrawImage PROC, hdc:HDC, img:HBITMAP, destx:DWORD, desty:DWORD, srcx:DWORD, srcy:DWORD, destw:DWORD, desth:DWORD, srcw:DWORD, srch:DWORD
;--------------------------------------------------------------------------------
local hdcMem:HDC
local HOld:HBITMAP
	invoke CreateCompatibleDC, hdc
	mov hdcMem, eax
	invoke SelectObject, hdcMem, img
	mov HOld, eax
	invoke SetStretchBltMode, hdc, COLORONCOLOR
	invoke StretchBlt , hdc, destx, desty, destw, desth, hdcMem, srcx, srcy, srcw, srch, SRCCOPY
	invoke SelectObject, hdcMem, HOld
	invoke DeleteDC, hdcMem 
	invoke DeleteObject, HOld
	ret
;================================================================================
DrawImage ENDP

Get_Handle_To_Mask_Bitmap PROC, hbmColour:HBITMAP, crTransparent:COLORREF
;--------------------------------------------------------------------------------
local hdcMem:HDC
local hdcMem2:HDC
local hbmMask:HBITMAP
local bm:BITMAP
local hold:HBITMAP
local hold2:HBITMAP
	invoke GetObject, hbmColour, SIZEOF(BITMAP), addr bm
	invoke CreateBitmap, bm.bmWidth, bm.bmHeight, 1, 1, NULL
	mov hbmMask, eax
	invoke CreateCompatibleDC, NULL
	mov hdcMem, eax
	invoke CreateCompatibleDC, NULL
	mov hdcMem2, eax
	invoke SelectObject, hdcMem, hbmColour
	invoke SelectObject, hdcMem2, hbmMask
	invoke SetBkColor, hdcMem, crTransparent
	invoke BitBlt, hdcMem2, 0, 0, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCCOPY
	invoke BitBlt, hdcMem, 0, 0, bm.bmWidth, bm.bmHeight, hdcMem2, 0, 0, SRCINVERT
	invoke DeleteDC, hdcMem
	invoke DeleteDC, hdcMem2
	mov eax, hbmMask
	ret
;================================================================================
Get_Handle_To_Mask_Bitmap ENDP

DrawBG PROC, mystatus:DWORD, myrect:RECT, myhdc:HDC, hWnd:HWND
;----------------------------------------------------------------------------
	local mem_hdc:HDC
	local OldHandle:HBITMAP

	invoke CreateCompatibleDC, myhdc
	mov mem_hdc, eax

	cmp mystatus, GAME
	je gamedraw
	cmp mystatus, MAINMENU
	je mainmenudraw
	cmp mystatus, SETTINGS
	je settingsdraw
	cmp mystatus, PAUSING
	je pausingdraw
	cmp mystatus, ENDING
	je endingdraw
	cmp mystatus, COLOR1
	je color1draw
	cmp mystatus, COLOR1CHOSE
	je color1chosedraw
	cmp mystatus, COLOR2
	je color2draw
	cmp mystatus, COLOR2CHOSE
	je color2chosedraw
	cmp mystatus, EXITING
	je exitingdraw
	cmp mystatus, HELPING
	je helpingdraw
	cmp mystatus, CREDITS
	je creditsdraw
	cmp mystatus, AUDIO
	je audiodraw
	cmp mystatus, GRAPHICS
	je graphicsdraw
	invoke ExitProcess, 0

gamedraw:
	invoke SelectObject, mem_hdc, GameBMH
	mov OldHandle, eax
	invoke GetClientRect, hWnd, addr myrect
	;invoke StretchBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, 3944, 2245, SRCCOPY
	invoke BitBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, SRCCOPY	 ;first zeroes are dest and second zeroes are src
	invoke SelectObject, mem_hdc, OldHandle
	invoke DeleteDC, mem_hdc
	ret

mainmenudraw:	;new game, settings, help, credits, exit
	;invoke SelectObject, mem_hdc, MainMenuBMH
	;mov OldHandle, eax
	invoke GetClientRect, hWnd, addr myrect
	invoke BitBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, SRCCOPY	 ;first zeroes are dest and second zeroes are src
	invoke SelectObject, mem_hdc, OldHandle
	invoke DeleteDC, mem_hdc

	cmp Selected, 1
	je mainmenunewgameselect
	cmp Selected, 2
	je mainmenusettingsselect
	cmp Selected, 3
	je mainmenuhelpselect
	cmp Selected, 4
	je mainmenucreditsselect
	cmp Selected, 5
	je mainmenuexitselect
	ret
	
mainmenunewgameselect:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, NewGameButtonBMH, NewGameButtonMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, SettingsButtonBMH, SettingsButtonMaskBMH,  WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, HelpButtonBMH, HelpButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, CreditsButtonBMH, CreditsButtonMaskBMH,  WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, ExitButtonBMH, ExitButtonMaskBMH,  WINDOW_WIDTH/4, 5*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret
mainmenusettingsselect:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, NewGameButtonBMH, NewGameButtonMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, SettingsButtonBMH, SettingsButtonMaskBMH,  WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, HelpButtonBMH, HelpButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, CreditsButtonBMH, CreditsButtonMaskBMH,  WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, ExitButtonBMH, ExitButtonMaskBMH,  WINDOW_WIDTH/4, 5*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret
mainmenuhelpselect:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, NewGameButtonBMH, NewGameButtonMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, SettingsButtonBMH, SettingsButtonMaskBMH,  WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, HelpButtonBMH, HelpButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, CreditsButtonBMH, CreditsButtonMaskBMH,  WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, ExitButtonBMH, ExitButtonMaskBMH,  WINDOW_WIDTH/4, 5*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret
mainmenucreditsselect:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, NewGameButtonBMH, NewGameButtonMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, SettingsButtonBMH, SettingsButtonMaskBMH,  WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, HelpButtonBMH, HelpButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, CreditsButtonBMH, CreditsButtonMaskBMH,  WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, ExitButtonBMH, ExitButtonMaskBMH,  WINDOW_WIDTH/4, 5*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret
mainmenuexitselect:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 5*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, NewGameButtonBMH, NewGameButtonMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, SettingsButtonBMH, SettingsButtonMaskBMH,  WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, HelpButtonBMH, HelpButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, CreditsButtonBMH, CreditsButtonMaskBMH,  WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, ExitButtonBMH, ExitButtonMaskBMH,  WINDOW_WIDTH/4, 5*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret

settingsdraw:		;audio, graphics, back
	invoke SelectObject, mem_hdc, SettingsBMH
	mov OldHandle, eax
	invoke GetClientRect, hWnd, addr myrect
	;invoke StretchBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, 3944, 2245, SRCCOPY
	invoke BitBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, SRCCOPY	 ;first zeroes are dest and second zeroes are src
	invoke SelectObject, mem_hdc, OldHandle
	invoke DeleteDC, mem_hdc

	cmp Selected, 1
	je settingsaudioselect
	cmp Selected, 2
	je settingsgraphicsselect
	cmp Selected, 3
	je settingsbackselect
	ret

settingsaudioselect:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, AudioButtonBMH, AudioButtonMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, GraphicsButtonBMH, GraphicsButtonMaskBMH,  WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, BackButtonBMH, BackButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret

settingsgraphicsselect:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, AudioButtonBMH, AudioButtonMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, GraphicsButtonBMH, GraphicsButtonMaskBMH,  WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, BackButtonBMH, BackButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret

settingsbackselect:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, AudioButtonBMH, AudioButtonMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, GraphicsButtonBMH, GraphicsButtonMaskBMH,  WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, BackButtonBMH, BackButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret

pausingdraw:		;resume, new game, settings, help, mainmenu
	invoke SelectObject, mem_hdc, PausingBMH
	mov OldHandle, eax
	invoke GetClientRect, hWnd, addr myrect
	;invoke StretchBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, 3944, 2245, SRCCOPY
	invoke BitBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, SRCCOPY	 ;first zeroes are dest and second zeroes are src
	invoke SelectObject, mem_hdc, OldHandle
	invoke DeleteDC, mem_hdc

	cmp Selected, 1
	je pausingresumeselected
	cmp Selected, 2
	je pausingnewgameselected
	cmp Selected, 3
	je pausingsettingsselected
	cmp Selected, 4
	je pausinghelpselected
	cmp Selected, 5
	je pausingmainmenuselected
	ret

pausingresumeselected:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, ResumeButtonBMH, ResumeButtonMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, NewGameButtonBMH, NewGameButtonMaskBMH,  WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, SettingsButtonBMH, SettingsButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, HelpButtonBMH, HelpButtonMaskBMH,  WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, MainMenuButtonBMH, MainMenuButtonMaskBMH,  WINDOW_WIDTH/4, 5*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret

pausingnewgameselected:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, ResumeButtonBMH, ResumeButtonMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, NewGameButtonBMH, NewGameButtonMaskBMH,  WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, SettingsButtonBMH, SettingsButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, HelpButtonBMH, HelpButtonMaskBMH,  WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, MainMenuButtonBMH, MainMenuButtonMaskBMH,  WINDOW_WIDTH/4, 5*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret

pausingsettingsselected:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, ResumeButtonBMH, ResumeButtonMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, NewGameButtonBMH, NewGameButtonMaskBMH,  WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, SettingsButtonBMH, SettingsButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, HelpButtonBMH, HelpButtonMaskBMH,  WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, MainMenuButtonBMH, MainMenuButtonMaskBMH,  WINDOW_WIDTH/4, 5*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret

pausinghelpselected:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, ResumeButtonBMH, ResumeButtonMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, NewGameButtonBMH, NewGameButtonMaskBMH,  WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, SettingsButtonBMH, SettingsButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, HelpButtonBMH, HelpButtonMaskBMH,  WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, MainMenuButtonBMH, MainMenuButtonMaskBMH,  WINDOW_WIDTH/4, 5*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret

pausingmainmenuselected:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 5*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, ResumeButtonBMH, ResumeButtonMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, NewGameButtonBMH, NewGameButtonMaskBMH,  WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, SettingsButtonBMH, SettingsButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, HelpButtonBMH, HelpButtonMaskBMH,  WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, MainMenuButtonBMH, MainMenuButtonMaskBMH,  WINDOW_WIDTH/4, 5*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret

endingdraw:			;new game, credits, mainmenu, exit
	invoke SelectObject, mem_hdc, EndingBMH
	mov OldHandle, eax
	invoke GetClientRect, hWnd, addr myrect
	;invoke StretchBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, 3944, 2245, SRCCOPY
	invoke BitBlt, myhdc, 0, 0, myrect.right, myrect.bottom, mem_hdc, 0, 0, SRCCOPY	 ;first zeroes are dest and second zeroes are src
	invoke SelectObject, mem_hdc, OldHandle
	invoke DeleteDC, mem_hdc
	
	cmp Selected, 1
	je endingnewgameselected
	cmp Selected, 2
	je endingcreditsselected
	cmp Selected, 3
	je endingmainmenuselected
	cmp Selected, 4
	je endingexitselected
	ret

endingnewgameselected:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, NewGameButtonBMH, NewGameButtonMaskBMH,  WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, CreditsButtonBMH, CreditsButtonMaskBMH, WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, MainMenuButtonBMH, MainMenuButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, ExitButtonBMH, ExitButtonMaskBMH,  WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret

endingcreditsselected:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, NewGameButtonBMH, NewGameButtonMaskBMH,  WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, CreditsButtonBMH, CreditsButtonMaskBMH, WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, MainMenuButtonBMH, MainMenuButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, ExitButtonBMH, ExitButtonMaskBMH,  WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret

endingmainmenuselected:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, NewGameButtonBMH, NewGameButtonMaskBMH,  WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, CreditsButtonBMH, CreditsButtonMaskBMH, WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, MainMenuButtonBMH, MainMenuButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, ExitButtonBMH, ExitButtonMaskBMH,  WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret

endingexitselected:
	invoke DrawImage_WithMask, myhdc, HighlightBMH, HighlightMaskBMH, WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, NewGameButtonBMH, NewGameButtonMaskBMH,  WINDOW_WIDTH/4, 1*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, CreditsButtonBMH, CreditsButtonMaskBMH, WINDOW_WIDTH/4, 2*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346	;magic numbers
	invoke DrawImage_WithMask, myhdc, MainMenuButtonBMH, MainMenuButtonMaskBMH,  WINDOW_WIDTH/4, 3*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	invoke DrawImage_WithMask, myhdc, ExitButtonBMH, ExitButtonMaskBMH,  WINDOW_WIDTH/4, 4*WINDOW_HEIGHT/7, 0, 0, WINDOW_WIDTH/2, WINDOW_HEIGHT/7, 1813, 346
	ret

color1draw:
	ret
color1chosedraw:
	ret
color2draw:
	ret
color2chosedraw:
	ret
exitingdraw:
	ret
helpingdraw:
	ret
creditsdraw:
	ret
audiodraw:
	ret
graphicsdraw:
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
	mov eax, MAINMENUX1
	mov P1.x, eax
	mov eax, MAINMENUY1
	mov P1.y, eax
	mov eax, MAINMENUX2
	mov P2.x, eax
	mov eax, MAINMENUY2
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
	mov eax, 1
	mov Selected, eax
	mov eax, status
	mov laststatus, eax
	mov eax, GAME
	mov status, eax
	invoke Restart
	ret

settings:
	mov eax, 1
	mov Selected, eax
	mov eax, status
	mov laststatus, eax
	mov eax, SETTINGS
	mov status, eax
	ret

help:
	mov eax, 1
	mov Selected, eax
	mov eax, status
	mov laststatus, eax
	mov eax, HELPING
	mov status, eax
	ret

exiting:
	mov eax, 1
	mov Selected, eax
	mov eax, status
	mov laststatus, eax
	mov eax, EXITING
	mov status, eax
	ret

resume:
	mov eax, 1
	mov Selected, eax
	mov eax, status
	mov laststatus, eax
	mov eax, GAME
	mov status, eax
	ret

credits:
	mov eax, 1
	mov Selected, eax
	mov eax, status
	mov laststatus, eax
	mov eax, CREDITS
	mov status, eax
	ret
	
pausing:
	mov eax, 1
	mov Selected, eax
	mov eax, status
	mov laststatus, eax
	mov eax, PAUSING
	mov status, eax
	ret

backing:
	mov eax, 1
	mov Selected, eax
	mov eax, laststatus
	cmp laststatus, PAUSING
	je pausing
	cmp laststatus, MAINMENU
	je mainmenu
	ret

audio:
	mov eax, 1
	mov Selected, eax
	mov eax, status
	mov laststatus, eax
	mov eax, AUDIO
	mov status, eax
	ret

graphics:
	mov eax, 1
	mov Selected, eax
	mov eax, status
	mov laststatus, eax
	mov eax, GRAPHICS
	mov status, eax
	ret

mainmenu:
	mov eax, 1
	mov Selected, eax
	mov eax, status
	mov laststatus, eax
	mov eax, MAINMENU
	mov status, eax
	ret

statuskey:
	cmp status, GAME
	je gamemovement
	cmp status, MAINMENU
	je mainmenumovement
	cmp status, SETTINGS
	je settingsmovement
	cmp status, PAUSING
	je pausingmovement
	cmp status, ENDING
	je endingmovement
	cmp status, AUDIO
	je audiomovement
	cmp status, GRAPHICS
	je graphicsmovement
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
	ret
pausingupselect:
	dec Selected
	cmp Selected, 1
	jl pausingselectbot
	ret
pausingdownselect:
	inc Selected
	cmp Selected, 5	;number of buttons: resume, new game, settings, help, mainmenu
	jg pausingselecttop
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
	je mainmenu
	ret
pausingselecttop:
	mov eax, 1
	mov Selected, eax
	ret
pausingselectbot:
	mov eax, 5
	mov Selected, eax
	ret
	
endingmovement:
	cmp wParam, VK_UP
	je endingupselect
	cmp wParam, VK_DOWN
	je endingdownselect
	cmp wParam, VK_RETURN
	je endingselect
	cmp wParam, VK_ESCAPE
	je closing
	ret
endingupselect:
	dec Selected
	cmp Selected, 1
	jl endingselectbot
	ret
endingdownselect:
	inc Selected
	cmp Selected, 4	;number of buttons: new game, credits, mainmenu, exit
	jg endingselecttop
	ret
endingselect:
	cmp Selected, 1
	je newgame
	cmp Selected, 2
	je credits
	cmp Selected, 3
	je mainmenu
	cmp Selected, 4
	je exiting
	ret
endingselecttop:
	mov eax, 1
	mov Selected, eax
	ret
endingselectbot:
	mov eax, 4
	mov Selected, eax
	ret

mainmenumovement:
	cmp wParam, VK_UP
	je mainmenuupselect
	cmp wParam, VK_DOWN
	je mainmenudownselect
	cmp wParam, VK_RETURN
	je mainmenuselect
	cmp wParam, VK_ESCAPE
	je closing
	ret
mainmenuupselect:
	dec Selected
	cmp Selected, 1
	jl mainmenuselectbot
	ret
mainmenudownselect:
	inc Selected
	cmp Selected, 5	;number of buttons: new game, settings, help, credits, exit
	jg mainmenuselecttop
	ret
mainmenuselect:
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
mainmenuselecttop:
	mov eax, 1
	mov Selected, eax
	ret
mainmenuselectbot:
	mov eax, 5
	mov Selected, eax
	ret

audiomovement:
	ret

graphicsmovement:
	ret

settingsmovement:
	cmp wParam, VK_UP
	je settingsupselect
	cmp wParam, VK_DOWN
	je settingsdownselect
	cmp wParam, VK_RETURN
	je settingsselect
	cmp wParam, VK_ESCAPE
	je closing
	ret
settingsupselect:
	dec Selected
	cmp Selected, 1
	jl settingsselectbot
	ret
settingsdownselect:
	inc Selected
	cmp Selected, 3	;number of buttons: audio, graphics, back
	jg settingsselecttop
	ret
settingsselect:
	cmp Selected, 1
	je audio
	cmp Selected, 2
	je graphics
	cmp Selected, 3
	je backing
	ret
settingsselecttop:
	mov eax, 1
	mov Selected, eax
	ret
settingsselectbot:
	mov eax, 3
	mov Selected, eax
	ret

gamemovement:
	cmp wParam, VK_ESCAPE
	je closing
	cmp wParam, VK_P
	je pausing
	cmp wParam, VK_R
	je newgame
	cmp wParam, VK_RSHIFT
	je mainmenuboost1
	cmp wParam, VK_LSHIFT
	je mainmenuboost2
	invoke WhichPlayer, wParam
	cmp eax, 1
	je gamemovement1
	cmp eax, 2
	je gamemovement2
	cmp eax, -1
	je theend


mainmenuboost1:
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

mainmenuboost2:
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
	jle mainmenuboost1
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
	jle mainmenuboost2
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
	cmp status, MAINMENU
	je mainmenupaint
	cmp status, SETTINGS
	je settingspaint
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

mainmenupaint:
	invoke BeginPaint, hWnd, addr paint
	mov hdc, eax
	invoke DrawBG, status, rect, hdc, hWnd
	invoke EndPaint, hWnd, addr paint
	ret

settingspaint:
	invoke BeginPaint, hWnd, addr paint
	mov hdc, eax
	invoke DrawBG, status, rect, hdc, hWnd
	invoke EndPaint, hWnd, addr paint
	ret

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
	mov eax, status
	mov laststatus, eax
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
	mov eax, status
	mov laststatus, eax
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
	mov eax, status
	mov laststatus, eax
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
invoke LoadBitmap, eax, MAINMENU
mov MainMenuBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, SETTINGS
mov SettingsBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, ENDING
mov EndingBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, PAUSING
mov PausingBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, COLOR1
mov Color1BMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, COLOR1CHOSE
mov Color1ChoseBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, COLOR2
mov Color2BMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, EXITING
mov ExitingBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, HELPING
mov HelpingBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, CREDITS
mov CreditsBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, AUDIO
mov AudioBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, GRAPHICS
mov GraphicsBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, NEWGAMEBUTTON
mov NewGameButtonBMH, eax
invoke Get_Handle_To_Mask_Bitmap, NewGameButtonBMH, 0ffffffh		;white
mov NewGameButtonMaskBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, MAINMENUBUTTON
mov MainMenuButtonBMH, eax
invoke Get_Handle_To_Mask_Bitmap, MainMenuButtonBMH, 0ffffffh		;white
mov MainMenuButtonMaskBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, BACKBUTTON
mov BackButtonBMH, eax
invoke Get_Handle_To_Mask_Bitmap, BackButtonBMH, 0ffffffh		;white
mov BackButtonMaskBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, SETTINGSBUTTON
mov SettingsButtonBMH, eax
invoke Get_Handle_To_Mask_Bitmap, SettingsButtonBMH, 0ffffffh		;white
mov SettingsButtonMaskBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, AUDIOBUTTON
mov AudioButtonBMH, eax
invoke Get_Handle_To_Mask_Bitmap, AudioButtonBMH, 0ffffffh		;white
mov AudioButtonMaskBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, GRAPHICSBUTTON
mov GraphicsButtonBMH, eax
invoke Get_Handle_To_Mask_Bitmap, GraphicsButtonBMH, 0ffffffh		;white
mov GraphicsButtonMaskBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, RESUMEBUTTON
mov ResumeButtonBMH, eax
invoke Get_Handle_To_Mask_Bitmap, ResumeButtonBMH, 0ffffffh		;white
mov ResumeButtonMaskBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, HELPBUTTON
mov HelpButtonBMH, eax
invoke Get_Handle_To_Mask_Bitmap, HelpButtonBMH, 0ffffffh		;white
mov HelpButtonMaskBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, CREDITSBUTTON
mov CreditsButtonBMH, eax
invoke Get_Handle_To_Mask_Bitmap, CreditsButtonBMH, 0ffffffh		;white
mov CreditsButtonMaskBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, EXITBUTTON
mov ExitButtonBMH, eax
invoke Get_Handle_To_Mask_Bitmap, ExitButtonBMH, 0ffffffh		;white
mov ExitButtonMaskBMH, eax

invoke GetModuleHandle, NULL
invoke LoadBitmap, eax, HIGHLIGHT
mov HighlightBMH, eax
invoke Get_Handle_To_Mask_Bitmap, HighlightBMH, 0ffffffh		;white
mov HighlightMaskBMH, eax

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