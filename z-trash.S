# Copy - Copy from one location to another
# Scale -  Retrieve frommemory, scale by constant annd store in memory  (This kernel multiplies a large block of memory by a scalar value.)
# Add - Add from two differnt memory locations and store result
# Triad - retrieves two numbers from memory, scales by a constant and stores back to different location.

#Flash = .text + .data

.bss # uninitialized data in RAM
    A:  .skip   800000000
    B:  .skip   800000000
    C:  .skip   800000000

.data # initialized data in FLASH > RAM
    N:              .quad   1000000
    time_start:     .quad   0
    time_end:       .quad   0
    sieze_Mb:       .quad   0

.text # code or constant data in FLASH, read only
    init:       .asciz  "Performing benchmark...\n"
    separator:  .asciz  "|------------------------------------------|\n"
    header:     .asciz  "|  name    |   kernel      |      Speed    |\n"
    formatString:       .asciz  "|  copy    |   a(i) = b(i) |      %u MB/s  |\n"  
    ss: .asciz "debug print: %d"

.global main
main:
    pushq   %rbp                # store the caller's base pointer
    movq    %rsp, %rbp          # initialize the base pointer
    
    movq    $0, %rax
    movq    $init, %rdi
    call    printf

    leaq    C(%rip), %rcx       # laod first element of array C
    leaq    B(%rip), %rdx       # laod first element of array B
    leaq    A(%rip), %rsi       # laod first element of array A
    movq    N, %rdi             # array size
    call    fill                # fill the arrays with values


    rdtscp            # read timestamp counter into edx:eax
    shl $32, %rdx     # shift the upper 32 bits into the upper half of rdx
    or %rdx, %rax     # combine the upper and lower halves of the timestamp counter

    movq %rax, %r8     # save the first timestamp

    leaq    B(%rip), %rdx       # laod first element of array B
    leaq    A(%rip), %rsi       # laod first element of array A
    movq    N, %rdi             # array size
    call    copy_kernal

    # some code to measure the time interval
    rdtscp            # read timestamp counter into edx:eax
    shl $32, %rdx     # shift the upper 32 bits into the upper half of rdx
    or %rdx, %rax     # combine the upper and lower halves of the timestamp counter

    subq %r8, %rax     # calculate the difference in CPU cycles
    
    
    #time in milliseconds = (CPU cycles / CPU frequency) * 1000
    

    movq    %rax, %rsi
    movq    $formatString, %rdi
    call    printf

    jmp     end

copy_kernal:
    movq    (%rdx), %r13 
    movq    %r13, (%rsi)
    
    subq    $1, %rdi
    addq    $8, %rdx
    addq    $8, %rsi 
    
    cmpq    $0, %rdi    
    jg      copy_kernal

    ret


fill:  
    movq    %rdi, (%rcx)
    movq    %rdi, (%rdx)
    movq    %rdi, (%rsi)
    
    addq    $8, %rcx
    addq    $8, %rdx
    addq    $8, %rsi

    subq    $1, %rdi
    cmpq    $0, %rdi    
    jg      fill
    ret 

end:
    movq    $0, %rax
    call    exit



// .section .data
// N:  .quad (1<<20)
// t_format: .string "copy time: %f\n"
// CLOCKS_PER_SEC: .quad 1000000

// .section .bss
// a:  .fill  (1<<20),8,0
// b:  .fill  (1<<20),8,0

// .section .text
// .globl main

// main:
//   pushq %rbp
//   movq %rsp, %rbp
//   subq $16, %rsp # allocate 16 bytes on the stack for two doubles
//   xorq %rax, %rax
//   xorq %rbx, %rbx

//   # initialize array a with values i=0 to N-1
//   leaq a(%rip), %rdi
//   movq $0, %rbx
// init_loop:
//   cmpq N(%rip), %rbx
//   je init_done
//   movq %rbx, (%rdi)
//   addq $8, %rdi
//   incq %rbx
//   jmp init_loop
// init_done:

//   # copy array a to array b
//   leaq a(%rip), %rdi
//   leaq b(%rip), %rsi
//   movq N(%rip), %rdx
//   callq copy

//   # measure elapsed time
//   callq clock
//   movq %rax, (%rsp) # store start time

//   leaq a(%rip), %rdi
//   leaq b(%rip), %rsi
//   movq N(%rip), %rdx
//   callq copy

//   callq clock
//   subq (%rsp), %rax

//   movq %rax, % 
//   movq t_format(%rip), %rdi
//   callq printf

//   addq $16, %rsp # deallocate stack space
//   popq %rbp
//   ret

// copy:
//   pushq %rbp
//   movq %rsp, %rbp
//   pushq %r12 # preserve registers
//   pushq %r13
//   pushq %r14
//   pushq %r15

//   # loop through array, copying values from a to b
//   movq %rdi, %r12
//   movq %rsi, %r13
//   movq %rdx, %r15
// copy_loop:
//   cmpq $0, %r15
//   je copy_done
//   movsd (%r12), %xmm0
//   movsd %xmm0, (%r13)
//   addq $8, %r12
//   addq $8, %r13
//   decq %r15
//   jmp copy_loop
// copy_done:

//   # restore registers and return
//   popq %r15
//   popq %r14
//   popq %r13
//   popq %r12
//   movq %rbp, %rsp
//   popq %rbp
//   ret
