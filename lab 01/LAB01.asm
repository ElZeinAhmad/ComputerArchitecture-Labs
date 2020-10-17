DIM1 EQU 20
DIM2 EQU 50
CR   EQU 13;Carriage return which is equal to 13
LF   EQU 10;Line Feed which is equal to 10
           ;In windows both must be used to note an end of line.
k1   EQU 1           
k2   EQU 2
k3   EQU 3
k4   EQU 4
.MODEL small
.STACK
 
.DATA

MSGSTART  DB "                    <<< PROGRAM WILL START NOW >>>                   ",CR,LF,"$" ;text string is a byte array and $ to terminate the string.  
MSGFINISH DB "<<< PROGRAM IS TERMINATED >>>",CR,LF,"$"
MSG1      DB "PLEASE INSERT YOUR FIRST  20 TO 50 CHARACTERS STRING:",CR,LF,"$"
MSG2      DB "PLEASE INSERT YOUR SECOND 20 TO 50 CHARACTERS STRING:",CR,LF,"$"
MSG3      DB "PLEASE INSERT YOUR THIRD  20 TO 50 CHARACTERS STRING:",CR,LF,"$"
MSG4      DB "PLEASE INSERT YOUR FOURTH 20 TO 50 CHARACTER STRING:",CR,LF,"$"
MSG5      DB      "CHARACTER WITH MAX NUMBER OF OCCURENCY :", "$"
MSG6      DB      "CHARACTERS WITH OCCURENCY MAX/2 :", "$"
MSGCC1   DB      "CAESER CIPHER WITH  k=1: ", CR, LF, "$"
MSGCC2   DB      "CAESER CIPHER WITH  k=2: ", CR, LF, "$"
MSGCC3   DB      "CAESER CIPHER WITH  k=3: ", CR, LF, "$"
MSGCC4   DB      "CAESER CIPHER WITH  k=4: ", CR, LF, "$"
first_line  DB 50 DUP(?)
second_line DB 50 DUP(?)
third_line  DB 50 DUP(?)
fourth_line DB 50 DUP(?) 
words_upper DB 26 DUP(0)
words_lower DB 26 DUP(0) 

.CODE

arrays_clean proc
         PUSH CX
         PUSH DI
         MOV CX,26              ;number of all array elements
         MOV DI,0               ;initializing index
clean_upper:
         MOV words_upper[DI],0  ;initializing all array values to zero
         INC DI                 ;incrementing index
         DEC CX                 ;decrementing counter
         CMP CX,0
         JNE clean_upper 
         
clean_lower:                  
        MOV words_lower[DI-1],0 ;initializing all array values to zero starting from DI-1=26-1
         INC CX                 ;incrementing CX to reach 26 counter
         DEC DI                 ;decrementing index
         CMP DI,0
         JNE clean_lower         
         POP DI
         POP CX
         ret       
arrays_clean endp





printstring proc
PUSH AX
MOV AH,09H;output string DS:DX while string must be terminated by $.
INT 21H
POP AX
ret    
printstring endp

printendline proc
PUSH AX
PUSH DX
MOV AH,2                ;writing
MOV DL,13               ;Carriage return \r
INT 21H                 ;interrupt
MOV DL,10               ;Line Feed \n
INT 21H                 ;interrupt
POP DX
POP AX 
ret
printendline endp

storeline proc
PUSH DI
MOV CX,DIM1             ;store in CX 20
MOV BX,DIM2             ;store in CX 50
MOV AH,1                ; reading

storetilltwenty:
INT 21H                 ;interrupt
MOV [DI],AL             ;save character
INC DI                  ;increment index
DEC CX                  ;decrement CX
DEC BX                  ;decrement BX
CMP CX,0                ;check if it is the 20th character
JNE storetilltwenty     ;if CX is not zero go to "storetilltwenty"
MOV CL,13               ;store in CL the ascii code of ENTER
CMP [DI-1],CL           ;check if the twentieth character is ENTER
JE  storefinish         ;if the character is ENTER go to "storefinish"

storeabovetwenty:
INT 21H                 ;interrupt
MOV [DI],AL             ;save character
INC DI                  ;increment index
DEC BX                  ;decrement BX
CMP [DI-1],CL           ;check if the character is ENTER
JE  storefinish         ;if the character is ENTER go to "storefinish"
CMP BX,0                ;check if it is the 50th character
JNE storeabovetwenty    ; if BX is not zero go to "storeabovetwenty"

storefinish:
          CALL printendline ;call printendline function 
          POP DI
          ret    
storeline endp

count_char proc
     
     PUSH DI
     MOV BH,0
     MOV CX,DIM2          ;giving CX value 50 then will be subtracted from the value remained in BX above.
     SUB CX,BX            ;finding number of characters entered 50-(value of above BX=50-characters entered).
     PUSH CX              ;saving in stack the number of characters
    
     
read:MOV BL,[DI]
     CMP BL,65            ;check if the ASCII code is lower than 65
     JL finish_count      ;if it is lower go to "finish_count"
     CMP BL,122           ;check if the ASCII code is greater than 122
     JG finish_count      ;if it is greater go to "finish_count"
     CMP BL,90            ;check if the ASCII code is lower than 90
     JLE upper_char_count ;if it is lower/equal go to "upper_char_count" because it is an uppercase
     CMP BL,97            ;check if the ASCII code is greater than 97
     JGE lower_char_count ;if it is greater/equal go to "lower_char_count" because it is a lowercase
     JMP finish_count     ;if the character in between 90 and 97 (not a letter)

upper_char_count:
     SUB BL,65            ;convert the ASCII code of the uppercase to the position within the words_upper array
     INC words_upper[BX]  ;increment the position value by 1
     JMP finish_count     ;jump to "finish_count" 
          
lower_char_count:
     SUB BL,97            ;convert the ASCII code of the lowercase to the position within the words_lower array
     INC words_lower[BX]  ;increment the position value by 1
     
finish_count: 
      INC DI              ;increment index
      DEC CX              ;decrement counter CX
      CMP CX,0            ;check if it is the last character
      JNE read            ;if CX is not zero jump to "read" 
      POP CX
      POP DI
      ret
count_char endp 

max_count_char proc
       PUSH CX
       PUSH DI
       MOV  DL,0;           ;used as the start max which is equal to zero
       MOV  BH,0;           ;initializing the upper byte of BX to zero to use it later as index for arrays.
reading:
         CMP [DI],65        ;check if the ASCII code is lower than 65
         JL finish_max      ;if it is lower go to "finish_count"
         CMP [DI],122       ;check if the ASCII code is greater than 122
         JG finish_max      ;if it is greater go to "finish_count"
         CMP [DI],90        ;check if the ASCII code is lower than 90
         JLE upper_char_max ;if it is lower/equal go to "upper_char_count" because it is an uppercase
         CMP [DI],97        ;check if the ASCII code is greater than 97
         JGE lower_char_max ;if it is greater/equal go to "lower_char_count" because it is a lowercase   
          JMP finish_max     ;if the character in between 90 and 97 (not a letter)
upper_char_max:
         
         MOV BL,[DI]              ;load character
         SUB BL,65                ;convert the ASCII code of the uppercase to the position within the words_upper array
         CMP DL,words_upper[BX]   ;compare max with the character occurency saved in the index.
         JL  update_max_upper     ;if it is lower jump to "update_max_upper" to update the char/max values
         JMP finish_max           ;else jump to "finish_max"  no update for char/max values
         
lower_char_max:         
         
         MOV BL,[DI]              ;load character
         SUB BL,97                ;convert the ASCII code of the lowercase to the position within the words_lower array
         CMP DL,words_lower[BX]   ;compare max with the character occurency saved in the index.
         JL  update_max_lower     ;if it is lower jump to "update_max_lower" to update the char/max values
         JMP finish_max           ;else jump to "finish_max" no update for char/max values
         
update_max_upper:
           MOV DH,[DI]            ;load the character into DH
           MOV DL,words_upper[BX] ;load the character occurency into DL
           JMP finish_max         ;jump to "finish_max"  
update_max_lower:
           MOV DH,[DI]            ;load the character into DH
           MOV DL,words_lower[BX] ;load the character occurency into DL
                       
finish_max:
          INC DI                  ;increment index
          DEC CX                  ;decrement counter
          CMP CX,0                ;check if it is the last character
          JNE reading             ;if it is not jump to reading
          POP DI
          POP CX
          ret           
max_count_char endp 

print_max_character proc
     
     PUSH DX
     ;no push and pop for AX since i use the values given here in the next function. 
     CMP DL,0
     JE  max_zero_char ;if max saved in DL is equal zero then no character printing
     MOV AH,2
     MOV BL,DL;putting the occurances in BL
     MOV DL,20H
     INT 21H
     MOV DL,DH;putting the character with max occurence in DL to print it out
     INT 21H
     MOV DL,3DH;"=" printing
     INT 21H
     MOV AL,BL;giving AL again the value of occurances then it enter in printing function.
     POP DX
     ret
max_zero_char:    
        MOV AL,DL ;putting the zero occurence in AL then in next function (print_num it will not print max)
        POP DX
        ret  
print_max_character endp

print_num proc near
          
        PUSH AX
		PUSH BX
		PUSH DX
        CMP AL,0
        JE  max_zero        ;if max is equal zero no printing for occurency
        CMP AL, 10			; check if the number to print is less than 10
		JB  one_digit		; if AL is less than 10 go to "digit"
		XOR AH, AH			; reset the register to zero
		MOV BL, 10			; preparing the divisor (10) 
		DIV BL				; AL=AX/divisor (AH=rest)
		CALL print_num		; recursive iteration
		MOV AL, AH			; move the rest

one_digit:
        PUSH AX
		MOV AH, 2			; writing
		MOV DL, AL			; move digit to DL
		ADD DL, 30H			; convert to ASCII
		INT 21H
		POP AX

		POP DX
		POP BX
		POP AX
		ret
max_zero:                   ;just pop and return
        POP DX
		POP BX
		POP AX
		ret
        		 
print_num endp

print_maxdiv2_num_lower proc
        PUSH SI
        PUSH DX
        PUSH CX
        MOV  CX,26 ;max number of the arrays index
        SHR  DL,1  ;divide the max by two (max saved in DL...PUSH AND POP of DX).
        CMP  DL,1  ;if max is 0<max<1 then all elements have max/2 then jump and dont print them
        JB   max_zero_lower      
        
check_lower:  
        CMP words_lower[SI],DL
        JE  write_maxdivtwo_lower
        JMP maxdivtwo_finish_lower
        
write_maxdivtwo_lower:
        PUSH AX
        MOV DH,0
        MOV AX,SI
        MOV DH,AL   ;i did this value move since i faced a problem in MOV DH,[SI] which is not moving the value of SI
        ADD DH,97   ;convert the lowercase of the position within the words_lower array into ASCII code
        call print_max_character;print the max/2 occurance character
        call print_num          ;print the occurence of these characters.
        POP AX
maxdivtwo_finish_lower:
        INC SI                 ;increment index
        DEC CX                 ;decrement counter
        CMP CX,0               ;check if it is the last character
        JNE check_lower        ;if it is not jump to "check"
        MOV DL,20H
        INT 21H				   ;interrupt
        POP CX
        POP DX
        POP SI
        ret
max_zero_lower:                 ;just pop and ret
        POP CX
        POP DX
        POP SI
        ret

print_maxdiv2_num_lower endp

print_maxdiv2_num_upper proc
        PUSH SI
        PUSH DX
        PUSH CX
        MOV  CX,26 ;max number of the arrays index
        SHR  DL,1  ;divide the max by two (max saved in DL...PUSH AND POP of DX).
        CMP  DL,1  ;if max is 0<max<1 then all elements have max/2 then jump and dont print them
        JB   max_zero_upper;      
        
check_upper:  
        CMP words_upper[SI],DL
        JE  write_maxdivtwo_upper
        JMP maxdivtwo_finish_upper
        
write_maxdivtwo_upper:
        PUSH AX
        MOV DH,0
        MOV AX,SI
        MOV DH,AL   ;i did this value move since i faced a problem in MOV DH,[SI] which is not moving the value of SI
        ADD DH,65   ;convert the lowercase of the position within the words_lower array into ASCII code
        call print_max_character;print the max/2 occurance character
        call print_num          ;print the occurence of these characters.
        POP AX
maxdivtwo_finish_upper:
        INC SI                 ;increment index
        DEC CX                 ;decrement counter
        CMP CX,0               ;check if it is the last character
        JNE check_upper        ;if it is not jump to "check"
        POP CX
        POP DX
        POP SI
        ret
max_zero_upper:                ;just pop and ret
        POP CX
        POP DX
        POP SI
        ret

print_maxdiv2_num_upper endp

caesar_cipher proc
         PUSH DI
         PUSH CX
         PUSH DX
         PUSH AX
         PUSH BX
reading_only_char:
        
         CMP [DI],65           ;check if the ASCII code is lower than 65
         JL non_alpha          ;if it is lower go to "finish_count"
         CMP [DI],122          ;check if the ASCII code is greater than 122
         JG non_alpha          ;if it is greater go to "finish_count"
         CMP [DI],90           ;check if the ASCII code is lower than 90
         JLE upper_char_caesar ;if it is lower/equal go to "upper_char_count" because it is an uppercase
         CMP [DI],97           ;check if the ASCII code is greater than 97
         JGE lower_char_caesar ;if it is greater/equal go to "lower_char_count" because it is a lowercase   
         JMP non_alpha
upper_char_caesar:
          MOV AX,[DI]          ;moving the content of [DI] into AX
          MOV DL,AL            ;moving the lowest byte of [DI]=AL into DL
          ADD DL,BH            ;adding the K value in BH
          CMP DL,90            ;comparing if it is incremented outside the upper alphabetical ascii range
          JG  out_of_bound_upper;if yes manage it
          JMP print_caesar_character;if no print the character
out_of_bound_upper:
          ADD DL,6                  ;incrementing by 6 (number of characters between the upper/lower alphabeticals ascii)
          JMP print_caesar_character;print the character
non_alpha:
         MOV AX,[DI]           ;moving the content of [DI] into AX
         MOV DL,AL             ;moving the lowest byte of [DI]=AL into DL
         JMP print_caesar_character;printing non alphabetical characters                 
lower_char_caesar:
          MOV AX,[DI]               ;moving the content of [DI] into AX
          MOV DL,AL                 ;moving the lowest byte of [DI]=AL into DL
          ADD DL,BH                 ;adding the K value in BH
          CMP DL,122                ;comparing if it is incremented outside the lower alphabetical ascii range
          JG  out_of_bound_lower    ;if yes manage it
          JMP print_caesar_character;if no print the character
out_of_bound_lower:
          SUB DL,58                 ;decrementing by 58 (to return to the upper alphabeticals ascii)
                           
print_caesar_character: 
          
          MOV AH,2                ;writing
          INT 21H                 ;interrupt
finish_caesar:
          INC DI                  ;increment index
          DEC CX                  ;increment counter
          CMP CX,0                ;check if it is the last character
          JNE reading_only_char   ;if it is not jump to reading
          POP BX
          POP AX
          POP DX
          POP CX
          POP DI
          ret
caesar_cipher endp



.STARTUP


LEA DX,MSGSTART             ;load effective address of MSGSTART into DX
call printstring            ;print the message
call printendline           ;new line

LEA DX,MSG1                 ;load effective address of MSG1 into DX
call printstring            ;print the message       
LEA DI,first_line           ;load effective address of first_line into DI.
call storeline              ;store line characters
call printendline           ;new line
LEA DX,MSG5                 ;load effective address of MSG5 into DX
call printstring            ;print the message
call count_char             ;count characters occurrences
call max_count_char         ;calculate max character occurences and save them in the lower/upper arrays.
call print_max_character    ;print the max occurency character
call print_num              ;print the occurency of the character
call printendline           ;new line
PUSH DX                     ;push DX since we have in DH=character and DL=max occurency and i need them to max/2
LEA DX,MSG6                 ;load effective address of MSG6 into DX;since we need to print a DS:DX string by 09H
call printstring            ;print the message
POP DX                      ;pop to get again the values of DH/DL
call print_maxdiv2_num_lower;print the characters having occurency half of the max one lowercase
call print_maxdiv2_num_upper;print the characters having occurency half of the max one uppercase
call printendline           ;new line
call printendline           ;new line
MOV  BH,k1                  ;first line has a caesar cipher k=1                       
LEA DX,MSGCC1               ;load effective address of MSGCC1 into DX
call printstring            ;print the message
call caesar_cipher          ;call caeser_cipher
call printendline           ;new line
call printendline           ;new line
call arrays_clean

LEA DX,MSG2                 ;load effective address of MSG2 into DX
call printstring            ;print the message
LEA DI,second_line           ;load effective address of first_line into DI.
call storeline              ;store line characters
call printendline           ;new line
LEA DX,MSG5                 ;load effective address of MSG5 into DX
call printstring            ;print the message
call count_char             ;count characters occurrences
call max_count_char         ;calculate max character occurences and save them in the lower/upper arrays.
call print_max_character    ;print the max occurency character
call print_num              ;print the occurency of the character
call printendline           ;new line
PUSH DX                     ;push DX since we have in DH=character and DL=max occurency and i need them to max/2
LEA DX,MSG6                 ;load effective address of MSG6 into DX;since we need to print a DS:DX string by 09H
call printstring            ;print the message
POP DX                      ;pop to get again the values of DH/DL
call print_maxdiv2_num_lower;print the characters having occurency half of the max one lowercase
call print_maxdiv2_num_upper;print the characters having occurency half of the max one uppercase
call printendline           ;new line
call printendline           ;new line
MOV  BH,k2                  ;first line has a caesar cipher k=2                       
LEA DX,MSGCC2               ;load effective address of MSGCC1 into DX
call printstring            ;print the message
call caesar_cipher          ;call caeser_cipher    
call arrays_clean           ;initializing upper/lower arrays to zero
call printendline           ;new line
call printendline           ;new line


LEA DX,MSG3                 ;load effective address of MSG3 into DX
call printstring            ;print the message
LEA DI,second_line           ;load effective address of first_line into DI.
call storeline              ;store line characters
call printendline           ;new line
LEA DX,MSG5                 ;load effective address of MSG5 into DX
call printstring            ;print the message
call count_char             ;count characters occurrences
call max_count_char         ;calculate max character occurences and save them in the lower/upper arrays.
call print_max_character    ;print the max occurency character
call print_num              ;print the occurency of the character
call printendline           ;new line
PUSH DX                     ;push DX since we have in DH=character and DL=max occurency and i need them to max/2
LEA DX,MSG6                 ;load effective address of MSG6 into DX;since we need to print a DS:DX string by 09H
call printstring            ;print the message
POP DX                      ;pop to get again the values of DH/DL
call print_maxdiv2_num_lower;print the characters having occurency half of the max one lowercase
call print_maxdiv2_num_upper;print the characters having occurency half of the max one uppercase
call printendline           ;new line
call printendline           ;new line
MOV  BH,k3                  ;first line has a caesar cipher k=3                       
LEA DX,MSGCC3               ;load effective address of MSGCC1 into DX
call printstring            ;print the message
call caesar_cipher          ;call caeser_cipher
call arrays_clean           ;initializing upper/lower arrays to zero
call printendline           ;new line
call printendline           ;new line
 
 
LEA DX,MSG4                 ;load effective address of MSG4 into DX
call printstring            ;print the message
LEA DI,second_line           ;load effective address of first_line into DI.
call storeline              ;store line characters
call printendline           ;new line
LEA DX,MSG5                 ;load effective address of MSG5 into DX
call printstring            ;print the message
call count_char             ;count characters occurrences
call max_count_char         ;calculate max character occurences and save them in the lower/upper arrays.
call print_max_character    ;print the max occurency character
call print_num              ;print the occurency of the character
call printendline           ;new line
PUSH DX                     ;push DX since we have in DH=character and DL=max occurency and i need them to max/2
LEA DX,MSG6                 ;load effective address of MSG6 into DX;since we need to print a DS:DX string by 09H
call printstring            ;print the message
POP DX                      ;pop to get again the values of DH/DL
call print_maxdiv2_num_lower;print the characters having occurency half of the max one lowercase
call print_maxdiv2_num_upper;print the characters having occurency half of the max one uppercase
call printendline           ;new line
call printendline           ;new line
MOV  BH,k4                  ;first line has a caesar cipher k=4                       
LEA DX,MSGCC4               ;load effective address of MSGCC1 into DX
call printstring            ;print the message
call caesar_cipher          ;call caeser_cipher
call arrays_clean           ;initializing upper/lower arrays to zero
call printendline           ;new line
call printendline           ;new line
.EXIT
END