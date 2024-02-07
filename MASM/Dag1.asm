ExitProcess PROTO

.data

.code

main PROC

	mov rsi, 10 ; Which number in the fibonacci sequence should be displayed?
	mov rax, 0 ; num1
	mov rcx, 1 ; num2
	mov rdx, 0 ; nextNum

	loop1:
		sub rsi, 1 ; removes 1 from the counter

		mov rdx, rax ; moves num1 to nextNum
		add rdx, rcx ; adds num2 to nextNum

		mov rax, rcx ; moves num2 to num1

		mov rcx, rdx ; moves nextNum to num2

		cmp rsi, 1 ; checks if counter is 0
		jne loop1


	call ExitProcess

main ENDP

END


COMMENT @
Solution 1
	mov rax, 0
	mov rcx, 0

	loop1:
	
	add rcx, 1
	add rax, 5
	cmp rcx, 10
	jle loop1

	mov rcx, rax
	@