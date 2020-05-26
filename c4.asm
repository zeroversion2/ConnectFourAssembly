section .data

;external function resources
extern printByteArray
extern getByteArray
extern printEndl
extern exitNormal
extern copyArray

;variable definitions
clear db 0x1b, "[H", 0x1b,"[J"
clearLen dq $-clear

selectPos dq 1
selectString db "               "
selectStringLen dq $-selectString

gridBar db "---------------"
gridBarLen dq $-gridBar

gridMid db "| | | | | | | |"
gridMidLen dq $-gridMid

winOMsg db "O is winner!"
winOMsgLen dq $-winOMsg

winXMsg db "X is winner!"
winXMsgLen dq $-winXMsg

turn dq 0
playerChar db 'O'

won db 0
winner db 0
 
section	.bss

;variable declarations
read_test resb 10
drawString resb 15
pieceGrid resq 6

section	.text

;begin program 	
global startASM

startASM:

gameLoop:

    mov rsi, clear
    mov rdx, [clearLen]
    call printByteArray

    ;determine player char
    mov rax, [turn]
    mov rbx, 9           ;difference between 'X' and 'O' in ascii
    mul rbx
    mov rbx, 'O'
    add rbx, rax
    mov [playerChar], bl

    ;copy top string to working string
    mov rsi, selectString
    mov rdi, drawString
    mov rcx, 15
    call copyArray

    ;draw top string
    mov rdi, [selectPos]
    mov al, [playerChar]
    mov byte [drawString+rdi], al
    mov rsi, drawString
    mov rdx, [selectStringLen]
    call printByteArray
    call printEndl

    mov rsi, gridBar
    mov rdx, [gridBarLen]
    call printByteArray
    call printEndl

    xor rbx, rbx
    printLoop:
        mov rsi, gridMid
        mov rdi, drawString
        mov rcx, 15
        call copyArray

        mov rcx, 7
        replaceLoop:
            dec rcx
            mov al, byte [pieceGrid+(rbx*8)+rcx]
            cmp al, 1
            je makeO

            cmp al, 2
            je makeX

            mov rdx, ' '
            jmp choiceMade

            makeO:
                mov rdx, 'O'
                jmp choiceMade

            makeX:
                mov rdx, 'X'
                ;jmp choiceMade

            choiceMade:

            mov byte [drawString+(rcx*2)+1], dl
            inc rcx
            loop replaceLoop

        ;draw 
        mov rsi, drawString
        mov rdx, [gridMidLen]
        call printByteArray
        call printEndl

        mov rsi, gridBar
        mov rdx, [gridBarLen]
        call printByteArray
        call printEndl

        inc rbx
        cmp rbx, 5
        jle printLoop

        cmp byte [won], 1
        je printWin

    getInput:
        mov rsi, read_test
        mov rdx, 10
        call getByteArray

        ;check if enter key pressed
        cmp byte [read_test], 0x0a
        je handleEnter

        ;check if arrow key pressed
        cmp byte [read_test], 0x1b
        jne getInput

        ;check if left arrow key
        cmp byte [read_test+2], 0x44
        je handleLeft

        ;check if right arrow key
        cmp byte [read_test+2], 0x43
        je handleRight

    handleLeft:
        mov rax, qword [selectPos]
        cmp rax, 1
        jle getInput

        sub rax, 2
        mov qword [selectPos], rax
        jmp gameLoop

    handleRight:
        mov rax, qword [selectPos]
        cmp rax, 13
        jge getInput

        add rax, 2
        mov qword [selectPos], rax
        jmp gameLoop

    handleEnter:
        mov rcx, 6
        checkEmpty:
            mov rbx, 2
            mov rax, [selectPos]
            div bl
            movzx rax, al
            mov rdi, rax
            cmp byte [pieceGrid+((rcx-1)*8)+rdi], 0
            je fillSlot
            dec rcx
            cmp rcx, 0
            jge checkEmpty

        fillSlot:
            mov rax, [turn]
            inc al
            mov byte [pieceGrid+((rcx-1)*8)+rdi], al
            mov rdx, rax
            dec al
            xor al, 0x1
            mov [turn], al

        mov rbx, rcx
        dec rbx

        xor rcx, rcx
        inc rcx
        mov r9, rdi
        cmp r9, 0
        je checkRowRight
        checkRowLeft:
            dec r9
            cmp byte [pieceGrid+(rbx*8)+r9], dl
            jne checkRowRightPre
            inc rcx
            cmp rcx, 4
            jge onWin
            cmp r9, 0
            je checkRowRightPre
            jmp checkRowLeft

        checkRowRightPre:
            mov r9, rdi
            cmp r9, 6
            je checkColumnPre
        checkRowRight:
            inc r9
            cmp byte [pieceGrid+(rbx*8)+r9], dl
            jne checkColumnPre
            inc rcx
            cmp rcx, 4
            jge onWin
            jmp checkRowRight

        checkColumnPre:
        mov r8, rbx
        cmp r8, 2
        jle checkDiagonalPre
        xor rcx, rcx
        checkColumn:
            inc r8
            cmp byte [pieceGrid+(r8*8)+rdi], dl
            jne checkDiagonalPre
            inc rcx
            cmp rcx, 3
            jge onWin
            jmp checkColumn

        checkDiagonalPre:
        mov r8, rbx
        mov r9, rdi
        xor rcx, rcx
        inc rcx
        cmp r8, 5
        je checkDiagonalUpperRightPre
        cmp r9, 0
        je checkDiagonalUpperRightPre
        checkDiagonalLowerLeft:
            inc r8
            dec r9
            cmp byte [pieceGrid+(r8*8)+r9], dl
            jne checkDiagonalUpperRightPre
            inc rcx
            cmp rcx, 4
            jge onWin
            cmp r8, 5
            je checkDiagonalUpperRightPre
            cmp r9, 0
            je checkDiagonalUpperRightPre
            jmp checkDiagonalLowerLeft

        checkDiagonalUpperRightPre:
        mov r8, rbx
        mov r9, rdi
        cmp r8, 0
        je checkDiagonalUpperLeftPre
        cmp r9, 6
        je checkDiagonalUpperLeftPre
        checkDiagonalUpperRight:
            dec r8
            inc r9
            cmp byte [pieceGrid+(r8*8)+r9], dl
            jne checkDiagonalUpperLeftPre
            inc rcx
            cmp rcx, 4
            jge onWin
            cmp r8, 0
            je checkDiagonalUpperLeftPre
            cmp r9, 6
            je checkDiagonalUpperLeftPre
            jmp checkDiagonalUpperRight

        checkDiagonalUpperLeftPre:
        mov r8, rbx
        mov r9, rdi
        xor rcx, rcx
        inc rcx
        cmp r8, 0
        je checkDiagonalLowerRightPre
        cmp r9, 0
        je checkDiagonalLowerRightPre
        checkDiagonalUpperLeft:
            dec r8
            dec r9
            cmp byte [pieceGrid+(r8*8)+r9], dl
            jne checkDiagonalLowerRightPre
            inc rcx
            cmp rcx, 4
            jge onWin
            cmp r8, 5
            je checkDiagonalLowerRightPre
            cmp r9, 0
            je checkDiagonalLowerRightPre
            jmp checkDiagonalUpperLeft

        checkDiagonalLowerRightPre:
        mov r8, rbx
        mov r9, rdi
        cmp r8, 5
        je gameLoop
        cmp r9, 6
        je gameLoop
        checkDiagonalLowerRight:
            inc r8
            inc r9
            cmp byte [pieceGrid+(r8*8)+r9], dl
            jne gameLoop
            inc rcx
            cmp rcx, 4
            jge onWin
            cmp r8, 5
            je gameLoop
            cmp r9, 6
            je gameLoop
            jmp checkDiagonalLowerRight

        jmp gameLoop

    onWin:
        mov byte [won], 1
        dec dl
        mov [winner], dl
        jmp gameLoop

    printWin:
        cmp byte [winner], 1
        jne winO

        winX:
        mov rsi, winXMsg
        mov rdx, [winXMsgLen]
        call printByteArray
        call printEndl
        jmp end

        winO:
        mov rsi, winOMsg
        mov rdx, [winOMsgLen]
        call printByteArray
        call printEndl

    end:
