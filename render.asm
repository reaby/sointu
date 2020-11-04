; source file for compiling sointu as a library
%define SU_DISABLE_PLAYER

%include "sointu/header.inc"

; TODO: make sure compile everything in

USE_ENVELOPE
USE_OSCILLAT
USE_MULP
USE_PAN
USE_OUT

%define INCLUDE_TRISAW
%define INCLUDE_SINE
%define INCLUDE_PULSE
%define INCLUDE_GATE
%define INCLUDE_STEREO_OSCILLAT
%define INCLUDE_STEREO_ENVELOPE
%define INCLUDE_STEREO_OUT
%define INCLUDE_POLYPHONY
%define INCLUDE_MULTIVOICE_TRACKS

%include "sointu/footer.inc"

section .text

struc su_synth
    .synthwrk   resb    su_synthworkspace.size
    .delaywrks  resb    su_delayline_wrk.size * 64    
    .randseed   resd    1
    .globaltime resd    1  
    .commands   resb    32 * 64
    .values     resb    32 * 64 * 8
    .polyphony  resd    1
    .numvoices  resd    1
endstruc

SECT_TEXT(sursampl)

EXPORT MANGLE_FUNC(su_render,16)
%if BITS == 32  ; stdcall    
    pushad                  ; push registers
    mov     ecx, [esp + 4 + 32] ; ecx = &synthState    
    mov     edx, [esp + 8 + 32]  ; edx = &buffer 
    mov     esi, [esp + 12 + 32]  ; esi = &samples
    mov     ebx, [esp + 16 + 32]  ; ebx = &time
%else
    %ifidn __OUTPUT_FORMAT__,win64 ; win64 ABI: rcx = &synth, rdx = &buffer, r8 = &bufsize, r9 = &time
        push_registers rdi, rsi, rbx, rbp ; win64 ABI: these registers are non-volatile
        mov     rsi, r8 ; rsi = &samples        
        mov     rbx, r9 ; rbx = &time
    %else ; System V ABI: rdi = &synth, rsi = &buffer, rdx = &samples, rcx = &time
        push_registers rbx, rbp ; System V ABI: these registers are non-volatile   
        mov     rbx, rcx ; rbx points to time
        xchg    rsi, rdx ; rdx points to buffer, rsi points to samples
        mov     rcx, rdi ; rcx = &Synthstate
    %endif
%endif
    push    _SI         ; push the pointer to samples
    push    _BX         ; push the pointer to time
    xor     eax, eax    ; samplenumber starts at 0
    push    _AX         ; push samplenumber to stack
    mov     esi, [_SI]  ; zero extend dereferenced pointer
    push    _SI         ; push bufsize
    push    _DX         ; push bufptr
    push    _CX         ; this takes place of the voicetrack
    mov     eax, [_CX + su_synth.randseed]
    push    _AX                             ; randseed
    mov     eax, [_CX + su_synth.globaltime]
    push    _AX                        ; global tick time    
    mov     ebx, dword [_BX]           ; zero extend dereferenced pointer
    push    _BX                        ; the nominal rowlength should be time_in
    xor     eax, eax                   ; rowtick starts at 0
su_render_samples_loop:
        cmp     eax, [_SP]                    ; if rowtick >= maxtime
        jge     su_render_samples_time_finish ;   goto finish
        mov     ecx, [_SP + PTRSIZE*5]        ; ecx = buffer length in samples
        cmp     [_SP + PTRSIZE*6], ecx        ; if samples >= maxsamples
        jge     su_render_samples_time_finish ;   goto finish
        inc     eax                           ; time++
        inc     dword [_SP + PTRSIZE*6]       ; samples++
        mov     _CX, [_SP + PTRSIZE*3]
        push    _AX                        ; push rowtick
        mov     eax, [_CX + su_synth.polyphony]
        push    _AX                        ;polyphony
        mov     eax, [_CX + su_synth.numvoices]
        push    _AX                        ;numvoices
        lea     _DX, [_CX+ su_synth.synthwrk] 
        lea     COM, [_CX+ su_synth.commands] 
        lea     VAL, [_CX+ su_synth.values] 
        lea     WRK, [_DX + su_synthworkspace.voices]  
        lea     _CX, [_CX+ su_synth.delaywrks - su_delayline_wrk.filtstate] 
        call    MANGLE_FUNC(su_run_vm,0)
        pop     _AX
        pop     _AX
        mov     _DI, [_SP + PTRSIZE*5] ; edi containts buffer ptr
        mov     _CX, [_SP + PTRSIZE*4]
        lea     _SI, [_CX + su_synth.synthwrk + su_synthworkspace.left]
        movsd   ; copy left channel to output buffer
        movsd   ; copy right channel to output buffer
        mov     [_SP + PTRSIZE*5], _DI ; save back the updated ptr
        lea     _DI, [_SI-8]
        xor     eax, eax
        stosd   ; clear left channel so the VM is ready to write them again
        stosd   ; clear right channel so the VM is ready to write them again
        pop     _AX
        inc     dword [_SP + PTRSIZE] ; increment global time, used by delays
        jmp     su_render_samples_loop
su_render_samples_time_finish:
    pop     _CX
    pop     _BX
    pop     _DX    
    pop     _CX
    mov     [_CX + su_synth.randseed], edx
    mov     [_CX + su_synth.globaltime], ebx            
    pop     _BX
    pop     _BX
    pop     _DX
    pop     _BX  ; pop the pointer to time
    pop     _SI  ; pop the pointer to samples
    mov     dword [_SI], edx  ; *samples = samples rendered
    mov     dword [_BX], eax  ; *time = time ticks rendered
    xor     eax, eax ; TODO: set eax to possible error code, now just 0
%if BITS == 32  ; stdcall
    mov     [_SP + 28],eax ; we want to return eax, but popad pops everything, so put eax to stack for popad to pop 
    popad
    ret 16
%else
    %ifidn __OUTPUT_FORMAT__,win64
        pop_registers rdi, rsi, rbx, rbp ; win64 ABI: these registers are non-volatile
    %else
        pop_registers rbx, rbp ; System V ABI: these registers are non-volatile   
    %endif
    ret
%endif