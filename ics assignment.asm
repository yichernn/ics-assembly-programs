section .data
    prompt_shape db '          Shape Drawing Implementation', 10, "------------------------------------------------", 10, '1. Line', 10, '2. Rectangle', 10, '3. Circle', 10, '4. Triangle', 10, '5. Square', 10, '6. Exit', 10, 0
    prompt_choice db 'Enter your choice (1-6): ', 0
    invalid_choice_msg db 'Invalid choice. Please enter a number between 1 and 6.', 10, 0
    prompt_line_length db "Enter the length of the line (1-9): ", 0
    prompt_rec_length db "Enter the length of rectangle (1-9): ", 0
    prompt_rec_width db "Enter the width of rectangle (1-9): ", 0
    prompt_square db "Enter the length of square (1-9): ", 0
    prompt_circle db "Enter the radius of the circle (1-9): ", 0
    prompt_tri db "Enter the row of triangle (1-9): ", 0
    invalid_length_msg db "Invalid length. Please enter a number between 1 and 9.", 10, 0
    star db "* ", 0
    space db "  ", 0
    newline db 10, 0

section .bss
    buffer resb 3                  ; Buffer to store 2 digit (at most) input
    choice resb 1                  ; variable to store menu choice
    line_length resb 1             ; variable to store line length
    rec_length resb 1              ; variable to store rectangle length
    rec_width resb 1               ; variable to store rectangle width
    rec_ori_length resb 1          ; variable to store original length for resetting
    square_length resb 1           ; variable to store square side length
    square_ori_length resb 1       ; variable to store original square length for resetting
    square_width resb 1            ; variable to store square width
    radius resd 1                  ; variable to store circle radius
    x resd 1                       ; variable to store circle x coordinate
    y resd 1                       ; variable to store circle y coordinate
    tri_space resb 1               ; variable to store number of triangle space
    tri_star resb 1                ; variable to store number of triangle star
    tri_ori_space resb 1           ; variable to store original space number
    tri_ori_star resb 1            ; variable to store original star number

section .text
    global _start

_start:
    ; Print the shape menu
    mov eax, 4                      ; sys_write
    mov ebx, 1                      ; file descriptor: stdout
    mov ecx, prompt_shape           ; pointer to message
    mov edx, 149                    ; message length
    int 0x80                        ; call kernel

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_choice
    mov edx, 25
    int 0x80

    ; Read user input for the choice
    mov eax, 3                      ; sys_read
    mov ebx, 0                      ; file descriptor: stdin
    mov ecx, buffer                 ; buffer to store choice
    mov edx, 3                      ; read up to 2 bytes (1-2 digit input + blank)
    int 0x80                        ; call kernel

    ; Call convert_loop to process input in buffer
    call convert_loop               ; convert buffer to integer
    mov [choice], al                ; store the final integer choice in choice

    ; Validate choice and jump to the corresponding function
    cmp al, 1
    je draw_line                    ; choice 1: draw line
    cmp al, 2
    je draw_rectangle               ; choice 2: draw rectangle
    cmp al, 3
    je draw_circle                  ; choice 3: draw circle
    cmp al, 4
    je draw_triangle                ; choice 4: draw triangle
    cmp al, 5
    je draw_square                  ; choice 5: draw square
    cmp al, 6
    je exit
    ; If no match, go to invalid_choice
    jmp invalid_choice

invalid_choice:
    ; Print invalid choice message
    mov eax, 4                      ; sys_write
    mov ebx, 1                      ; file descriptor: stdout
    mov ecx, invalid_choice_msg     ; pointer to invalid choice message
    mov edx, 54                     ; message length
    int 0x80                        ; call kernel

    ; Print two new line
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    jmp _start

draw_line:
    ; Prompt for line length
    mov eax, 4                      ; syscall: sys_write
    mov ebx, 1                      ; file descriptor: stdout
    mov ecx, prompt_line_length     ; pointer to prompt line message
    mov edx, 35                     ; Length of the prompt message
    int 0x80

    ; Read line length input
    mov eax, 3                      ; syscall: sys_read
    mov ebx, 0                      ; file descriptor: stdin
    mov ecx, buffer                 ; buffer to store length input
    mov edx, 3                      ; Allow for 1-2 characters input + newline
    int 0x80                        ; call kernel

    ; Convert input to integer
    call convert_loop               ; convert buffer to integer in eax
    mov [line_length], al           ; store the final integer line length in line_length

    ; Validate line length (1-9)
    cmp al, 1
    jl invalid_length               ; if less than 1, invalid length
    cmp al, 9
    jg invalid_length               ; if greater than 9, invalid length

    ; Print the line
    jmp print_line_loop

print_line_loop:
    mov al, [line_length]           ; Get the line length
    cmp al, 0                       ; Check if we need to print more stars
    jle line_print_newline          ; If no more stars, jump to done

    ; Print a star
    mov eax, 4
    mov ebx, 1                      ; stdout
    mov ecx, star                   ; Pointer to star
    mov edx, 2                      ; Length of "* "
    int 0x80                        ; Call kernel

    sub byte [line_length], 1       ; Decrease star count
    jmp print_line_loop             ; Repeat

line_print_newline:
    ; Print new line
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    jmp line_done

line_done:
    jmp _start                      ; Go to exit

draw_rectangle:
    ; Prompt for length
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_rec_length      ; pointer to prompt rectangle length message
    mov edx, 36                     ; Length of the prompt message
    int 0x80

    ; Read length input
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 3                      ; Allow for 2 characters input
    int 0x80

    call convert_loop               ; convert buffer to integer in eax
    mov [rec_length], al            ; store the final integer line length in line_length
    mov [rec_ori_length], al        ; Save original length

    ; Validate line length (1-9)
    cmp al, 1
    jl invalid_length               ; if less than 1, invalid length
    cmp al, 9
    jg invalid_length               ; if greater than 9, invalid length

    ; Prompt for width
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_rec_width
    mov edx, 35                     ; Length of the prompt message
    int 0x80

    ; Read width input
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 3                      ; Allow for 2 characters input
    int 0x80

    call convert_loop               ; convert buffer to integer in eax
    mov [rec_width], al             ; store the final integer line length in line_length

    ; Validate line length (1-9)
    cmp al, 1
    jl invalid_length               ; if less than 1, invalid length
    cmp al, 9
    jg invalid_length               ; if greater than 9, invalid length

rectangle_loop_width:
    mov al, [rec_width]
    cmp al, 0
    jle rectangle_done              ; If width is zero, exit

rectangle_loop_length:
    mov al, [rec_length]
    cmp al, 0
    jle rectangle_newline           ; If length is zero, print newline

    ; Print a star
    mov eax, 4
    mov ebx, 1
    mov ecx, star
    mov edx, 2                      ; Length of "* "
    int 0x80

    ; Decrement length
    sub byte [rec_length], 1        ; Decrease star count
    jmp rectangle_loop_length       ; Repeat

rectangle_newline:
    ; Print a newline character
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Reset length to original value for the next line
    mov al, [rec_ori_length]
    mov [rec_length], al

    ; Decrement width
    sub byte [rec_width], 1         ; Decrease width count
    jmp rectangle_loop_width

rectangle_done:
    jmp _start

draw_circle:
    ; Print the circle prompt
    mov eax, 4                      ; sys_write
    mov ebx, 1                      ; file descriptor (stdout)
    mov ecx, prompt_circle          ; pointer to the prompt string
    mov edx, 37                     ; length of the prompt string
    int 0x80

    ; Read the radius from the user
    mov eax, 3                      ; sys_read
    mov ebx, 0                      ; file descriptor (stdin)
    mov ecx, buffer                 ; buffer to store radius
    mov edx, 3                      ; read up to 2 bytes
    int 0x80

    ; Convert input to integer
    call convert_loop               ; convert buffer to integer
    mov [radius], al                ; store the final integer radius in "radius"

    ; Validate line length (1-9)
    cmp al, 1
    jl invalid_length               ; if less than 1, invalid length
    cmp al, 9
    jg invalid_length               ; if greater than 9, invalid length

    ;set y = -radius
    mov ecx, [radius]               ; ecx = radius
    neg ecx                         ; ecx = -radius
    mov [y], ecx                    ; y = -radius

outer_loop:
    ; Check if y > radius
    mov eax, [y]
    cmp eax, [radius]
    jg end_outer_loop

    ; Inner loop for x = -radius to radius
    mov ecx, [radius]               ; ecx = radius
    neg ecx                         ; ecx = -radius
    mov [x], ecx                    ; x = -radius

inner_loop:
    ; Check if x > radius
    mov eax, [x]
    cmp eax, [radius]
    jg end_inner_loop

    ; Calculate x^2 + y^2
    mov eax, [x]                    ; eax = x
    imul eax, eax                   ; eax = x^2
    mov ebx, eax                    ; ebx = x^2
    mov eax, [y]                    ; eax = y
    imul eax, eax                   ; eax = y^2
    add eax, ebx                    ; eax = x^2 + y^2

    ; Compare with radius^2
    mov ebx, [radius]               ; ebx = radius
    imul ebx, ebx                   ; ebx = radius^2
    cmp eax, ebx
    jg print_space                  ; if x^2 + y^2 > radius^2, print space

    ; Print '* ' (inside the circle)
    mov eax, 4                      ; sys_write
    mov ebx, 1                      ; file descriptor (stdout)
    mov ecx, star                   ; pointer to the '*' character
    mov edx, 2                      ; length of the character
    int 0x80
    jmp next_x

print_space:
    ; Print ' ' (outside the circle)
    mov eax, 4                      ; sys_write
    mov ebx, 1                      ; file descriptor (stdout)
    mov ecx, space                  ; pointer to the space character
    mov edx, 2                      ; length of the character
    int 0x80

next_x:
    ; Increment x
    inc dword [x]
    jmp inner_loop                  ; continue inner loop

end_inner_loop:
    ; Print newline
    mov eax, 4                      ; sys_write
    mov ebx, 1                      ; file descriptor (stdout)
    mov ecx, newline                ; pointer to the newline character
    mov edx, 1                      ; length of the newline character
    int 0x80

    ; Increment y
    inc dword [y]
    jmp outer_loop                  ; continue outer loop

end_outer_loop:
    jmp _start                      ; go to exit

draw_triangle:
    ; Prompt for side length
    mov eax, 4                      ; sys_write
    mov ebx, 1                      ; file descriptor (stdout)
    mov ecx, prompt_tri             ; pointer to the triangle prmopt
    mov edx, 33                     ; length of the prompt message
    int 0x80

    ; Read side length input
    mov eax, 3                      ; sys_read
    mov ebx, 0                      ; file descriptor (stdin)
    mov ecx, buffer                 ; buffer to store radius
    mov edx, 3                      ; read up to 2 bytes
    int 0x80

    ; Convert input to integer
    call convert_loop               ; convert buffer to integer
    mov [tri_ori_space], al

    ; Validate line length (1-9)
    cmp al, 1
    jl invalid_length               ; if less than 1, invalid length
    cmp al, 9
    jg invalid_length               ; if greater than 9, invalid length

    ; Set initial value
    sub byte [tri_ori_space], 1     ; initial space = row - 1
    mov eax, 1                      ; initial star = 1
    mov [tri_ori_star], eax

triangle_load_space:
    ; Load space number to tri_space
    mov al, [tri_ori_space]
    mov [tri_space], al

triangle_print_space:
    mov al, [tri_space]
    cmp al, 0
    jle triangle_load_star          ; jump triangle_load_star after printing all space

    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 2
    int 0x80

    sub byte [tri_space], 1         ; Decrement tri_space
    jmp triangle_print_space        ; loop again

triangle_load_star:
    ; Load star number to tri_star
    mov al,[tri_ori_star]
    mov [tri_star], al

triangle_print_star:
    mov al, [tri_star]
    cmp al, 0
    jle triangle_print_newline      ; jump triangle_print_line after printing alll star

    mov eax, 4
    mov ebx, 1
    mov ecx, star
    mov edx, 2
    int 0x80

    sub byte [tri_star], 1          ; Decrement tri_star
    jmp triangle_print_star         ; loop again

triangle_print_newline:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx , 1
    int 0x80

    mov al, [tri_ori_space]
    cmp al, 0
    jle triangle_done               ; jump to triangle_done if all rows printed

    sub byte [tri_ori_space], 1     ; Decrement tri_ori_space
    add byte [tri_ori_star], 2      ; Add 2 for the tri_ori_star
    jmp triangle_load_space         ; loop form the begining

triangle_done:
    jmp _start                      ; go to exit

draw_square:
    ; Prompt for side length
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_square
    mov edx, 34                     ; Length of the updated prompt message
    int 0x80

    ; Read side length input
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 3
    int 0x80

    call convert_loop               ; convert buffer to integer in eax
    mov [square_length], al         ; store the final integer line length in line_length
    mov [square_ori_length], al     ; Save original length
    mov [square_width], al

    ; Validate line length (1-9)
    cmp al, 1
    jl invalid_length               ; if less than 1, invalid length
    cmp al, 9
    jg invalid_length               ; if greater than 9, invalid length

square_loop_rows:
    mov al, [square_width]
    cmp al, 0
    je square_done                  ; If width is zero, exit

square_loop_columns:
    mov al, [square_length]
    cmp al, 0
    je square_print_newline         ; If length is zero, print newline

    ; Print a star
    mov eax, 4
    mov ebx, 1
    mov ecx, star
    mov edx, 2                      ; Length of "* "
    int 0x80

    ; Decrement length
    sub byte [square_length], 1
    jmp square_loop_columns

square_print_newline:
    ; Print a newline character
    mov eax, 4
    mov ebx, 1
    mov ecx, newline                ; Use updated name for newline
    mov edx, 1
    int 0x80

    ; Reset length to original value for the next line
    mov al, [square_ori_length]
    mov [square_length], al

    ; Decrement the row count
    sub byte [square_width], 1      ; Decrement square_width
    jmp square_loop_rows

square_done:
    jmp _start

convert_loop:
    ; Convert ASCII characters in buffer to integer
    xor eax, eax                    ; clear eax (to accumulate result)
    xor ecx, ecx                    ; clear ecx (index counter for buffer)

convert_digit_loop:
    movzx edx, byte [buffer + ecx]  ; load the current character from buffer
    cmp edx, 0xA                    ; check if we reached a newline character (ASCII LF)
    je convert_done                 ; if newline, end conversion

    sub edx, '0'                    ; convert ASCII character to integer
    imul eax, eax, 10               ; multiply current result by 10
    add eax, edx                    ; add the new digit
    inc ecx                         ; move to the next character in buffer
    jmp convert_digit_loop          ; repeat for next digit

convert_done:
    ret                             ; return to the calling function with result in eax

invalid_length:
    ; Print invalid length message
    mov eax, 4                      ; syscall: sys_write
    mov ebx, 1                      ; file descriptor: stdout
    mov ecx, invalid_length_msg     ; pointer to invalid length message
    mov edx, 54                     ; message length
    int 0x80                        ; call kernel

    ; Print two new line
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    jmp _start

exit:
    ; Exit the program
    mov eax, 1                      ; syscall: sys_exit
    xor ebx, ebx                    ; status 0
    int 0x80                        ; make the syscall
