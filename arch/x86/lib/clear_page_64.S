#include <linux/linkage.h>
#include <asm/export.h>

/*
 * Most CPUs support enhanced REP MOVSB/STOSB instructions. It is
 * recommended to use this when possible and we do use them by default.
 * If enhanced REP MOVSB/STOSB is not available, try to use fast string.
 * Otherwise, use original.
 */

/*
 * Zero a page.
 * %rdi	- page
 */

/*  To remove non temporal page zeroing, uncomment this block.   */
/*------------------------Default logic for copying--------------*/
/*
ENTRY(clear_page_rep)
	movl $4096/8,%ecx
	xorl %eax,%eax
	rep stosq
	ret
ENDPROC(clear_page_rep)
*/
/*---------------------------------------------------------------*/

/*-------Modified logic for copying using non temporal writes----*/
ENTRY(clear_page_rep)
       xorq    %rax, %rax
       movl    $4096/64, %ecx
       .p2align 4
1:
       decl    %ecx
       movnti  %rax,(%rdi)
       movnti  %rax,0x8(%rdi)
       movnti  %rax,0x10(%rdi)
       movnti  %rax,0x18(%rdi)
       movnti  %rax,0x20(%rdi)
       movnti  %rax,0x28(%rdi)
       movnti  %rax,0x30(%rdi)
       movnti  %rax,0x38(%rdi)
       leaq    64(%rdi),%rdi
       jnz     1b
       nop
       ret
ENDPROC(clear_page_rep)
/*---------------------------------------------------------------*/
EXPORT_SYMBOL_GPL(clear_page_rep)

ENTRY(clear_page_orig)
	xorl   %eax,%eax
	movl   $4096/64,%ecx
	.p2align 4
.Lloop:
	decl	%ecx
#define PUT(x) movq %rax,x*8(%rdi)
	movq %rax,(%rdi)
	PUT(1)
	PUT(2)
	PUT(3)
	PUT(4)
	PUT(5)
	PUT(6)
	PUT(7)
	leaq	64(%rdi),%rdi
	jnz	.Lloop
	nop
	ret
ENDPROC(clear_page_orig)
EXPORT_SYMBOL_GPL(clear_page_orig)

ENTRY(clear_page_erms)
	movl $4096,%ecx
	xorl %eax,%eax
	rep stosb
	ret
ENDPROC(clear_page_erms)
EXPORT_SYMBOL_GPL(clear_page_erms)
