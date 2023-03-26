# Copy - Copy from one location to another
# Scale -  Retrieve frommemory, scale by constant annd store in memory  (This kernel multiplies a large block of memory by a scalar value.)
# Add - Add from two differnt memory locations and store result
# Triad - retrieves two numbers from memory, scales by a constant and stores back to different location.

#Flash = .text + .data


//  Average:
// |-----------------------------------------------------------------|
// |  copy    |   a(i) = b(i)             |      8064 cycles/Mb      |
// |-----------------------------------------------------------------|
// |  scale   |   a(i) = b(i) * q         |      10402 cycles/Mb     |
// |-----------------------------------------------------------------|
// |  add     |   a(i) = b(i) + c(i)      |      12502 cycles/Mb     |
// |-----------------------------------------------------------------|
// |  add     |   a(i) = b(i) + q* c(i)   |      14629 cycles/Mb     |
// |-----------------------------------------------------------------|


//  Best:
// |-----------------------------------------------------------------|
// |  copy    |   a(i) = b(i)             |      9344 cycles/Mb      |
// |-----------------------------------------------------------------|
// |  scale   |   a(i) = b(i) * q         |      12001 cycles/Mb     |
// |-----------------------------------------------------------------|
// |  add     |   a(i) = b(i) + c(i)      |      12840 cycles/Mb     |
// |-----------------------------------------------------------------|
// |  add     |   a(i) = b(i) + q* c(i)   |      14739 cycles/Mb     |
// |-----------------------------------------------------------------|


//  AVX Best:
// |-----------------------------------------------------------------|
// |  copy    |   a(i) = b(i)             |      6462 cycles/Mb      |
// |-----------------------------------------------------------------|
// |  scale   |   a(i) = b(i) * q         |      9007 cycles/Mb      |
// |-----------------------------------------------------------------|
// |  add     |   a(i) = b(i) + c(i)      |      11020 cycles/Mb     |
// |-----------------------------------------------------------------|
// |  add     |   a(i) = b(i) + q* c(i)   |      13216 cycles/Mb     |
// |-----------------------------------------------------------------|

.bss # uninitialized data in RAM
    A:  .skip   800000000
    B:  .skip   800000000
    C:  .skip   800000000

.data # initialized data in FLASH > RAM
    N:              .quad   1000000
    clocks_per_sec: .quad   1000000
    scale:          .quad   2

    time_start:     .quad   0
    time_end:       .quad   0

    time:           .quad   0
    sieze_Mb:       .quad   0

.text # code or constant data in FLASH, read only
    init:                       .asciz  "Performing benchmark...\n"
    separator:                  .asciz  "|-----------------------------------------------------------------|\n"
    header:                     .asciz  "|  name    |   kernel                  |      Speed            |\n"
    formatString_copy:          .asciz  "|  copy    |   a(i) = b(i)             |      %d cycles/Mb     |\n"  
    formatString_scale:         .asciz  "|  scale   |   a(i) = b(i) * q         |      %d cycles/Mb     |\n"
    formatString_add:           .asciz  "|  add     |   a(i) = b(i) + c(i)      |      %d cycles/Mb     |\n"  
    formatString_triad:         .asciz  "|  add     |   a(i) = b(i) + q* c(i)   |      %d cycles/Mb     |\n"  

.global main
main:
    pushq   %rbp                # store the caller's base pointer
    movq    %rsp, %rbp          # initialize the base pointer
    
    movq    $0, %rax
    movq    $init, %rdi
    call    printf

    movq    $0, %rax
    movq    $separator, %rdi
    call    printf

    ##############################################################
    leaq    C(%rip), %rcx       # laod first element of array C
    leaq    B(%rip), %rdx       # laod first element of array B
    leaq    A(%rip), %rsi       # laod first element of array A
    movq    N, %rdi             # array size
    call    fill                # fill the arrays with values

    call    clock
    movq    %rax, time_start

    leaq    B(%rip), %rdx       # laod first element of array B
    leaq    A(%rip), %rsi       # laod first element of array A
    movq    N, %rdi             # array size
    call    copy_kernal

    call    clock
    movq    %rax, time_end

    movq    time_start, %rsi
    movq    time_end, %rdi
    subq    %rsi, %rdi

    movq    %rsi, %rsi
    leaq    formatString_copy(%rip), %rdi
    call    printf  

    movq    $0, %rax
    movq    $separator, %rdi
    call    printf

    ##############################################################    

    leaq    C(%rip), %rcx       # laod first element of array C
    leaq    B(%rip), %rdx       # laod first element of array B
    leaq    A(%rip), %rsi       # laod first element of array A
    movq    N, %rdi             # array size
    call    fill                # fill the arrays with values

    call    clock
    movq    %rax, time_start

    leaq    B(%rip), %r14       # laod first element of array B
    leaq    A(%rip), %r15       # laod first element of array A
    movq    N, %rdi             # array size
    
    call    scale_kernal

    call    clock
    movq    %rax, time_end

    movq    time_start, %rsi
    movq    time_end, %rdi
    subq    %rsi, %rdi

    movq    %rsi, %rsi
    leaq    formatString_scale(%rip), %rdi
    call    printf  

    movq    $0, %rax
    movq    $separator, %rdi
    call    printf

    ##############################################################  

    leaq    C(%rip), %rcx       # laod first element of array C
    leaq    B(%rip), %rdx       # laod first element of array B
    leaq    A(%rip), %rsi       # laod first element of array A
    movq    N, %rdi             # array size
    call    fill                # fill the arrays with values

    call    clock
    movq    %rax, time_start

    leaq    C(%rip), %r13       # laod first element of array B
    leaq    B(%rip), %r14       # laod first element of array B
    leaq    A(%rip), %r15       # laod first element of array A
    movq    N, %rdi             # array size
    
    call    add_kernal

    call    clock
    movq    %rax, time_end

    movq    time_start, %rsi
    movq    time_end, %rdi
    subq    %rsi, %rdi

    movq    %rsi, %rsi
    leaq    formatString_add(%rip), %rdi
    call    printf  

    movq    $0, %rax
    movq    $separator, %rdi
    call    printf

    ##############################################################  

    leaq    C(%rip), %rcx       # laod first element of array C
    leaq    B(%rip), %rdx       # laod first element of array B
    leaq    A(%rip), %rsi       # laod first element of array A
    movq    N, %rdi             # array size
    call    fill                # fill the arrays with values

    call    clock
    movq    %rax, time_start

    leaq    C(%rip), %r13       # laod first element of array B
    leaq    B(%rip), %r14       # laod first element of array B
    leaq    A(%rip), %r15       # laod first element of array A
    movq    N, %rdi             # array size
    
    call    add_kernal

    call    clock
    movq    %rax, time_end

    movq    time_start, %rsi
    movq    time_end, %rdi
    subq    %rsi, %rdi

    movq    %rsi, %rsi
    leaq    formatString_triad(%rip), %rdi
    call    printf  

    movq    $0, %rax
    movq    $separator, %rdi
    call    printf

    jmp     end



triad_kernal:
    vmovq   (%r13), %xmm0     # Load a 64-bit value from memory into %xmm0
    movq    scale, %r12
    imul    %r12              # Multiply the scale factor with rax

    vmovq   (%r14), %xmm1     # Load a 64-bit value from memory into %xmm1
    vfmadd231sd %xmm0, %xmm1, %xmm1  # Multiply the value in %xmm0 by the scale factor and add it to the value in %xmm1

    vmovq   %xmm1, (%r15)     # Store the result to memory

    subq    $1, %rdi
    addq    $8, %r13
    addq    $8, %r14
    addq    $8, %r15 

    cmpq    $0, %rdi    
    jg      triad_kernal      # Jump back to the beginning of the loop if rdi > 0

    ret



add_kernal:
add_kernal:
    vmovq    (%r14), %xmm0     # Load a 64-bit value from memory into %xmm0
    vmovq    (%r13), %xmm1     # Load a 64-bit value from memory into %xmm1

    vpaddq   %xmm0, %xmm1, %xmm2  # Add the two 64-bit values in %xmm0 and %xmm1
    vmovq    %xmm2, (%r15)     # Store the result to memory
    
    subq     $1, %rdi
    addq     $8, %r13
    addq     $8, %r14
    addq     $8, %r15 
    
    cmpq     $0, %rdi    
    jg       add_kernal       # Jump back to the beginning of the loop if rdi > 0

    ret

scale_kernal:
    vmovsd      (%r14), %xmm0    # load a double-precision floating-point value into xmm0
    vbroadcastsd scale, %ymm1   # broadcast the scale factor to all elements of ymm1
    vmulsd      %xmm0, %xmm1, %xmm0 # scale the value in xmm0 by the value in xmm1
    vmovsd      %xmm0, (%r15)   # store the scaled value back to memory

    subq        $1, %rdi
    addq        $8, %r14
    addq        $8, %r15 
    
    cmpq        $0, %rdi    
    jg          scale_kernal

    ret

copy_kernal:
    vmovups     (%rdx), %ymm0 
    vmovups     %ymm0, (%rsi)

    subq        $8, %rdi
    addq        $32, %rdx
    addq        $32, %rsi 
    
    cmpq        $0, %rdi    
    jg          copy_kernal

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
