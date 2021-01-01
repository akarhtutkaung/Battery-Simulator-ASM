	.file	"batt_update.c"
	.text
	.globl	set_batt_from_ports
	.type	set_batt_from_ports, @function
set_batt_from_ports:
.LFB52:
	.cfi_startproc
	movzwl	BATT_VOLTAGE_PORT(%rip), %eax
	testw	%ax, %ax
	js	.L7
	movw	%ax, (%rdi)
	cmpw	$3799, %ax
	jle	.L3
	movb	$100, 2(%rdi)
.L4:
	testb	$1, BATT_STATUS_PORT(%rip)
	jne	.L8
	movb	$0, 3(%rdi)
	movl	$0, %eax
	ret
.L3:
	cmpw	$3000, %ax
	jg	.L5
	movb	$0, 2(%rdi)
	jmp	.L4
.L5:
	movswl	BATT_VOLTAGE_PORT(%rip), %edx
	subl	$3000, %edx
	leal	7(%rdx), %eax
	testl	%edx, %edx
	cmovns	%edx, %eax
	sarl	$3, %eax
	movb	%al, 2(%rdi)
	jmp	.L4
.L8:
	movb	$1, 3(%rdi)
	movl	$0, %eax
	ret
.L7:
	movl	$1, %eax
	ret
	.cfi_endproc
.LFE52:
	.size	set_batt_from_ports, .-set_batt_from_ports
	.globl	set_display_from_batt
	.type	set_display_from_batt, @function
set_display_from_batt:
.LFB53:
	.cfi_startproc
	pushq	%r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	pushq	%rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	pushq	%rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	subq	$48, %rsp
	.cfi_def_cfa_offset 80
	movq	%fs:40, %rax
	movq	%rax, 40(%rsp)
	xorl	%eax, %eax
	movl	$0, (%rsi)
	movl	$63, (%rsp)
	movl	$3, 4(%rsp)
	movl	$109, 8(%rsp)
	movl	$103, 12(%rsp)
	movl	$83, 16(%rsp)
	movl	$118, 20(%rsp)
	movl	$126, 24(%rsp)
	movl	$35, 28(%rsp)
	movl	$127, 32(%rsp)
	movl	$119, 36(%rsp)
	movswl	%di, %ecx
	imull	$5243, %ecx, %ecx
	sarl	$19, %ecx
	movl	%edi, %eax
	sarw	$15, %ax
	subl	%eax, %ecx
	leal	(%rcx,%rcx,4), %ecx
	leal	(%rcx,%rcx,4), %ecx
	leal	0(,%rcx,4), %eax
	movl	%edi, %ecx
	subl	%eax, %ecx
	movswl	%cx, %ecx
	movl	$1717986919, %edx
	movl	%ecx, %eax
	imull	%edx
	sarl	$2, %edx
	movl	%ecx, %eax
	sarl	$31, %eax
	subl	%eax, %edx
	leal	(%rdx,%rdx,4), %edx
	leal	(%rdx,%rdx), %eax
	movl	%ecx, %edx
	subl	%eax, %edx
	cmpl	$4, %edx
	jle	.L10
	movl	$1717986919, %edx
	movl	%ecx, %eax
	imull	%edx
	sarl	$2, %edx
	sarl	$31, %ecx
	subl	%ecx, %edx
	leal	1(%rdx), %ebx
.L11:
	movswl	%di, %edx
	imull	$-31981, %edx, %eax
	shrl	$16, %eax
	addl	%edi, %eax
	sarw	$9, %ax
	movl	%edi, %ecx
	sarw	$15, %cx
	subl	%ecx, %eax
	imulw	$1000, %ax, %ax
	movl	%edi, %r11d
	subl	%eax, %r11d
	movl	%r11d, %eax
	movswl	%r11w, %r11d
	imull	$5243, %r11d, %r11d
	sarl	$19, %r11d
	sarw	$15, %ax
	subl	%eax, %r11d
	movswl	%r11w, %r11d
	imull	$6711, %edx, %eax
	sarl	$26, %eax
	subl	%ecx, %eax
	imulw	$10000, %ax, %ax
	movl	%edi, %ecx
	subl	%eax, %ecx
	movl	%ecx, %eax
	movswl	%cx, %r8d
	imull	$-31981, %r8d, %r8d
	shrl	$16, %r8d
	addl	%eax, %r8d
	sarw	$9, %r8w
	sarw	$15, %ax
	subl	%eax, %r8d
	movswl	%r8w, %r8d
	movl	%edi, %ebp
	sall	$8, %ebp
	sarl	$24, %ebp
	movsbw	%bpl, %dx
	imull	$103, %edx, %r9d
	sarw	$10, %r9w
	movl	%ebp, %ecx
	sarb	$7, %cl
	subl	%ecx, %r9d
	leal	(%r9,%r9,4), %r9d
	leal	(%r9,%r9), %eax
	movl	%ebp, %r9d
	subl	%eax, %r9d
	movsbl	%r9b, %r9d
	leal	(%rdx,%rdx,4), %eax
	leal	(%rdx,%rax,8), %eax
	sarw	$12, %ax
	subl	%ecx, %eax
	movl	$100, %edx
	imull	%edx, %eax
	movl	%ebp, %edx
	subl	%eax, %edx
	movl	%edx, %eax
	movsbw	%dl, %r10w
	imull	$103, %r10d, %r10d
	sarw	$10, %r10w
	sarb	$7, %al
	subl	%eax, %r10d
	movsbl	%r10b, %r10d
	movsbl	%bpl, %r12d
	movl	$274877907, %edx
	movl	%r12d, %eax
	imull	%edx
	sarl	$6, %edx
	movl	%r12d, %eax
	sarl	$31, %eax
	subl	%eax, %edx
	imull	$1000, %edx, %ecx
	subl	%ecx, %r12d
	movl	%r12d, %ecx
	movl	$1374389535, %edx
	movl	%r12d, %eax
	imull	%edx
	sarl	$5, %edx
	sarl	$31, %ecx
	subl	%ecx, %edx
	sarl	$24, %edi
	testb	%dil, %dil
	jne	.L12
	movslq	%ebx, %rbx
	movl	(%rsp,%rbx,4), %eax
	orl	$6291456, %eax
	movl	%eax, (%rsi)
.L13:
	testb	%dil, %dil
	jne	.L14
	testl	%r8d, %r8d
	jle	.L14
	movslq	%r8d, %r8
	movl	(%rsp,%r8,4), %eax
	sall	$14, %eax
	orl	%eax, (%rsi)
.L14:
	testb	%dil, %dil
	jne	.L15
	testl	%r11d, %r11d
	js	.L15
	movslq	%r11d, %r11
	movl	(%rsp,%r11,4), %eax
	sall	$7, %eax
	orl	%eax, (%rsi)
.L15:
	cmpb	$1, %dil
	je	.L26
.L16:
	cmpb	$1, %dil
	je	.L27
.L17:
	cmpb	$1, %dil
	je	.L28
.L18:
	leal	-5(%rbp), %eax
	cmpb	$24, %al
	jbe	.L29
	cmpb	$44, %al
	jbe	.L30
	cmpb	$64, %al
	jbe	.L31
	cmpb	$84, %al
	jbe	.L32
	cmpb	$89, %bpl
	jle	.L20
	movl	(%rsi), %eax
	orl	$520093696, %eax
	movl	%eax, (%rsi)
	jmp	.L20
.L10:
	movl	$1717986919, %edx
	movl	%ecx, %eax
	imull	%edx
	sarl	$2, %edx
	sarl	$31, %ecx
	movl	%edx, %ebx
	subl	%ecx, %ebx
	jmp	.L11
.L12:
	cmpb	$1, %dil
	jne	.L13
	movslq	%r9d, %r9
	movl	(%rsp,%r9,4), %eax
	orl	$8388608, %eax
	movl	%eax, (%rsi)
	jmp	.L13
.L26:
	testl	%edx, %edx
	jle	.L16
	movslq	%edx, %rax
	movl	(%rsp,%rax,4), %eax
	sall	$14, %eax
	orl	%eax, (%rsi)
	jmp	.L16
.L27:
	testl	%edx, %edx
	setne	%cl
	movl	%r10d, %eax
	notl	%eax
	shrl	$31, %eax
	testb	%cl, %cl
	je	.L17
	testb	%al, %al
	je	.L17
	movslq	%r10d, %r10
	movl	(%rsp,%r10,4), %eax
	sall	$7, %eax
	orl	%eax, (%rsi)
	jmp	.L18
.L28:
	testl	%edx, %edx
	sete	%al
	testl	%r10d, %r10d
	setg	%dl
	testb	%al, %al
	je	.L18
	testb	%dl, %dl
	je	.L18
	movslq	%r10d, %r10
	movl	(%rsp,%r10,4), %eax
	sall	$7, %eax
	orl	%eax, (%rsi)
	jmp	.L18
.L29:
	orl	$268435456, (%rsi)
.L20:
	movl	$0, %eax
	movq	40(%rsp), %rbx
	xorq	%fs:40, %rbx
	jne	.L33
	addq	$48, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 32
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	ret
.L30:
	.cfi_restore_state
	movl	(%rsi), %eax
	orl	$402653184, %eax
	movl	%eax, (%rsi)
	jmp	.L20
.L31:
	movl	(%rsi), %eax
	orl	$469762048, %eax
	movl	%eax, (%rsi)
	jmp	.L20
.L32:
	movl	(%rsi), %eax
	orl	$503316480, %eax
	movl	%eax, (%rsi)
	jmp	.L20
.L33:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE53:
	.size	set_display_from_batt, .-set_display_from_batt
	.globl	batt_update
	.type	batt_update, @function
batt_update:
.LFB54:
	.cfi_startproc
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	subq	$16, %rsp
	.cfi_def_cfa_offset 32
	movq	%fs:40, %rax
	movq	%rax, 8(%rsp)
	xorl	%eax, %eax
	leaq	4(%rsp), %rdi
	call	set_batt_from_ports
	testl	%eax, %eax
	je	.L39
	movl	$1, %ebx
.L34:
	movl	%ebx, %eax
	movq	8(%rsp), %rdx
	xorq	%fs:40, %rdx
	jne	.L40
	addq	$16, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 16
	popq	%rbx
	.cfi_def_cfa_offset 8
	ret
.L39:
	.cfi_restore_state
	movl	%eax, %ebx
	movq	%rsp, %rsi
	movl	4(%rsp), %edi
	call	set_display_from_batt
	movl	(%rsp), %eax
	movl	%eax, BATT_DISPLAY_PORT(%rip)
	jmp	.L34
.L40:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE54:
	.size	batt_update, .-batt_update
	.ident	"GCC: (Ubuntu 7.4.0-1ubuntu1~18.04.1) 7.4.0"
	.section	.note.GNU-stack,"",@progbits
