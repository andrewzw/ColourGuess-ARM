//R11 contains max guess
      MOV R0, #codebreakerAsk //Ask codebreaker name
      STR R0,.WriteString
      MOV R0, #codebreaker
      STR R0, .ReadString 
      MOV R0, #codemakerAsk //Ask codemaker name
      STR R0,.WriteString
      MOV R0, #codemaker
      STR R0, .ReadString
      MOV R0, #maxGuessesAsk //Ask max guess
      STR R0,.WriteString
      LDR R11, .InputNum //Input max guess
//Print codebreaker name
      MOV R0, #printCodebreaker //Move msg into R1
      STR R0,.WriteString //Write msg from R1
      MOV R0, #codebreaker //Move codebreaker  name into R1
      STR R0,.WriteString //Write codebreaker  name from R1
//Print codemaker name
      MOV R0, #printCodemaker //Move msg into R1
      STR R0,.WriteString //Write msg from R1
      MOV R0, #codemaker //Move codemaker  name into R1
      STR R0,.WriteString //Write codemaker  name from R1
//Print Max guesses
      MOV R0, #printMaxguess //Move msg into R1
      STR R0,.WriteString //Write msg from R1
      STR R11, .WriteUnsignedNum //Write max guess from max guess(R1)
//Ask Secret Code
      MOV R0, #lineBreak
      STR R0, .WriteString //line break
      MOV R0, #lineBreak
      STR R0, .WriteString //line break
      MOV R0, #codemaker
      STR R0, .WriteString
      MOV R0, #printEnterSecretcode
      STR R0, .WriteString
      MOV R0, #secretcode //use #secretcode as argument
      BL getcode        //Call getcode
      MOV R4, #.PixelScreen
loop:
      MOV R0, #codebreaker
      STR R0, .WriteString //Print codebreaker name
      MOV R0, #printGuessNumber 
      STR R0, .WriteString //Print guessNum
      STR R11, .WriteUnsignedNum //Write max guess from max guess(R1)
//Call getcode 
      MOV R0, #querycode //store entered query into #querycode
      BL getcode 
//Call draw
      MOV R0, #querycode
      BL draw 
      ADD R4, R4, #256  //Draw on next line
//Call comparecodes
      MOV R0, #0        //Case 1
      MOV R1, #0        //Case 2
      BL comparecodes
      MOV R3, #printPositionMatches
      STR R3, .WriteString
      STR R0, .WriteUnsignedNum
      MOV R3, #printColourMatches
      STR R3, .WriteString
      STR R1, .WriteUnsignedNum
      CMP R0, #4
      BEQ win
      CMP R11, #0
      BEQ lose
//END
      SUB R11, R11, #1  //subtract guesses after code entered successfully
      CMP R11, #0
      BNE loop
      MOV R3, #printEnded
      STR R3, .WriteString
lose:
      MOV R3, #codebreaker
      STR R3, .WriteString
      MOV R3, #printLose
      STR R3, .WriteString
      B over
win:
      MOV R3, #codebreaker
      STR R3, .WriteString
      MOV R3, #printWin
      STR R3, .WriteString
      B over
over: 
      MOV R0, #printGameEnd
      STR R0, .WriteString
      HALT
      .Align 128
//Messages labels
printEnded: .ASCIZ "Game ended\n"
lineBreak: .ASCIZ "\n"
secretcode: .BLOCK 128
querycode: .BLOCK 128
codemaker: .BLOCK 128
codebreaker: .BLOCK 128
codemakerAsk: .ASCIZ "Enter codemaker's name:\n"
codebreakerAsk: .ASCIZ "Enter codebreaker's name:\n"
maxGuessesAsk: .ASCIZ "Maximum number of guesses:\n"
printGuessNumber: .ASCIZ ", this is guess number: "
printCodebreaker:.ASCIZ "\nCodebreaker is "
printCodemaker:.ASCIZ "\nCodemaker is "
printMaxguess: .ASCIZ "\nMaximum number of guesses:"
printEntercode: .ASCIZ "\nEnter a code: "
printEnterSecretcode: .ASCIZ ", please enter a 4-character secret code"
printError: .ASCIZ "\nIncorrect format(4character, using [r, g, b, y, q, c])"
printSuccess: .ASCIZ "\nCode Entered!\n"
printPositionMatches: .ASCIZ "Position matches: "
printColourMatches: .ASCIZ ", Colour matches: "
printWin: .ASCIZ ", you WIN!\n"
printLose: .ASCIZ ", you LOST!\n"
printGameEnd: .ASCIZ "Game Over!\n"
//getcode FUNCTION
getcode:
      PUSH {R1,R2,R3,R4} //Store registers onto stack to reserve registers for function
      MOV R2, R0        //Pass in #code into parameter   
      MOV R4, #printEntercode
      STR R4,.WriteString //Write msg from R1
      STR R2, .ReadString
      STR R2, .WriteString //Print R2
      MOV R1, #0        //index 	
check:
      LDRB R3, [R2 + R1] //read byte from #code array
      ADD R1,R1,#1
      CMP R3, #0x72     //r
      BEQ check
      CMP R3, #0x67     //g
      BEQ check
      CMP R3, #0x62     //b
      BEQ check
      CMP R3, #0x79     //y
      BEQ check
      CMP R3, #0x70     //p
      BEQ check
      CMP R3, #0x63     //c
      BEQ check
      CMP R3, #0        //Check when string ends
      BEQ break
      B error
error:
      MOV R4, #printError
      STR R4, .WriteString
      POP {R1}          //restore max guess
      B getcode
break:
      CMP R1, #5
      BNE error
      MOV R4, #printSuccess
      STR R4, .WriteString
      POP {R1,R2,R3,R4}
      RET
//END getcode
//comparecodes FUNCTION
comparecodes:
      PUSH {R2,R3,R4,R5,R6,R7}
      MOV R2, #querycode 
      MOV R3, #secretcode 
      MOV R6, #0        //index check1
check1:
      MOV R7, #0        //index check2
      LDRB R4, [R2 + R6] //read byte from #querycode array
check2: 
      LDRB R5, [R3 + R7] //read byte from #secretcode array
      CMP R4,R5         //Compare colour
      PUSH {LR}
      MOV LR,PC
      BEQ checkIndex
      POP {LR}
      ADD R7, R7, #1    //increment index check2
      CMP R7, #4
      BNE check2
      ADD R6, R6, #1    //increment index check1
      CMP R6, #4
      BLT check1
      POP {R2,R3,R4,R5,R6,R7}
      RET
checkIndex:
      CMP R6,R7         //Compare index after colour
      BNE case2
      ADD R0, R0, #1    //case 1
      RET
case2:
      ADD R1, R1, #1
      RET
//END comparecodes
//draw FUNCTION
draw:
      PUSH {R1,R2,R3,R5,R7}
      MOV R2, R0 
//checkColor
      MOV R1, #0        //index 	
checkColor:
      LDRB R3, [R2 + R1] //read byte from #code array
      ADD R1,R1,#1
      CMP R3, #0x72     //r
      BEQ cRed
      CMP R3, #0x67     //g
      BEQ cGreen
      CMP R3, #0x62     //b
      BEQ cBlue
      CMP R3, #0x79     //y
      BEQ cYellow
      CMP R3, #0x70     //p
      BEQ cPurple
      CMP R3, #0x63     //c
      BEQ cCyan
//loop
      MOV R7, #0        //drawColor Counter
drawColor: STR R5,[R4+R7] //Store colour(R5) into PixelScreen(R4) at index R7(counter)
      ADD R7,R7,#4      //Increase counter
      CMP R7,#16        //stop when index at 16
      BLT checkColor
//loop
      POP {R1,R2,R3,R5,R7}
      RET
cRed: MOV R5, #.red
      B drawColor
cGreen: MOV R5, #.green
      B drawColor
cBlue: MOV R5, #.blue
      B drawColor
cYellow: MOV R5, #.yellow
      B drawColor
cPurple: MOV R5, #.purple
      B drawColor
cCyan: MOV R5, #.cyan
      B drawColor
//end checkColor
