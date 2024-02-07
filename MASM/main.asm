ExitProcess PROTO
GetStdHandle PROTO
ReadConsoleA PROTO
WriteConsoleA PROTO

.data

std_out_handle QWORD ?
std_in_handle QWORD ?
bytes_written QWORD ?
bytesRead QWORD ?

buffer BYTE 128 dup(?)

promptMessage BYTE "Enter a number: ", 0

.code
main PROC
    
    ; reserve shadow space
    sub rsp, 5 * 8


    ; Get std handle and display the prompt
    mov rcx, -11
    call GetStdHandle
    
    mov std_out_handle, rax

    mov rcx, rax
    lea rdx, promptMessage
    mov r8, LENGTHOF promptMessage - 1
    lea r9, bytesRead
    push 0
    call WriteConsoleA

    ; Get standard input handle and read input into buffer
    mov rcx, -10
    call GetStdHandle

    mov std_in_handle, rax

    mov rcx, rax
    lea rdx, buffer
    mov r8, 128
    lea r9, bytesRead
    push 0
    call ReadConsoleA

    ; Initialize RAX to 0, clearing any previous value, to prepare for numerical conversion
    mov rax, 0

    ; Grabs the first adress at the start of the buffer
    lea rsi, [buffer]

    ; Loop to convert a string into numerical value, completed using RAX
convertLoop:

    ; Move the byte at the memoery location [rsi] and zero-extending to fit the size of RDX
    ; Zero-extending is done when a 8 bit value (comprised of e.x ('00001101' = 13)) is to fit into a 64-bit register like RDX
    ; Using movzx moves the value to the lower end( = right end) of the register and the remaining bits to the left
    ; are filled with zero.
    movzx rdx, byte ptr [rsi]

    ; Check for end of input (newline or return), if true jmp out of the loop
    ; DL (8-bit register) is the lower part (DH higher part) of the DX register this continues up to the RDX registry, meaning that
    ; whatever is stored in DL is in a way reachable in RDX as well. Important to understand the different architectures!
    ; Modifying DL, only modifies the lower bits of the DX registry and not more.
    cmp dl, 10  ; Check \n
    je convertDone
    cmp dl, 13   ; Check \r
    je convertDone

    ; Subtract '0' to get the actual numerical value
    ; In ASCII '0' is represented by 48, lets say we want to get '2' (ASCII = 50), we would have to remove '0' and get '2'
    ; It looks like this when executed, 50 - 48 = 2
    sub dl, '0'

    ; Multiply (imul = integer multiplication) RAX by 10 and add the current digit
    ; RAX holds the final results why the loop is iterating and modifying the DL register
    ; Each time a new digit is added to the RDX registry it first needs to be moved into the correct spot
    ; I.e if RAX holds the current digit of 23 and the input was 234 we first need to create room (multiplying) for the next (and in this case final) digit 
    ; 23 * 10 = 230, adding 4 gives 234
    imul rax, rax, 10
    add rax, rdx

    ; Increments RSI register which points to the next character in the input buffer
    inc rsi
    jmp convertLoop

convertDone:

    ; Converted number is used as exit code
    mov rcx, rax

    call ExitProcess

main ENDP
END