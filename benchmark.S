# Copy - Copy from one location to another
# Scale -  Retrieve frommemory, scale by constant annd store in memory  (This kernel multiplies a large block of memory by a scalar value.)
# Add - Add from two differnt memory locations and store result
# Triad - retrieves two numbers from memory, scales by a constant and stores back to different location.

#Flash = .text + .data

.bss # uninitialized data in RAM
    A:  .skip   8000000
    B:  .skip   8000000
    C:  .skip   8000000

.data # initialized data in FLASH > RAM
    N:              .quad   1000000
    time_start:     .quad   0
    time_end:       .quad   0
    sieze_Mb:       .quad   0

.text # code or constant data in FLASH, read only
    init:       .asciz  "Performing benchmark...\n"
    separator:  .asciz  "|------------------------------------------|\n"
    header:     .asciz  "|  name    |   kernel      |      Speed    |\n"
    copy:       .asciz  "|  copy    |   a(i) = b(i) |      %d MB/s  |\n"  

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


    movq    $0, %rax
    movq    $copy, %rdi
    call    printf

    jmp     end

copy_kernal:
    movq    (%rdx), %rsi
    dec     %rdi
    
    cmp     $0, %rdi    
    jne     copy_kernal

    ret


fill:  
    movq    %rdi, (%rcx)
    movq    %rdi, (%rdx)
    movq    %rdi, (%rsi)
    
    addq    $8, %rcx
    addq    $8, %rdx
    addq    $8, %rsi

    dec     %rdi
    cmp     $0, %rdi    
    jne     fill

    ret 

end:
    movq    $0, %rax
    call    exit
