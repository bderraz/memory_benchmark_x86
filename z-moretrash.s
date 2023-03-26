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
    N:              .quad   100000000
    time_start:     .quad   0
    time_end:       .quad   0
    sieze_Mb:       .quad   0

.text # code or constant data in FLASH, read only
    init:       .asciz  "Performing benchmark...\n"
    separator:  .asciz  "|------------------------------------------|\n"
    header:     .asciz  "|  name    |   kernel      |      Speed    |\n"
    formatString:       .asciz  "|  copy    |   a(i) = b(i) |      %d MB/s  |\n"  
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

    #; some code to measure the time interval
    rdtscp            # read timestamp counter into edx:eax
    shl $32, %rdx     # shift the upper 32 bits into the upper half of rdx
    or %rdx, %rax     # combine the upper and lower halves of the timestamp counter

    subq %r8, %rax     # calculate the difference in CPU cycles

    # get the clock rate of the CPU
    movq $0x16, %rax   # get the clock rate syscall number
    xorq %rdi, %rdi    # clear rdi to indicate the current CPU
    syscall            # call the clock rate syscall

    movq %rax, %r9     # save the clock rate in r9

    // # convert the difference in CPU cycles to seconds
    // cqo                # sign-extend rax to rdx:rax
    // idivq %r9          # divide rdx:rax by r9
    // movq %rax, %rbx    # save the result in rbx (or any other register)

    // # the result in rbx is the time interval in seconds


    movq    %r9, %rsi
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
