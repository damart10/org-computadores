bits 32

numargs     equ 3
sys_exit    equ 1
sys_read    equ 3
sys_write   equ 4
stdin       equ 0 
stdout      equ 1
stderr      equ 3	

extern      openimage
extern      createtext
extern      saveimage
extern      cast
extern      printf

SECTION .data
fail:       db "The input image %s is invalid or doesn't exist", 10, 0
factor:     dd 0.8

SECTION .bss
img:        resd 1
text:       resd 1
size:       resd 1
dsize:      resd 1
scale:      resd 1
orwidth:    resd 1
orheight:   resd 1
txwidth:    resd 1

SECTION .text

global _main

_main: 
  mov   eax, [esp + 4]      ;mov to eax pos of first argument 
  mov   ebx, dword[eax]     ;store the arguments in variables
  mov   [img], ebx
  mov   ebx, dword[eax + 4]
  mov   [text], ebx

  push  img
  call  openimage           ;open the image

  cmp   eax, 0              ;see if the image was loaded correctly
  je    _fail               
  jne   _process

_process:
  mov   ebx, [eax]          ;store width of the original image
  mov   [orwidth], ebx      
  mov   ebx, [eax + 4]      ;store initial value of size (height)
  mov   [orheight], ebx  

  mov   eax, orwidth        ;calculate the text scale and store it
  mov   ebx, factor
  imul  eax, ebx
  mov   [scale], eax

  mov   eax, [orheight]  ;create img with text
  mov   [size], eax
  push  dword[size]
  push  dword[text]
  call  createtext
  mov   [txwidth], eax

  mov   eax, [orwidth]
  mov   ebx, [txwidth]
  cmp   eax, ebx            ;compare width with original 
  jl    _create             ;jump if txwidth < orwidth
  
  mov   eax, [scale]        ;calculate new scale
  div   dword[txwidth]
  mov   [scale], eax        ;store the new scale

  mov   eax, [scale]        ;calculate the new text size..
  mov   ebx, [size]         ;..based on the new scale
  imul  eax, ebx
  mov   [dsize], eax

  push  dword[dsize]        ;cast the new size to int
  call  cast

  mov   [size], eax         ;store the new size 
  jmp   _create             ;jump to create

_create:
  push dword[size]          ;create and save the new img
  push dword[text]
  call saveimage
  jmp _exit

_fail:
  push  dword[img]          ;print the error message
  push  fail
  call  printf
  jmp   _exit

_exit:
  mov   eax, sys_exit
  int   80H