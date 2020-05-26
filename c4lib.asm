section .data

endl db 0x0a

section .text

;copies array pointed to by rsi to one pointed to by rdi, of length rcx
global copyArray
copyArray:
    copyLoop:
        push rax
        mov al, byte [rsi+rcx-1]
        mov byte [rdi+rcx-1], al
        pop rax
        loop copyLoop
    ret

;print newline character
global printEndl
printEndl:
    push rax
    push rdi
    push rsi
    push rdx
    
    mov rax, 0x1
    mov rdi, 0x1
    mov rsi, endl
    mov rdx, 0x1
    syscall

    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

;print byte array, address of starting array character defined in rsi, length of array to print defined in rdx
global printByteArray
printByteArray:
    push rax
    push rdi
    
    mov rax, 0x1
    mov rdi, 0x1
    syscall

    pop rdi
    pop rax
    ret

global getByteArray
getByteArray:
    push rax
    push rdi

    mov rax, 0x0
    mov rdi, 0x0
    syscall

    pop rdi
    pop rax
    ret

global exitNormal
exitNormal:
    push rax
    push rdi

    mov rax, 0x3C
    mov rdi, 0x0
    syscall

    pop rdi
    pop rax
    ret
