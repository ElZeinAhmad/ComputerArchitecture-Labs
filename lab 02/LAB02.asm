N EQU 4
M EQU 7
P EQU 5
NP EQU N*P
MP EQU M*P
WNP EQU 2*NP      ;used for checking the reach of last DW element in result_matrix,*2 since we have DW(two bytes)
.MODEL SMALL
.STACK


.DATA

first_matrix  DB 3,14,-15,9,26,-53,5             ;matrix initialization
              DB 89,79,3,23,84,-6,26
              DB 43,-3,83,27,-9,50,28
              DB -88,41,97,-103,69,39,-9


 
second_matrix DB 37,-101,0,58,-20                ;matrix initialization
              DB 9,74,94,-4,59
              DB -23,90,-78,16,-4
              DB 0,-62,86,20,89
              DB 9,86,28,0,-34
              DB 82,5,34,-21,1
              DB 70,-67,9,82,14

              

MSG1 DB "RESULT MATRIX : ",13,10,"$"
                
result_matrix DW  NP DUP(?)  ;N*P is the total number of elements must be in the memory

   

.CODE


print_matrix proc
            ;no need to push since i dont want to use the values in registers anymore
            XOR BX,BX              ;initializing BX to zero used to iterate over the result_matrix
            LEA DX,MSG1            ;Loading Effective Address of first_matrix into DI
            MOV AH,09H             ;printing the string in DX
            INT 21H                ;interrupt
 print_start:
            
            MOV AX,result_matrix[BX] ;moving content of result_matrix with index BX to AX
            call print_num           ;calling print_num procedure
            MOV AH,2                 ;writing
            MOV DL,20H               ;space in ascii is 20H
            INT 21H                  ;interrupt
            INC BP                   ;incrementing BP used to make a new line after P position is reached
            CMP BP,P                 ;check BP is it reached last element in the row in result_matrix.
            JE  printendline         ;print a new line if yes print a new line
            JMP max_ele_check        ;if no continue reading the row elements.
printendline:
               
            MOV DL,13               ;Carriage return \r
            INT 21H                 ;interrupt
            MOV DL,10               ;Line Feed \n
            INT 21H                 ;interrupt
            XOR BP,BP               ;initializing BP to zero to start new 

max_ele_check:
            ADD BX,2                ;add 2 to get the next element in result_matrix "DW"
            CMP BX,WNP              ;check if the last element in memory is reached NP*2.
            JB  print_start         ;if no return to the print_start procedure
            ret
               
print_matrix endp
 
print_num proc near
        ;i will add a sign character for the negative numbers then i will treat them as binary.
        ;i used DIV and JB (binary) not IDIV and JL (signed).
        PUSH BX
	    TEST AX,AX                  ;TEST perfoms:if Ax is negative set Sign flag SF into 1 
		JS   neg_treat              ;if sign flag is 1 then treat Ax as negative
		JMP  pos_treat              ;else postive
neg_treat:
   	    ;NOT AX                     ;inverting AX to make its positive value (2's complement)
        ;INC AX                     ;adding +1 to finish the two's complement so we treat the number as positive adding later the - sign.
        NEG AX                     ;two's complement negate
        PUSH AX                     ;pushing not to lose the content of AX
        MOV AH,2                    ;moving a minus sign before writing the number
        MOV DL,0F0H                 ;DL="-"		    
		INT 21H                     ;interrupt
		POP AX                      ;poping the value of AX 
pos_treat:
        CMP AX, 10		            ;check if the number to print is less than 10
		JB  one_digit		        ;if AL is less than 10 go to "digit"
	    MOV BX, 10			        ;preparing the divisor (10) 
        XOR DX,DX                   ;initializing DX to zero to use it in the IDIV later.
		DIV BX                      ;AX=DX:AX/divisor (DX=rest) ---> 32bits/16bits = 16bits overflow is managed
		PUSH DX				        ;Pushing DX the residual to be used later in the recursion that will happen.
		CALL print_num		        ;recursive iteration
		POP DX                      ;poping the residual of DX tobe printed

   		MOV AX,DX
		
		

one_digit:
       
		MOV AH, 2			; writing
		MOV DL, AL			; move digit to DL
		ADD DL, 30H			; convert to ASCII
		INT 21H             ;interrupt
       	POP BX	
		ret   
print_num endp 
 
mul_matrix proc
             PUSH DI
             PUSH SI
                
             XOR AX,AX   ;initializing AX to zero
             XOR BP,BP   ;initializing BP to zero
             XOR BX,BX   ;initializing BX to zero
             XOR DX,DX   ;initializing DX to zero
 multiplication:
                
                
             MOV CX,AX   ;moving the value of every single mul of two elements into CX
             PUSH CX     ;pushing CX to use it later in the mul function without losing its sum value
             MOV AL,[SI] ;moving the contents of SI into AL 
             MOV CL,[DI] ;moving the contents of DI into CL
             IMUL CL     ;AX=AL*CL using IMUL (2's compliment)
             INC DI      ;increment the value of DI to get next content value
             INC BP      ;incremen BP to be the counter of the row max elements(M),elements are saved in memory(By ROW)
             ADD SI,P    ;increment SI by P  to get the next column element,elements are saved in memory(By ROW).
             POP CX      ;poping CX to get the last summed value ofthe IMULs done
             ADD AX,CX   ;Adding this value to the new IMUL value saved in AX
             JO  overflow;Checking the overflow flag if overflow take place jump then to the overflow control
             CMP BP,M    ;checking if all the row elements to be multiplied are finished.
             JB  multiplication;if BP is below the Max number of row element then do more multiplications.
                
move_value:     
             MOV result_matrix[BX],AX ;no more elements to be multiplied then put the result in the array result
             SUB DI,M   ;make the pointer of the matrix return to the first element of first_matrix
             SUB SI,MP   ;this Sub will return the pointer to the first element of second_matrix "already" multiplied column 
             XOR AX,AX  ;initializing AX to zero
             INC DH     ;to count the columns in second_matrix that are multiplied to check when we need to shift first_matrix row 
             INC SI     ;increment to start from next non multiplied column of second_matrix
             ADD BX,2   ;used to move to the second element that will be saved in the result_matrix (DW)
             XOR BP,BP  ;initializing BP to zero used to count the next row elements to be multiplied
                
             CMP DH,P   ;check if all colomns in the second_matrix are finished to be multiplied by a specific row.
             JE  rowshift ;if all colomns are finished then we shift to the next row in the first_matrix
               
             CMP BX,WNP   ;checking if the last element of the result_matrix is reached in memory *2 for (DW).
             JB  multiplication;if below return to multiplication
             JMP end           ;if equal/above then end this multiplication.(all multiplication result are in result_matrix.
                
rowshift:      ;at end of row mul SI position : (lastelement in second_matrix + P(line 74) + 1(line 87) 
               ;so (line 84 will return it into first element + P then Sub SI,P will return it to the first element of second_matrix.
               ADD DI,M        ;move to the next row in first_matrix
               SUB SI,P        ;---- explained above ----
               MOV DH,0        ;initializing DH to zero to start a new second_matrix colomn count.         
               CMP BX,WNP      ;checking if the last element of the result_matrix is reached in memory *2 for (DW).
               JB  multiplication;if below return to multiplication  
overflow:
               SHL AX,1          ;shifting left to analyse the MSB that will be saved in CF
               JC neg_over_flow  ;if CF is 1 then negative overflow occurs then number must be MAX positive.
               MOV AX,-32768     ;if CF is 0 then positive overflow occurs then number must be MIN negative number.
               CMP BP,M         ;checking if all the row elements to be multiplied are finished.
               JB  multiplication;if BP is below the Max number of row element then do more multiplications.
               JMP move_value    ;jumping to moving the new value after overflow check into the result_matrix
          
neg_over_flow:       
                MOV AX,32767     ;max positive value is moved.
                CMP BP,M         ;checking if all the row elements to be multiplied are finished.
                JB  multiplication;if BP is below the Max number of row element then do more multiplications.
                JMP move_value    ;jumping to moving the new value after overflow check into the result_matrix
end:            
               POP SI
               POP DI
               ret                   
mul_matrix endp
 


.STARTUP 

LEA DI,first_matrix      ;Loading Effective Address of first_matrix into DI
LEA SI,second_matrix     ;Loading Effective Address of second_matrix into SI
call mul_matrix          ;calling mul_matrix procedure
call print_matrix        ;calling print_matrix procedure

.EXIT
END