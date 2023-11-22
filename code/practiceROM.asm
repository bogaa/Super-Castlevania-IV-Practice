;;  ;;;;;;;;;;;;;;;;;;;;
;;  ;;PracticeROM;;;;
;;  ;;;;;;;;;;;;;;;;

!saveState = 0
		
	!SRAM_Pointer = $F2
	!Menu_Select = $F6
	!ManuState = $7FFFD0 	; enable menu 1, Running menu 2, closing menu 3
	
	!MenuCurserPos = $7FFFD8 
	!MenuPointer = $7FFFDA 
	
	!frameCounter = $7FFFB0
	!franeCounterComp = $7FFFB2
	!franeCounterCompSec = $7FFFB4 
	;$7FFFB6
	;$7FFFB8
	;$7FFFBA


	!costumMusicNumber = $1E16 		; also mono modifier in menu 
	!empty = $1e18
;	!blueSkinSwitchFlag = $1e1a
	!LoopFlag = $1e1c 
	!TimeStoperFlag = $1e1e
	!TimeStoperStop = $1e20 
	!TimerCompare = $1e22
;	!OutOfBouncDeath = $1e24
;	!setAutoRun = $1e26
;	!seeThroughWalls = $1e28
	!xposViwerFlag = $1e2a
	!RNGdisable = $1e2c
;	!seeThroughEnemy = $1e2e
	!placeHolder = $1e30
	!invincableFlag = $1e32
	!godMod	= $1e34

	;table "code/text_table_sc4.txt"	
	cleartable	;ASCII Table


    RAM_simonSlot_SpeedSubXpos = $000558 ;      |        |      ;  
	RAM_simonSlot_SpeedXpos = $00055A    ;      |        |      ;  
	RAM_simonSlot_SpeedSubYpos = $00055C ;      |        |      ;  
	RAM_simonSlot_SpeedYpos = $00055E    


org $86b593
	nop		; disable check where it compared against 13c2 to disable relad 
	nop


;-------------- Hijacks ------------------------------------------------------
org $80818e
		jml disableRNG

org $80A10A
		jml flightModRoutine

org $80A2C9		
		jml flightModControll

;org $80A323
;		jml flightModControll02
		
org $82bb13
		dw loopLevelCode	; bb1b general level increase code. Hijack for looping levels when finishing

org $828070 
		jsl loopAfterDeathToo
		nop

org $8081BF				; Beginnin of Interup?? Hijack
		JML.L hijackForDMAStuff
if !saveState == 1
org $8081bf
		jml.l saveStateMain
endif		

org $8081CA				; HijackFrameCounterReset	
		JML.L mainFrameCounter

org $8097A0				; mainHijackPracticMenu FixMe conflict with my code eventually..
		JML.L CheckStartSelectPress
	

org $80ffd8	
		db $03			; SRAM 2000 byte  ;007FD8

org $80ffd8				; Header Modefication
	if !saveState == 1 
		db $08			; largest supported.. 7??	128 kb $1ffff 
	endif 	
	
org $8283CB				
		JSL.L startUpSetup ;Hijack for all the WRAM menu stuff.. setting up at power on and reset
	
org $9FF1D0							;0FF1D0 mainHijack (9ff1ee savesstate)
	hijackForDMAStuff:						
		JSR.W MainPracticeMenuDMA          
		SEP #$20  					;ResetHijack and continue..                 
		LDX.W #$0000               
		JML.L $8081C4   	

; -------------- Code Savestate ------------------------------------------------------

if !saveState == 1
org $9ff1d0
   writeInteruAndScreenRegister: 
		LDA.W $1E80                        
        STA.W $2100                        
        LDA.W $1E82                        
        STA.W $4200                        
    end_SaveState: 
		PLP                                
        PLB                                
        jsr.w MainPracticeMenuDMA          
        SEP #$20                           
        LDX.W #$0000                       
        JML.L $8081C4                 
 
    saveStateMain:                         
		PHB                     	
        PHP                     	
        REP #$30               	
        LDA.B $20              	; Button Press Checks       	
		BIT.W #$2000 			; Select Press
        BEQ end_SaveState       	
        AND.B $28              	
        BEQ end_SaveState     	; to only run once??		

		LDA.B $20              	 	
		CMP.W #$2010			; use Select+R
        BEQ saveState_Start       		
		CMP.W #$2020 			; use Select+L
        BNE end_SaveState       	
        JMP.W loadState_Start     	
       
    saveState_Start:       
        PEA.W $0000                   
        PLB                             
        PLB                             
        SEP #$20                        
        LDY.W #$0000                   
        TYX                             
    backupData_ppu2sram: 
		LDA.W $4300,X                	   
        STA.L $770000,X                 
        INX                             
        INY                             
        CPY.W #$000B                    
        BNE backupData_ppu2sram                 
        CPX.W #$007B                    
        BEQ +                 
        INX                             
        INX                             
        INX                             
        INX                             
        INX                             
        LDY.W #$0000                    
        BRA backupData_ppu2sram                 

	+	REP #$30                        
        LDX.W #savePointerTable         
    getBankThenPointer: 
		PEA.W $9F00             		
        PLB                      	
        PLB                      	
        JMP.W loadDMA_pointerPPU2SRAM      	
		
	ppu_2_sramExitStackClear:
		PEA.W $0000                   
        PLB                            
        PLB                            
        REP #$30                       
        TSC                            
        STA.L $774004                          
        JMP.W writeInteruAndScreenRegister              
                                      
    loadState_Start:             
        PEA.W $0000                     	
        PLB                                 
        PLB                                 
        SEP #$20                            
        LDX.W #loadPointerTable                       
        JMP.W getBankThenPointer                 
	
	sRam_2_PPUexitStackClear:
		REP #$30                             
		LDA.L $774004                        
		TCS                                  
		PEA.W $0000                          
		PLB                                  
		PLB                                  
		LDA.B $20                            
		EOR.W #$2010                         
		ORA.W #$2020                         
		STA.B $20                            
		STA.B $28                            
		SEP #$20                             
		LDX.W #$0000                         
		TXY                                  
    
	restore_PPU_fromSRAM_loop: 
		LDA.L $770000,X                      
        STA.W $4300,X                        
        INX                                  
        INY                                  
        CPY.W #$000B                         
        BNE restore_PPU_fromSRAM_loop        
        CPX.W #$007B                         
        BEQ +                      
        INX                                  
        INX                                  
        INX                                  
        INX                                  
        INX                                  
        LDY.W #$0000                         
        JMP.W restore_PPU_fromSRAM_loop      
                                             
	+	REP #$30                             
        JMP.W writeInteruAndScreenRegister   
                                             
    loadDMA_pointerPPU2SRAM: 
		REP #$30                             
        LDA.W $0000,X                        
        BEQ ++                     			 
        TAY                                  
        INX                                  
        INX                                  
        BIT.W #$1000                         
        BEQ +                    			 
        AND.W #$EFFF                         
        TAY                                  
        SEP #$20                             

	+	LDA.W $0000,X                        
        INX                                  
        INX                                  
        CPY.W #$8000                         
        BCS +                      		
        STA.W $0000,Y                        
        BRA loadDMA_pointerPPU2SRAM          
                                             

	+	LDA.W $8000,Y                		 
        BRA loadDMA_pointerPPU2SRAM          
                                             
	++	JMP.W ($0002,X)                                     
	
	savePointerTable:
		dw $3100,$0080,$5200,$0000			
		dw $4310,$8080,$4312,$0000		
		
		dw $4314,$0071,$4316,$0080,$2181,$0000		
		dw $3183,$0000		
		
		dw $520B,$0002,$4312,$0000		
		dw $4314,$0072,$4316,$0080,$2181,$8000,$3183,$0000	
		
		dw $520B,$0002,$4312,$0000		
		dw $4314,$0073,$4316,$0080,$2181,$0000		
		
		dw $3183,$0001,$520B,$0002,$4312,$0000		
		dw $4314,$0074,$4316,$0080,$2181,$8000,$3183,$0001,$520B,$0002,$4310,$3981,$3115,$0000		
		
		dw $2116,$0000		
		dw $B139,$0000		
		
		dw $4312,$0000		
		dw $4314,$0075,$4316,$0080,$520B,$0002,$2116,$4000,$B139,$0000		
		
		dw $4312,$0000		
		dw $4314,$0076,$4316,$0080,$520B,$0002,$3121,$0000		
		
		dw $4310,$3B80,$4312,$2000,$4314,$0077,$4316,$0002,$520B,$0002,$0000		
		dw ppu_2_sramExitStackClear

	loadPointerTable:            
		dw $520C,$0000
		dw $3100,$0080,$5200,$0000
		
		dw $4310,$8000,$4312,$0000
		dw $4314,$0071,$4316,$0080,$2181,$0000
		
		dw $3183,$0000
		dw $520B,$0002,$4312,$0000
		
		dw $4314,$0072,$4316,$0080,$2181,$8000,$3183,$0000
		dw $520B,$0002,$4312,$0000
		
		dw $4314,$0073,$4316,$0080,$2181,$0000,$3183,$0001,$520B,$0002,$4312,$0000
		dw $4314,$0074,$4316,$0080,$2181,$8000,$3183,$0001,$520B,$0002,$4310,$1801,$3115,$0000
		
		dw $2116,$0000
		dw $4312,$0000
		
		dw $4314,$0075,$4316,$0080,$520B,$0002,$2116,$4000,$4312,$0000
		dw $4314,$0076,$4316,$0080,$520B,$0002,$3121,$0000
		
		dw $4310,$2200,$4312,$2000,$4314,$0077,$4316,$0002,$520B,$0002,$0000
		dw sRam_2_PPUexitStackClear	

endif	


; -------------------------------- Practice Menu Code ------------------------------------
if !saveState == 0		; offset to not overwrite needed code?
org $9ff400				;org $9ff460				 
endif


{; -------------------------------- Menu Logic ---------------------------------------------------
	MainPracticeMenuDMA: 
		PHD                            
        PHA                            
        PHP                            
        PEA.W $0000                    
        PLD                            
        REP #$30                       
        LDA.L !ManuState                  
        BEQ setPracticeMenuFlag         
       
		JSR.W MenueStatues      		; main will start, run or close menue         
		REP #$30                          
		JMP.W endMainPracticeMenuDMA     
           
	setPracticeMenuFlag: 
		LDA.B $20                     
        CMP.W #$3000                 	;check if start+select is pressed
        BNE endMainPracticeMenuDMA                       
        LDA.W #$0001              		;set initiate menu            
        STA.L !ManuState
	endMainPracticeMenuDMA: 
		
;		jsl doBlueSkinL					; extra jobs to execute go here
;		jsl doAutoWalkL
;		jsl seeThroughWallsL
;		jsl seeThroughEnemyL
;		jsl outofBounceCheckL
		jsl goodModRoutine						; broken here used for flight now 
		jsl invincableRoutine
		jsl timeStoperXposL	
		jsl xposViwer
		
		PLP                                   
        PLA                                   
        PLD                                   
        RTS                                   
             
	startUpSetup:		 
		PHA                                   
		PHP                                  
		REP #$30                             
		LDA.W #$0000              		; set noMenu               
		STA.L !ManuState                        
		STA.L $7FFFD2                        
		STA.L $7FFFD4                        
		STA.L $7FFFD6                        
		STA.L !MenuCurserPos                        
		STA.L !MenuPointer                        
		STA.L $7FFFE0                        
		JSL.L cleanWRAM                    
		PLP                                  
		PLA                                  
		JSL.L $82858F 					; what code??    Loading sequentz at the beginning of the game..               
		RTL                                  


	CheckStartSelectPress:            
		LDA.B $20,X             		; 9FF4B7|B520    |000020;  
        CMP.W #$3000                         
        BEQ endCheckStartSelectPress                      
        
		jsl musicSelector				; put jobs while play loop here
			
	endCheckStartSelectPress: 
		LDA.B $28,X                          	
        AND.W #$1000                         
		JML.L $8097A5           ; setPauseFlag if equal and continue.. 	
		rtl    					; endPause orginal JML.L $8097C2.  

	MenueStatues: 
		PHA                                  ;9FF4CB|48      |      ;  
        PHX                                 
        PHY                                 
        PHP                                 
        REP #$30                            
        LDA.L !ManuState                       
        CMP.W #$0001      			; goTo if set init                  
        BEQ startUpMenu                     
        CMP.W #$0002            	; goTo if set run               
        BEQ runMenu                     
        CMP.W #$0003             	; goTo if set close             
        BEQ closeMenu                     

	goToSetInitDMA: 
		LDA.L !ManuState             	; check if menu is set and DO DMA if yes           
        BEQ endInterupt                       
        JSR.W menuSram2PPU_DMA                     

	endInterupt: 
		PLP              
        PLY              
        PLX              
        PLA              
        REP #$20         
        PLA              
        JSL.L $808788     			; Controller ReadOut??
        PLP             
        PLA             
        PLD             
        REP #$30        
        PLA             
        PLB             
        PLD             
        PLY             
        PLX             
        PLA             
        RTI             
     
	startUpMenu: 
		JSR.W zeroPage2SRAMload     		; update 20 byte from RAM to SRAM
        JSR.W backupHUD      				; DMA HUD2 SRAM
        JSR.W initiateMenuForUse      
        JMP.W goToSetInitDMA   
                               
	runMenu: 
		JSR.W userInputChecks  
        JMP.W goToSetInitDMA   
                               
	closeMenu: 
		JSR.W closeMenuToDo      
        JMP.W goToSetInitDMA   

	initiateMenuForUse: 
		JSR.W clearMenuTableSRAM     
        LDA.W #mainMenuList                 ; Load List Pointer $1FF937
        STA.L !MenuPointer                  ; WRAM Location 
        LDA.W #$0000       
        STA.L !MenuCurserPos      
        STA.L $7FFFD2      
        STA.L $7FFFD6      
        STA.L $7FFFE0      
        JSR.W setMenuForUpdate  
        LDA.W #$0002    					   ; set RunMenuFlag   
        STA.L !ManuState      
        RTS                
    
	userInputChecks: 
		LDA.B $28                            
        CMP.W #$0100                         
        BEQ leftPressAction                  
        CMP.W #$0200                         
        BEQ rightPressAction                 
        CMP.W #$0400                         
        BEQ downPressAction                  
        CMP.W #$0800                         
        BEQ upPressAction                    
        CMP.W #$1000                         
        BEQ startPressAction                 
        CMP.W #$0080                         
        BEQ BPressAction                     
        CMP.W #$8000                         
        BEQ APressAction                     
        RTS                                  
    
	startPressAction: 
		JMP.W startPressActionDo       
	BPressAction: 	;leave
		JMP.W BPressActionDo       
	APressAction: 	;Do
		JMP.W APressActionDo       
                                
	downPressAction: 
		LDA.L $7FFFD2                        ;checkMenu end 
        CMP.L $7FFFD6                        
        BNE +                      
        JMP.W advanceCurserDo                    	
	+	INC A                                ;advance curser
        STA.L $7FFFD2                        
        JMP.W advanceCurserDo                    
    
	upPressAction: 
		LDA.L $7FFFD2          
        BNE +                 
        JMP.W advanceCurserDo  	
	+	DEC A                  
        STA.L $7FFFD2          
        JMP.W advanceCurserDo  
    
	rightPressAction: 
		LDA.L $7FFFD2          
        BNE +                
        JMP.W advanceCurserDo      
	+	DEC A                  
        DEC A                  
        DEC A                  
        DEC A                  
        CMP.W #$0000           
        BPL resetCurserPos     
        LDA.W #$0000           
	resetCurserPos: 
		STA.L $7FFFD2          
        STA.L !MenuCurserPos          
        JMP.W advanceCurserDo  
                               
	leftPressAction: 
		LDA.L $7FFFD2          
        CMP.L $7FFFD6          
        BNE +       
        JMP.W advanceCurserDo  
               
	+ 	INC A                  
        INC A                  
        INC A                  
        INC A                  
        CMP.L $7FFFD6          
        BMI +      
        LDA.L $7FFFD6          
        STA.L $7FFFD2          
        SEC                    
        SBC.W #$0003           
        STA.L !MenuCurserPos          
        JMP.W advanceCurserDo  
                               
	+	STA.L $7FFFD2          
        STA.L !MenuCurserPos          
        JMP.W advanceCurserDo  
                               
	startPressActionDo: 
		LDA.W #$0003    		; setExitMenu Code       
        STA.L !ManuState          
        RTS                    

	exitMenuCode: 
		PLB                        
        LDA.L $7FFFD4             
        BEQ startPressActionDo  
        LDA.W #$0000     		; set noMenu         
        STA.L $7FFFD4             
        RTS                        

	APressActionDo: 
		LDA.L $7FFFE0          
        BEQ startPressActionDo        
        TAX                    
        DEC A                  
        DEC A                  
        STA.L $7FFFE0          
        LDA.L $7FFFE0,X        
        STA.L !MenuPointer          
        JSR.W clearMenuTableSRAM     
        LDA.W #$0000           
        STA.L !MenuCurserPos          
        STA.L $7FFFD2          
        STA.L $7FFFD6          
        LDA.W #$0001           
        STA.L $7FFFD4          
        JMP.W menuCurserUpdate     ;setCurser to End or Beginning?? 
                               
	BPressActionDo: 
		PHB            			; will check for subMenu or leave
        PEA.W $9F00             	  
        PLB                        
        PLB                        
        LDA.L !MenuPointer              
        STA.B $F0                  
        LDY.W #$0000               
        STY.B !Menu_Select                  
        LDA.L $7FFFD2              
        ASL A                      
        ASL A                      
        ASL A                      
        TAY                        
        LDA.B ($F0),Y              
        TAX                        
        INY                        
        INY                        
        CPX.W #$0000               
        BEQ goNextIfZero            
        CPX.W #$007E               
        BEQ CODE_9FF671            
        CPX.W #$007F               
        BEQ CODE_9FF671                  
        JMP.W exitMenuCode          
                                   
	goNextIfZero: 
		TYA                                  ;9FF661|98      |      ;  
        CLC                                  ;9FF662|18      |      ;  
        ADC.B $F0                            ;9FF663|65F0    |0000F0;  
        TAX                                  ;9FF665|AA      |      ;  
        INY                                  ;9FF666|C8      |      ;  
        INY                                  ;9FF667|C8      |      ;  
        LDA.B ($F0),Y                        ;9FF668|B1F0    |0000F0;  
        TAY                                  ;9FF66A|A8      |      ;  
        JSR.W ($0000,X)                      ;9FF66B|FC0000  |9F0000;  
        JMP.W exitMenuCode                    ;9FF66E|4CB5F6  |9FF6B5;  
                                                  ;      |        |      ;  
	CODE_9FF671: 
		STX.B $B5                            ;9FF671|86B5    |0000B5;  
        LDA.B ($F0),Y                        ;9FF673|B1F0    |0000F0;  
        STA.B $B3                            ;9FF675|85B3    |0000B3;  
        INY                                  ;9FF677|C8      |      ;  
        INY                                  ;9FF678|C8      |      ;  
        LDA.B ($F0),Y                        ;9FF679|B1F0    |0000F0;  
        STA.B $B1                            ;9FF67B|85B1    |0000B1;  
        LDA.B [$B3]                          ;9FF67D|A7B3    |0000B3;  
        CMP.B $B1                            ;9FF67F|C5B1    |0000B1;  
        BNE CODE_9FF689                      ;9FF681|D006    |9FF689;  
        LDA.W #$0000                         ;9FF683|A90000  |      ;  
        JMP.W CODE_9FF68B                    ;9FF686|4C8BF6  |9FF68B;  
	CODE_9FF689: 
		LDA.B $B1                            ;9FF689|A5B1    |0000B1;  
	CODE_9FF68B: 
		STA.B [$B3]                          ;9FF68B|87B3    |0000B3;  
        JSR.W setMenuForUpdate                    ;9FF68D|20F4F7  |9FF7F4;  
        LDA.W #$0001                         ;9FF690|A90100  |      ;  
        STA.L $7FFFD4                        ;9FF693|8FD4FF7F|7FFFD4;  
        JMP.W exitMenuCode                    ;9FF697|4CB5F6  |9FF6B5;  

;	UNREACH_9FF69A:					;unused? Not in Diz Dissasembly potential bug??!!
;		STX $B5
;		LDA ($F0),Y
;		STA $B3
;		INY
;		INY
;		LDA [$B3]
;		EOR ($F0),Y
;		STA [$B3]
;		JSR $F7F4
;		LDA #$0001
;		STA $7FFFD4
;		JMP exitMenuCode				;$f6b5			;label_9FF6B5

	advanceCurserDo: 
		LDA.L !MenuCurserPos              
        CLC                        
        ADC.W #$0004               
        CMP.L $7FFFD2              
        BNE +      
        LDA.L !MenuCurserPos              
        INC A                      
        STA.L !MenuCurserPos              
        JMP.W menuCurserUpdate          
                                   
	+	LDA.L !MenuCurserPos              
        SEC                        
        SBC.W #$0001               
        CMP.L $7FFFD2              
        BNE menuCurserUpdate            
        LDA.L !MenuCurserPos              
        DEC A                      
        STA.L !MenuCurserPos              
	menuCurserUpdate: 
		JSR.W setMenuForUpdate     
        RTS                        
                                   
	zeroPage2SRAMload: 			
		REP #$30                 
        LDX.W #$0000             
	
	-	LDA.B $B0,X              
        STA.L $7000B0,X          
        LDA.B $F0,X              
        STA.L $7000F0,X          
        INX                      
        INX                      
        CPX.W #$0010             
        BNE -                    
        RTS                      
	
	SRAM2zeroPageLoad: 	
		REP #$30           	
        LDX.W #$0000       	
		
	--	LDA.L $7000B0,X   	
        STA.B $B0,X        	
        LDA.L $7000F0,X   	
        STA.B $F0,X        	
        INX                 	
        INX                 	
        CPX.W #$0010       	
        BNE --              	
        RTS                 	
	
	backupHUD: 					; backup Hud2SRAM $700900
		jsl backupHUDL							
        RTS                                 

	clearMenuTableSRAM: 
		LDA.W #$0000                     
		LDX.W #$0000                      
	-	STA.L $700608,X   		; SRAM Menu Table Pattern Starting Point
        INX                                
        INX                                
        CPX.W #$0100    	 	; bytes to clear                  
        BNE -                  
        RTS                                
                                           
	closeMenuToDo: 
		JSR.W clearMenuTableSRAM       	
        JSR.W HUDbackupSram2PPU_DMA        	
        JSR.W SRAM2zeroPageLoad        	
        LDA.W #$0000      	; set noMenu
        STA.L !ManuState             	
        STA.L $7FFB50             	
        STA.L $7FFB52             	
        RTS                        	

	menuSram2PPU_DMA: 			 
    	jsl menuSram2PPU_DMA_L
        RTS             	                    	

	HUDbackupSram2PPU_DMA: 
        jsl HudBackup2SramL         
        RTS                   

	setMenuForUpdate: 
		PHB                         	
        PEA.W $9F00                	;
        PLB                         	
        PLB                         	
        LDA.W #$7000               	
        STA.B $F3                  	
        LDA.W #$0608         		 	; SRAM Menu Table SetPosition
        STA.B !SRAM_Pointer            		 	; SRAM TablePointer
        LDA.L !MenuPointer           	 
        STA.B $F0                	 
        LDA.L !MenuCurserPos           	 
        STA.B $F8                	 
        LDA.W #$0000            	 
        STA.B !Menu_Select                	 
        LDA.W #$0000            	 
        LDX.W #$0002            	 
        LDY.W #$0000            	 
        LDA.B $F8                	 
        STA.B !Menu_Select                	 
        ASL A                    	
        ASL A                    	
        ASL A                    	
        TAY                      	
	setMenuEndTableCheck: 
		LDA.B ($F0),Y                       	
        CMP.W #$FFFF                        	; end of table check
        BNE setMenuOne                     	
        JMP.W GetDataBankRegister_9FF8F8 	 
   
	setMenuOne: 
		STA.B $B5                           
        INY                                  
        INY                                  
        LDA.B ($F0),Y                      
        STA.B $B3                           
        INY                                  
        INY                                  
        LDA.B !SRAM_Pointer                           
        CMP.W #$0708                        
        BEQ setMenuTwo                     
        JMP.W setMenuCurser                

	setMenuTwo: 
		LDA.L $7FFFD6                        ;Check for Menu Pos??
        BEQ setMenuThree                  
        PLB                                 
        RTS                                 
	setMenuThree: 
		INY                                 
        INY                                 
        INY                                 
        INY                                 
        INC.B !Menu_Select                          
        JMP.W setMenuEndTableCheck       
	
	setMenuCurser: 
		LDA.B !Menu_Select                          
        CMP.L $7FFFD2                      
        BEQ setSelectorHeart                   
        LDA.W #$0000  					; StoreEmpty to clear old selector                     
        STA.B [!SRAM_Pointer]                        
        JMP.W writeText2SRAM                 
	setSelectorHeart: 
		LDA.W #$2C27              		; Curser Heart tile
        STA.B [!SRAM_Pointer]                 	
	writeText2SRAM: 	
		INY                          	
        INY                          	
        LDA.B ($F0),Y               	
        STA.B $B1                   	
        PHY                          	
        LDY.W #$0000                	
        LDX.W #$0002                	
	 	
	-	LDA.W #$0000      				; writeLoop          	
        LDA.B ($B1),Y               	
        AND.W #$00FF            		; check if 00 to exit    	
        BNE writeEmpty            	
        
		JMP.W CODE_9FF893          	
	
	writeEmpty:
		PHY                          	
        ASL A                        	
        TAY                          	
        LDA.W emptyListEntery,Y    	
        TXY                          	
        STA.B [!SRAM_Pointer],Y               	
        PLY                          	
        INX                          	
        INX                          	
        INY                          	
        BRA -        	
	
	CODE_9FF893: 	
		INY                          	
        LDA.B $B5                   	
        CMP.W #$0000                	
        BEQ CODE_9FF8D6            	
        BIT.W #$1000                	
        BNE UNREACH_9FF8B3         	
        PLY                          	
        DEY                          	
        DEY                          	
        LDA.B ($F0),Y               	
        INY                          	
        INY                          	
        PHY                          	
        STA.B $B1                   	
        LDA.B [$B3]                 	
        CMP.B $B1                   	
        BNE CODE_9FF8D6            	
        JMP.W CODE_9FF8C3          	

	UNREACH_9FF8B3: 			;Not in diz.. probably rarly used..
		PLY
		DEY
		DEY
		LDA ($F0),Y
		INY
		INY
		PHY
		STA $B1
		LDA [$B3]
		BIT $B1
		BEQ CODE_9FF8D6
			
	CODE_9FF8C3: 
		PHY                              
        TXY                              
        LDA.W #$0000                    
        STA.B [!SRAM_Pointer],Y                   
        INY                              
        INY                              
        LDA.W #$2C22        	 ;X Letter Pattern for selected Upgrade         
		STA.B [!SRAM_Pointer],Y       	
        PLY                  	
        INX                  	
        INX                  	
        INX                  	
        INX                  	
	CODE_9FF8D6: 	
		PHY                  	
        TXY                  	
        LDA.W #$0000        	
	CODE_9FF8DB: 	
		STA.B [!SRAM_Pointer],Y       	
        INY                  	
        INY                  	
        CPY.W #$0040        	
        BNE CODE_9FF8DB     	
        PLY                  	
        LDA.B !SRAM_Pointer           	
        CLC                  	
        ADC.W #$0040        	
        STA.B !SRAM_Pointer           	
        LDX.W #$0002        	
        INC.B !Menu_Select           	
        PLY                  	
        INY                  	
        INY                  	
        JMP.W setMenuEndTableCheck    

	GetDataBankRegister_9FF8F8: 
		DEC.B !Menu_Select                           
        LDA.B !Menu_Select                              
        STA.L $7FFFD6                          
        PLB                                  ;Pull DataBank Register  
        RTS                                    
 
	mainMenuCode: 
        LDA.L $7FFFE0               	
        INC A                        	
        INC A                        	
        STA.L $7FFFE0               	
        TAX                          	
        LDA.L !MenuPointer               	
        STA.L $7FFFE0,X             	
        TYA                          	
        STA.L !MenuPointer               	
        JSR.W clearMenuTableSRAM         	
        LDA.W #$0000                	
        STA.L !MenuCurserPos               	
        STA.L $7FFFD2               	
        STA.L $7FFFD6               	
        LDA.W #$0001                	
        STA.L $7FFFD4               	
        JSR.W setMenuForUpdate     	
        RTS                          	
	
				
	doNothing:
;		stz $66		; exit with no music and a running game
		rts

	freeScrollRoutine:
		jsl freeScrollRoutineL
		rts 

;	healthRoutine:
;		jsl healthRoutineL
;		RTS 
	
	doRefill:
		jsl doRefillL
		RTS                    
   
	goToSelectedLevel:
		jsl goToSelectedLevelL
		RTS                                  		 
	
	goResetRoom:
		jsl goResetRoomL
		RTS
}		


; --------------------------------- menue data and routines -------------------------------------
	mainMenuList:			;1ff937
		dw $0000,mainMenuCode
		dw levelDisp,textStageSelect
		
		dw $0000,doRefill
		dw $0000,textRefill
		
		dw $0000,mainMenuCode
		dw subWeaponDisp,textSubweapons
	
		dw $0000,mainMenuCode
		dw multiShotDisp,textMulti	
	
		dw $0000,mainMenuCode
		dw extraMenu,textExtra	
		
		dw $0000,mainMenuCode
		dw whipLevelDisp,textWhip	

		dw $0000,mainMenuCode
		dw healthDisp,textHealth

;		dw $0000,freeScrollRoutine
;		dw $0000,texFreeScroll 
		
		dw $0000,doNothing
		dw $0000,textExit	
		
		dw $FFFF
	
 
	subWeaponDisp:			
		dw $007E,$008E,$0001,textDagger		;??,Address,Value,Text
		dw $007E,$008E,$0002,textAxe
		dw $007E,$008E,$0003,textHoly
		dw $007E,$008E,$0004,textBoomerang
		dw $007E,$008E,$0005,textWatch
		dw $007E,$008E,$0000,textNone
		dw $FFFF	
	
	extraMenu:
		dw $007E,!LoopFlag,$0001,textLoopRooom
		dw $007E,!TimeStoperFlag,$FECA,textBreakX
		dw $007E,!TimeStoperFlag,$0002,textBreakY
		dw $007E,!xposViwerFlag,$0001,textXposViwer
		dw $007E,$0088,$0008,textSecondQuest
		dw $007E,!RNGdisable,$0001,textRNG		
		dw $007E,!invincableFlag,$0001,textInvisableTimer	
		dw $007E,!godMod,$0001,textFligth						
		dw $FFFF
;		dw $007E,!blueSkinSwitchFlag,$0001,textBlue
;		dw $007E,$13f4,$7FFF,textHealth
;		dw $007E,!setAutoRun,$0001,textAutomove	
;		dw $007E,!OutOfBouncDeath,$0001,textOutofBounce	
	
;	cosmeticMenu:
;		dw $FFFF
		
;		dw $007E,$0080,$0001,textSkywalker		
;		dw $007E,!seeThroughWalls,$0008,textSeeThrouhWalls		
;		dw $007E,$00c2,$0050,textSubWButtonMap
;		dw $007E,$1F88,$0001,textSkywalker02
;		dw $007E,!seeThroughEnemy,$0004,textSeeThrouhEnemy
;		dw $007E,$0044,$0008,textSeeThrouhWalls

;	textGodMod:
;		db "GOD-MOD",$00	
	texFreeScroll:
		db "FREE SCROLL",$00
	textFligth:
		db "FLIGHT",$00	
	textRNG:
		db "RNG-DISABLE",$00	
	textInvisableTimer:		
		db "INVINCIBLE",$00
	textXposViwer:
		db "XPOS-VIWER",$00
	textBreakY:
		db "BREAK-TIME-YPOS",$00
	textBreakX:
		db "BREAK-TIME-XPOS",$00
	textLoopRooom:
		db "LOOP-ROOM",$00
	textDagger:
		db "DAGGER",$00				
	textAxe:
		db "AXE",$00
	textHoly:
		db "HOLY WATER",$00
	textBoomerang:
		db "BOOMERANG",$00
	textWatch:
		db "WATCH",$00
	textNone:
		db "NONE",$00
	textBlank:
		db " ",$00
	textMax:
		db "MAX",$00		

;	textCosmetic:
;		db "COSMETIC",$00	
;	textBlue:
;		db "BLUE-SKIN-SWITCH",$00	
	textExtra:	
		db "EXTRA",$00			
	textExit:	
		db "EXIT",$00	
	textSecondQuest:	
		db "SECOND-QUEST-SWITCH",$00
	textRefill:	
		db "REFILL",$00
	textHealth:	
		db "HEALTH",$00
	textSubweapons:
		db "SUBWEAPONS",$00			
	textMulti:
		db "MULTI",$00				
	textWhip:
		db "WHIP",$00				
	textStageSelect:	
		db "STAGE SELECT",$00		
 
;	textAutomove:
;		db "AUTO-MOVE",$00
;	textSubWButtonMap:
;		db "SUBW-BUTTON-MAP-X+R",$00
;	textSkywalker:	
;		db "SKYWALKER-ATTRIBUTE",$00
;	textSkywalker02:
;		db "SKYWALKER",$00
	
;	textHealth:
;		db "MAX-REMOVE-HEALTH",$00	
;	textSeeThrouhWalls:
;		db "SEE-THROUGH-WALLS",$00
;	textSeeThrouhEnemy:
;		db "SEE-DEAD-PEOPLE",$00	
;	textOutofBounce:
;		db "NO-OUT-O-B-DEATH",$00
	
	multiShotDisp:
		dw $007E,$0090,$0000,textNone	
		dw $007E,$0090,$0001,textLevel2
		dw $007E,$0090,$0002,textLevel3
		dw $007E,!placeHolder,$00ff,textBlank,$FFFF 		; extra enetry to prevent menu bug when pressing right
	whipLevelDisp:
		dw $007E,$0092,$0000,textLevel0
		dw $007E,$0092,$0001,textLevel1
		dw $007E,$0092,$0002,textLevel2
		dw $007E,!placeHolder,$00ff,textBlank,$FFFF
	healthDisp:
		dw $007E,!placeHolder,$0001,textHealth
		dw $007E,$13f4,$0010,textMax
		dw $007E,$13f4,$0009,text9
		dw $007E,$13f4,$0008,text8
		dw $007E,$13f4,$0007,text7
		dw $007E,$13f4,$0006,text6
		dw $007E,$13f4,$0005,text5
		dw $007E,$13f4,$0004,text4
		dw $007E,$13f4,$0003,text3
		dw $007E,$13f4,$0002,text2
		dw $007E,$13f4,$0001,text1		
		dw $007E,$13f4,$0000,textNone,$ffff 

	textLevel0:		
		db "LEVEL 0",$00		
	textLevel1:	
		db "LEVEL 1",$00		
	textLevel2:
		db "LEVEL 2",$00		
	textLevel3:
		db "LEVEL 3",$00		

	text1:
		db "1",$00
	text2:
		db "2",$00		
	text3:
		db "3",$00
	text4:
		db "4",$00
	text5:
		db "5",$00
	text6:
		db "6",$00
	text7:
		db "7",$00
	text8:
		db "8",$00
	text9:
		db "9",$00		
	
	
	levelDisp:	
		dw $0000,goResetRoom,$0000,textReset
		dw $0000,goToSelectedLevel,$0000,textStage1_1_1
		dw $0000,goToSelectedLevel,$0001,textStage1_1_2
		dw $0000,goToSelectedLevel,$0002,textStage1_2_1
		dw $0000,goToSelectedLevel,$0003,textStage1_2_2
;		dw $0000,goToSelectedLevel,$0004,textStage1_2_3
		dw $0000,goToSelectedLevel,$0005,textStage1_3_1
		dw $0000,goToSelectedLevel,$0006,textStage1_3_2
		dw $0000,goToSelectedLevel,$0007,textStage1_3_3
		dw $0000,goToSelectedLevel,$0008,textStage2_1_1
		dw $0000,goToSelectedLevel,$0009,textStage2_2_1
		dw $0000,goToSelectedLevel,$000A,textStage2_3_1
		dw $0000,goToSelectedLevel,$000B,textStage2_3_2
		dw $0000,goToSelectedLevel,$000C,textStage3_1_1
		dw $0000,goToSelectedLevel,$000D,textStage3_2_1
		dw $0000,goToSelectedLevel,$000E,textStage3_3_1
		dw $0000,goToSelectedLevel,$000F,textStage3_3_2
		dw $0000,goToSelectedLevel,$0010,textStage3_3_3
		dw $0000,goToSelectedLevel,$0011,textStage3_3_4
		dw $0000,goToSelectedLevel,$0012,textStage4_1_1
		dw $0000,goToSelectedLevel,$0013,textStage4_1_2
		dw $0000,goToSelectedLevel,$0014,textStage4_1_3
		dw $0000,goToSelectedLevel,$0015,textStage4_2_1
		dw $0000,goToSelectedLevel,$0016,textStage4_3_1
		dw $0000,goToSelectedLevel,$0017,textStage4_4_1
		dw $0000,goToSelectedLevel,$0018,textStage5_1_1
		dw $0000,goToSelectedLevel,$0019,textStage5_2_1
		dw $0000,goToSelectedLevel,$001A,textStage6_1_1
		dw $0000,goToSelectedLevel,$001B,textStage6_1_2
		dw $0000,goToSelectedLevel,$001C,textStage6_2_1
		dw $0000,goToSelectedLevel,$001D,textStage6_2_2
		dw $0000,goToSelectedLevel,$001F,textStage6_3_1
		dw $0000,goToSelectedLevel,$0021,textStage6_3_2
		dw $0000,goToSelectedLevel,$0022,textStage6_3_3
		dw $0000,goToSelectedLevel,$0023,textStage7_1_1
;		dw $0000,goToSelectedLevel,$0024,textStage7_1_2
		dw $0000,goToSelectedLevel,$0025,textStage7_1_3
		dw $0000,goToSelectedLevel,$0026,textStage7_2_1
		dw $0000,goToSelectedLevel,$0028,textStage7_2_2
		dw $0000,goToSelectedLevel,$002A,textStage8_1_1
		dw $0000,goToSelectedLevel,$002B,textStage8_1_2
		dw $0000,goToSelectedLevel,$002C,textStage8_2_1
		dw $0000,goToSelectedLevel,$002D,textStage8_2_2
		dw $0000,goToSelectedLevel,$002E,textStage9_1_1
		dw $0000,goToSelectedLevel,$002F,textStage9_1_2
		dw $0000,goToSelectedLevel,$0030,textStage9_1_3
		dw $0000,goToSelectedLevel,$0031,textStage9_2_1
		dw $0000,goToSelectedLevel,$0032,textStage9_2_2
		dw $0000,goToSelectedLevel,$0033,textStage9_2_3
		dw $0000,goToSelectedLevel,$0034,textStage9_2_4
		dw $0000,goToSelectedLevel,$0035,textStage9_2_4
;		dw $0000,goToSelectedLevel,$0036,textStage9_2_5
		dw $0000,goToSelectedLevel,$0037,textStageA_1_1
		dw $0000,goToSelectedLevel,$0038,textStageA_1_2
		dw $0000,goToSelectedLevel,$0039,textStageA_2_1
		dw $0000,goToSelectedLevel,$003A,textStageA_2_2
		dw $0000,goToSelectedLevel,$003B,textStageA_2_3
		dw $0000,goToSelectedLevel,$003C,textStageB_1_1
		dw $0000,goToSelectedLevel,$003E,textStageB_2_1
		dw $0000,goToSelectedLevel,$003F,textStageB_3_1
		dw $0000,goToSelectedLevel,$0040,textStageB_3_2
		dw $0000,goToSelectedLevel,$0041,textStageB_3_3
		dw $0000,goToSelectedLevel,$0042,textStageB_4_1
;		dw $0000,goToPlaySong,$0009,textCrisSpecial1 	;9
;		dw $0000,goToPlaySong,$000B,textCrisSpecial2	;b
		dw $FFFF
			
	textReset:		
		db "RESET-ROOM",$00
	textStage1_1_1:		
		db "1-1-1",$00	
	textStage1_1_2:		
		db "1-1-2",$00	
	textStage1_2_1:	
		db "1-2-1",$00	
	textStage1_2_2:	
		db "1-2-2-CLIP",$00	
;	textStage1_2_3:	
;		db "1-2-3",$00
	textStage1_3_1:	
		db "1-3-1",$00	
	textStage1_3_3:	
		db "1-3-3",$00
	textStage1_3_2:	
		db "1-3-2",$00	
	textStage2_1_1:	
		db "2-1-1-GRAVEYARD",$00           
	textStage2_2_1:	
		db "2-2-1",$00           
	textStage2_3_2:	
		db "2-3-2",$00 
	textStage2_3_1:	
		db "2-3-1",$00           
	textStage3_1_1:	
		db "3-1-1-CAVE",$00           
	textStage3_2_1:	
		db "3-2-1-WATERFALL",$00           
	textStage3_3_1:	
		db "3-3-1",$00           
	textStage3_3_2:	
		db "3-3-2",$00		
	textStage3_3_3:	
		db "3-3-3",$00           
	textStage3_3_4:	
		db "3-3-4-VIPER",$00 
	textStage4_1_1:	
		db "4-1-1",$00           
	textStage4_1_2:		
		db "4-1-2",$00 
	textStage4_1_3:		
		db "4-1-3-LIX-EW-UP",$00	
	textStage4_2_1:		
		db "4-2-1",$00           
	textStage4_3_1:	
		db "4-3-1",$00           
	textStage4_4_1:	
		db "4-4-1-ZIP-ZIP",$00           
	textStage5_1_1:	
		db "5-1-1",$00           
	textStage5_2_1:	
		db "5-2-1",$00           
	textStage6_1_1:	
		db "6-1-1",$00 
	textStage6_1_2:	
		db "6-1-2-CHANDELIER",$00
	textStage6_2_1:	
		db "6-2-1",$00   
	textStage6_2_2:	
		db "6-2-2",$00           
	textStage6_3_1:	
		db "6-3-1-SKELLY-HELL-WAY",$00           
	textStage6_3_2:	
		db "6-3-2",$00  
	textStage6_3_3:	
		db "6-3-2",$00		
	textStage7_1_1:	
		db "7-1-1",$00           
;	textStage7_1_2:	
;		db "7-1-2",$00  
	textStage7_1_3:	
		db "7-1-3-BOOKJUMP",$00   		
	textStage7_2_1:	
		db "7-2-1",$00           
	textStage7_2_2:	
		db "7-2-2",$00           
	textStage8_1_1:	
		db "8-1-1",$00
	textStage8_1_2:	
		db "8-1-2",$00  
	textStage8_2_1:	
		db "8-2-1",$00  
	textStage8_2_2:	
		db "8-2-2-VEGAS",$00 		
	textStage9_1_1:	
		db "9-1-1",$00   
	textStage9_1_2:	
		db "9-1-2",$00 	
	textStage9_1_3:	
		db "9-1-3",$00 		
	textStage9_2_1:	
		db "9-2-1-NO-MORE-GHOST",$00           
	textStage9_2_2:	
		db "9-2-2",$00           
	textStage9_2_3:	
		db "9-2-3-SPIKE-JUMP",$00
	textStage9_2_4:	
		db "9-2-4",$00
;	textStage9_2_5:	
;		db "9-2-5-CHILL",$00		
	textStageA_1_1:	
		db "A-1-1",$00           
	textStageA_1_2:	
		db "A-1-2",$00           
	textStageA_2_1:	
		db "A-2-1-ONE-SWING-CONVEYOR-PLS",$00     
	textStageA_2_2:	
		db "A-2-2-SUMMON-YOUR-INNER-JEDI",$00  ;-GO-SUB-30-SEC    
	textStageA_2_3:	
		db "A-2-3",$00  		
	textStageB_1_1:	
		db "B-1-1",$00           
	textStageB_2_1:	
		db "B-2-1",$00           
	textStageB_3_1:	
		db "B-3-1-DESTROYER-OF-DREAMS",$00           
	textStageB_3_2:	
		db "B-3-2-GEYBONE",$00           
	textStageB_3_3:		
		db "B-3-3-DEATH",$00           
	textStageB_4_1:	
		db "B-4-1-DRACULA",$00           
;	textCrisSpecial1:	
;		db "CRISMAS-SPECIAL",$00 
	
	
	emptyListEntery:	; used for letter and number symbpl lookup table		
		dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dw $0000,$0000,$0000
		dw $0CFF,$0CFD,$0CFE,$0CFE,$0C0A,$0CFE,$0CFE,$0CFC,$0CFE,$0CFE ;??
		dw $0CFE,$0CFB,$2026,$0CFA,$0CFE
		dw $2001,$2002,$2003,$2004,$2005 ;green numbers
		dw $2006,$2007,$2008,$2009,$200A
		dw $0CFE,$0CFE,$0CFE,$0CFE,$0CFE
		dw $0CFE,$0CFE,$200B,$200C,$200D,$200E,$200F,$2010,$2011,$2012
		dw $2013,$2014,$2015,$2016,$2017,$2018,$2019,$201A,$201B,$201C
		dw $201D,$201E,$201F,$2020,$2021,$2022,$2023,$2024,$2025,$2026,$2027,$2028,$2029
			
;		padbyte $ff		;cleanup
;		pad $9FFFFF
	
warnPC $9fffff

; ----------------------------------- Code Frame Counter  ---------------------------------	

org $9ef460		
	cleanWRAM:  		
		phx
		phy
	
		lda #$0000	;byte to be moved forward. Clear Trick
		sta $7FF300
		
	
		LDX #$f300   ; Set X to $f300
		LDY #$f302   ; Set Y to $f302
		LDA #$0cfd   ; Set A to $cfe bytes to be cleared
		MVN $7f,$7f  ; The values at $7f xxxx
    
		ply
		plx
		
		SEP #$20	;clearing the end of WRAM did change the dataBank so we recover what we had before
		LDA #$00
		PHA     
		PLB     
		REP #$30                        
		RTL                                    
    
	mainFrameCounter:         
		PHD                                  
		PHB                                  
		REP #$30                             
		PEA.W $9E00       ; Push Effective Absolute Address
		PLB                                  
		PLB                                  
		LDA.B $70                            
		CMP.W #$0006                         
		BNE resetCheckFrameCounter                      
		JSR.W resetFrameCounter                    
		BRA endFrameCounter              
	
	resetCheckFrameCounter: 
;		LDA.W #$0003    ; LevelInit and above to run                
;       CMP.B $70                       
;       BCC runFrameCounter                 
		cmp #$0005		; only run in game mode
        beq runFrameCounter
		
		BRA endFrameCounter         
	
	runFrameCounter: 
		JSR.W frameCoutnterCode          
		JSR.W frameCounterHudDisp               
	
	endFrameCounter: 
		PLB                             
        PLD                             
        LDA.W $4210                     
        REP #$20                        
        JML.L $8081CF                   
	
	resetFrameCounter: 
		LDA.L $7FFFBA      ; check ??             
        BEQ resetFrameCounterDo                 
        RTS                             
	
	resetFrameCounterDo: 
		LDA.L !franeCounterComp                   
        STA.L $7FFFB8                   
        LDA.L !frameCounter                   
        STA.L $7FFFB6                   
        LDA.W #$0000                    
        STA.L !frameCounter                   
        STA.L !franeCounterComp                   
        LDA.W #$0001                    
        STA.L !franeCounterCompSec                   
        STA.L $7FFFBA                   
        STZ.W $1FF0                     
        STZ.W $1FF2                     
        STZ.W $1FF4                     
        STZ.W $1FF6                     
        LDA.L $7FFFB8                   
        JSR.W CODE_9EF5A4               
        LDX.W #$000E                    
        JSR.W CODE_9EF610               
        LDA.L $7FFFB6                   
        STA.W $4204                     
        SEP #$20                        
        LDA.B #$0A                      
        STA.W $4206                     
        PHA                             
        PLA                             
        PHA                             
        PLA                             
        REP #$20                        
        LDA.W $4214                     
        ASL A                           
        STA.W $1FF0                     
        LDA.W $4216                     
        ASL A                           
        STA.W $1FF2                     
        LDX.W $1FF0                     
        LDA.L numberPatternLockUpTable,X
        STA.L $7FFF16                   
        LDX.W $1FF2                     
        LDA.L numberPatternLockUpTable,X
        STA.L $7FFF18                   
        
		lda #$0000			;clear xpos viwer after use
		sta $7fff1a
		sta $7fff1c
		sta $7fff1e
		
		SEP #$20                        
        REP #$10                        
        LDA.B #$80                      
        STA.W $2115                     
        LDX.W #$5800                    
        STX.W $2116                     
        LDA.B #$7F                      
        LDX.W #$FF00                    
        LDY.W #$0020                    
        STX.W $4302                     
        STA.W $4304                     
        STY.W $4305                     
        LDA.B #$18                      
        STA.W $4301                     
        LDA.B #$01                      
        STA.W $4300                     
        STA.W $420B                     
        RTS                             
	
	frameCoutnterCode: 
		lda !TimeStoperStop					   ; used to stop timer
		BEQ FrameCoutnterDo
		RTS
;		LDA.B $66                       
;      BEQ FrameCoutnterDo        ; dont run while pause
;      RTS                                    

	FrameCoutnterDo: 
		LDA.L !frameCounter                        
        INC A                                
        CMP.W #$003C       			; compare agains framecoutnter                   
        BNE +                      
        LDA.L !franeCounterComp                        
        INC A                                
        STA.L !franeCounterComp                        
        LDA.W #$0000     				; ??                    
        STA.L $7FFFBA                        	 
	
	+	STA.L !frameCounter                        
        RTS                                  
	
	frameCounterHudDisp: 
		STZ.W $1FF0                          
        STZ.W $1FF2                          
        STZ.W $1FF4                          
        STZ.W $1FF6                          
        LDA.L !franeCounterComp                        
        CMP.L !franeCounterCompSec                        
        BEQ drawFrameCount2Hud                      
        STA.L !franeCounterCompSec                        
        JSR.W CODE_9EF5A4                    
        LDX.W #$0000                         
        JSR.W CODE_9EF5FD                    
	drawFrameCount2Hud: 
		LDA.L !frameCounter                        
        STA.W $4204                          
        SEP #$20                             
        LDA.B #$0A                           
        STA.W $4206                          
        PHA                                  
        PLA                                  
        PHA                                  
        PLA                                  
        REP #$20                             
        LDA.W $4214                          
        ASL A                                
        STA.W $1FF0                          
        LDA.W $4216                          
        ASL A                                
        STA.W $1FF2                          
        LDX.W $1FF0                          
        LDA.L decimalLockUpTable,X           
        STA.L $7FFF08                        
        LDX.W $1FF2                          
        LDA.L decimalLockUpTable,X           
        STA.L $7FFF0A                        
        SEP #$20                             
        REP #$10                             
        LDA.B #$80                           
        STA.W $2115                          
        LDX.W #$5800                         
        STX.W $2116                          
        LDA.B #$7F                           
        LDX.W #$FF00                         
        LDY.W #$0020                         
        STX.W $4302                          
        STA.W $4304                          
        STY.W $4305                          
        LDA.B #$18                           
        STA.W $4301                          
        LDA.B #$01                           
        STA.W $4300                          
        STA.W $420B                          
        RTS                                  

	CODE_9EF5A4: 
		STA.W $4204                          
		SEP #$20                             
		LDA.B #$64                           
		STA.W $4206                          
		PHA                                  
		PLA                                  
		PHA                                  
		PLA                                  
		REP #$20                             
		LDA.W $4214                          
		STA.W $1FF0                          
		LDA.W $4216                          
		STA.W $4204                          
		SEP #$20                             
		LDA.B #$0A                           
		STA.W $4206                          
		PHA                                  
		PLA                                  
		PHA                                  
		PLA                                  
		REP #$20                             
		LDA.W $4214                          
		ASL A                                
		STA.W $1FF4                          
		LDA.W $4216                          
		ASL A                                
		STA.W $1FF6                          
		LDA.W $1FF0                          
		STA.W $4204                          
		SEP #$20                             
		LDA.B #$0A                           
		STA.W $4206                          
		PHA                                  
		PLA                                  
		PHA                                  
		PLA                                  
		REP #$20                             
		LDA.W $4214                          
		ASL A                                
		STA.W $1FF0                          
		LDA.W $4216                          
		ASL A                                
		STA.W $1FF2                          
		RTS                                  
	
	CODE_9EF5FD: 
		LDY.W $1FF2                          
        JSR.W CODE_9EF623                    
        LDY.W $1FF4                          
        JSR.W CODE_9EF623                    
        LDY.W $1FF6                          
        JSR.W CODE_9EF623                    
        RTS                                  
	CODE_9EF610: 
		LDY.W $1FF2                          
        JSR.W CODE_9EF62D                    
        LDY.W $1FF4                          
        JSR.W CODE_9EF62D                    
        LDY.W $1FF6                          
        JSR.W CODE_9EF62D                    
        RTS                                  
	CODE_9EF623: 
		LDA.W decimalLockUpTable,Y           
        STA.L $7FFF00,X                      
        INX                                  
        INX                                  
        RTS                                  
	CODE_9EF62D: 
		LDA.W numberPatternLockUpTable,Y     
        STA.L $7FFF00,X                      
        INX                                  
        INX                                  
        RTS                                  

	label_1EF637:									;frame counter. Executed in RAM? Not in Diz dissasembly
		LDA $7FFF00,X
		CMP #$2001
		BNE label_1EF65F
		LDA #$0000
		STA $7FFF00,X
		INX
		INX
		BRA label_1EF637
		LDA $7FFF00,X
		CMP #$2C01
		BNE label_1EF65F
		LDA #$0000
		STA $7FFF00,X
		INX
		INX
		BRA label_1EF637

	label_1EF65F:
		CMP #$0CCB
		BNE label_1EF66D
		DEX
		DEX
		LDA #$0C09
		STA $7FFF00,X

	label_1EF66D:
		RTS

	decimalLockUpTable:	
		dw $2001,$2002,$2003,$2004,$2005,$2006,$2007,$2008,$2009,$200A,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	numberPatternLockUpTable:
		dw $2C01,$2C02,$2C03,$2C04,$2C05,$2C06,$2C07,$2C08,$2C09,$2C0A,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	
 
 ;;;;;;;;;; exportedMenueRoutines to get some space in Bank 9f
 
	disableRNG:
		phx
		PLD
		lda !RNGdisable
		beq doRNG
		lda #$ffff	; RNG place holder
		sta $e6
		sta $e8
		sta $ea
		rtl
	doRNG:                                   
		LDA.B $E8        
		jml $808192
 
	musicSelector:
		lda $20				; Select Hold check
		bit #$2000
		beq endMusicSelector	 

		lda $28				; rotate music with select X
		cmp #$0040
		bne playMusicSelecteded
		lda !costumMusicNumber
		inc 
		cmp #$0023
		bne +
		lda #$0000
	+	sta !costumMusicNumber
		inc 
		ora #$2400				;store to display
		sta $7FFF1E		 
		
	playMusicSelecteded: 
		lda $28				
		cmp #$0080				; A button Press
		bne endMusicSelector		
		
		lda !costumMusicNumber				; selected music
		asl 
		jsl $8280DD			; music change
		JSL.L $80859E  		; donno seems to tune the music a bit quicker..
;		lda #$000f0			; reset Music
;		JSL.L $8085E3
		
		pla				; get rid of stuck pointer to check again if Simon died
		sep #$20
		pla
		rep #$30
		sec
		JML.L $8097A5
		
	endMusicSelector:	
		rtl
		
		
;	outofBounceCheckL:	
;		lda !OutOfBouncDeath 				; out of bounce disabler
;		beq justDie
;		lda #$0001
;		sta $00b6
;		bra doWhatEver
;	justDie: 	
;		stz $00b6
;	doWhatEver:
;		rtl
	
	
	goResetRoomL:
		stz !TimeStoperStop				; reset timeStoper
		lda #$0010
		sta $13f4
	
	;	jsl $80976d			; respawn handler
	;	jsl $8280b1			; death handler..
	
		lda #$0006				; setTo reload 
		sta $0070
;		jsr resetMod7rooms  	; seems usless because of checkpoints..
		rtl

	goToSelectedLevelL:
		STY.W $0086       	; storeCurrentLevel		
		stz !TimeStoperStop			; reset timeStoper
		stz $13d4			; make entrance 00 probably better then having back entrances noone wants..
		lda #$0006			; setTo reload 3 does not reset frame counter..
		sta $0070
		rtl

	doRefillL:
		lda #$0600
		sta $13f0			; timer
		lda #$0004			; cross
		sta $008e
		lda #$0002			
		sta $0090			; double
		sta $0092			; whip
		LDA.W #$0010      	; health     
		STA.W $13F4            
		LDA.W #$0040      	; heart     
		STA.W $13F2            
		LDA.W #$0005      	; lifes     
		STA.W $007C 
		rtl

	freeScrollRoutineL:
		lda $1298
		sec
		sbc #$0064
		sta $1298			; layer 1
		lda $12d8
		sec
		sbc #$0064
		sta $12d8 			; layer 2
;		lda $54e
;		sec
;		sbc #$0064			; simon 
;		sta $54e
		
		rtl 
;	healthRoutineL:
;		lda $13f2
;		inc
;		cmp #$0010
;		beq +
;		sta $13f2 
;	+	rtl 
	
	endXposViwer:
		rtl
	xposViwer:
		lda !xposViwerFlag
		beq endXposViwer
		
		lda #$0000
		sta $7fff14
		sta $7fff16
		sta $7fff18
		
		lda $54a			; First Digit
		and #$000F
		ora #$2400
		inc
		sta $7fff12
		
		lda $54a			; second Digit
		and #$00F0
		lsr
		lsr
		lsr
		lsr
		ora #$2400
		inc 
		sta $7fff10
		
		lda $54a			; third Digit
		and #$0F00
		lsr
		lsr
		lsr
		lsr
		lsr
		lsr
		lsr
		lsr
		ora #$2400
		inc 
		sta $7fff0e
	
;		lda $54a			; third Digit
;		and #$F000
;		lsr
;		lsr
;		lsr
;		lsr
;		lsr
;		lsr
;		lsr
;		lsr
;		lsr
;		lsr
;		lsr
;		lsr
;		ora #$2400
;		inc 
;		sta $7fff10
	
;ypos viwer		
		lda $54e			; First Digit
		and #$000F
		ora #$2400
		inc
		sta $7fff1e
		
		lda $54e			; second Digit
		and #$00F0
		lsr
		lsr
		lsr
		lsr
		ora #$2400
		inc 
		sta $7fff1c
		
		lda $54e			; third Digit
		and #$0F00
		lsr
		lsr
		lsr
		lsr
		lsr
		lsr
		lsr
		lsr
		ora #$2400
		inc 
		sta $7fff1a
		rtl		
	
;	seeThroughWallsL:
;		lda !seeThroughWalls
;		beq endSeeThrough
;		lda #$0008
;		sta $44
;	endSeeThrough:
;		rtl
		
;	seeThroughEnemyL:
;		lda !seeThroughEnemy
;		beq +
;		lda #$0004
;		sta $44
;	+	rtl	
		
;	doAutoWalkL:
;		lda !setAutoRun
;		beq endAutoWalkL
;		lda $20
;		and #$0300			; reset when left right walk input
;		beq autoWalkNow
;		stz !setAutoRun
;		
;	autoWalkNow:	
;;		jsl $80A684			; walk Animation
;		lda $544
;		bne simonWalkLeft
;		jsl $80A65E			; speedRoutine
;		rtl
;	simonWalkLeft:
;		jsl $80A677			; speedRoutine
;	endAutoWalkL:	
;		rtl
	
;	doBlueSkinL:
;		lda $1e1a			;switcher
;		beq endDoBlueSkinL
;			
;		lda #$7b74
;		sta $7e2310 
;		lda #$5dab
;		sta $7e2312
;		lda #$3883
;		sta $7e2314
;		lda #$0800
;		sta $7e2316
;	endDoBlueSkinL:	
;		rtl
;	orginalSimonPalette:
;		lda #$77b8
;		sta $7e2310 
;		lda #$4e70
;		sta $7e2312
;		lda #$2528
;		sta $7e2314
;		lda #$2462
;		sta $7e2316	
;		rtl 	

	goodModRoutine:
;		lda #$0010		; old god-mode
;		sta $13f4 		
;		
;		lda $552
;		cmp #$000f
;		bne +
;		lda #$0002
;		sta $552
		
		lda !godMod
		beq +
		
		lda #$0001
		sta $1f88
	+	rtl 
	flightModRoutine:		
		pha 
		
		lda !godMod
		beq +
		
		pla 	
		stz $1fa6 
;		jsl simonFlightControlls
		jml $80A129

	+	pla 
		jsl $8085E3
		jml $80A126 
	flightModControll:
		lda !godMod
		bne +
		
		jsl $80A621					; mud behavier 
		jsl $80A694                 ; 80A2CD|2294A680|80A694;  		
		jsl $80A792
	-	jml $80A605 
		
	+	jsl $80A792
		jsl simonFlightControlls
		jmp -
		
;	flightModControll02:
;		lda !godMod
;		bne +		
;		jsl $80A6C9
;		jsl $80A694
;		jsl $80A792		
;	+	jml $80A6AD

	
	simonFlightControlls:
		stz.w RAM_simonSlot_SpeedSubXpos		; seems done before.. 
		stz.w RAM_simonSlot_SpeedXpos
;		stz.w RAM_simonSlot_SpeedSubYpos
;		stz.w RAM_simonSlot_SpeedYpos 		
		lda $20
		bit #$0100
		bne goRight	
		
	checkLeft:
		lda $20
		bit #$0200
		bne goLeft
		rtl 
		
;	checkUp:
;		lda $20
;		bit #$0400
;		bne goUp
		
;	checkDown:
;		lda $20	
;		bit #$0800
;		bne	goDown
;		rtl 	
		
	goRight:		
		lda #$0001		; incXSpeed
		sta RAM_simonSlot_SpeedXpos
		lda #$c000
		sta RAM_simonSlot_SpeedSubXpos
		jmp checkLeft
		
	goLeft:		
		lda #$fffe 		; decXSpeed
		sta RAM_simonSlot_SpeedXpos
		lda #$8000
		sta RAM_simonSlot_SpeedSubXpos
		rtl
;		jmp checkUp
		
;	goUp:
;		lda #$0001		; incYSpeed
;		sta RAM_simonSlot_SpeedYpos
;		lda #$8000
;		sta RAM_simonSlot_SpeedSubYpos
;		bra checkDown
		
;	goDown:
;		lda #$fffe		; decYSpeed
;		sta RAM_simonSlot_SpeedYpos
;		lda #$8000
;		sta RAM_simonSlot_SpeedSubYpos
;		rtl 
	
	
	invincableRoutine:
		lda !invincableFlag
		beq +
		lda #$0003
		sta $00bc 
	+	rtl 



	timeStoperXposL:			
		lda !TimeStoperFlag
		beq endTimeStoper
		lda !TimerCompare
		bne +
		
		lda !TimeStoperFlag
		cmp #$0002				;0002 = ypos
		bne takeSimonsXpos
		lda $54e				; getYpos
		and #$fff0				; give it a 16 pixle box
		sta !TimerCompare
		bra ++
	takeSimonsXpos:	
		lda $54a				; getXpos
		and #$fff0
		sta !TimerCompare
		bra ++
	
	+	lda !TimeStoperFlag 
		cmp #$0002
		beq compareAgainstYpos	
		
		lda $54a 		;compares againt Xpos
		and #$fff0
		cmp !TimerCompare
		bne ++
		lda #$0001	 			; stop Timer
		sta !TimeStoperStop
	++	rtl
	endTimeStoper:	
		stz !TimerCompare		; resetting position for new one
		stz !TimeStoperStop		; disable Stopping
		rtl 
	
	compareAgainstYpos:
		lda $54e
		and #$fff0
		cmp !TimerCompare
		bne +
		lda #$0001	 	; stop Timer
		sta !TimeStoperStop
	+	rtl


	loopAfterDeathToo:
		lda !LoopFlag
		beq keepDieng
		lda #$0006		; resetRoomGiveHealth cheat death
		sta $70			
		lda #$0010
		sta $13f4
		lda #$0020
		sta $13f2	; give hearts 
		
		stz $13e2	; reset music when falling in pit 
		
		pla				; get rid of stuck pointer to check again if Simon died
		sep #$20
		pla
		rep #$30		
		rtl
	keepDieng:	
		stz $80
        sta $13c8          
		rtl 
		
;	resetMod7rooms:
;		ldy $0086					; else the graphic will not load 
;		cpy #$0000
;		beq +
;		cpy #$0015
;		beq +
;		cpy #$0016
;		beq +
;		cpy #$001b
;		beq +
;		bra ++
;	+	INC.W $007C        		; Life counter 
;        STZ.W $13F4        	; Delete Simons Health
;		lda #$0005
;		sta $0070
;		
;	++	rts		


	HudBackup2SramL:		
		PHP               	; Push Processor Status Register    	  
        SEP #$20         	; make A 8bit          	   
        REP #$10         	; makes Y 16 bit??        	   
        LDA.B #$80       	; set dest  	    
        STA.W $2115      	; VMAIN    	      	   
        LDX.W #$57FF     	; bg0 offset tilemap              	   
        STX.W $2116      	; VRAM Address Registers (Low)     	   
        LDA.B #$70       	  	    
        LDX.W #$0900     	; Load src Address    	  
        LDY.W #$0100     	         	   
        STX.W $4302      	; store low, A1TxL                           
        STA.W $4304      	; store high, A1TxH                          
        STY.W $4305      	; set increment DASxL              	   
    
		LDA.B #$01        	; DMA Enable Register    	    
        STA.W $4300          
        LDA.B #$18           
        STA.W $4301          
        LDA.B #$01           
        STA.W $420B          
        PLP  
		rtl
	
	menuSram2PPU_DMA_L:
		PHP             	; Push Processor Status Register    	
        SEP #$20       		; make A 8bit          	
        REP #$10       		; makes Y 16 bit??        	
        LDA.B #$80     		; set dest  	 
        STA.W $2115    		; VMAIN    	      	 
        LDX.W #$5800  		; bg0 offset tilemap              	 
        STX.W $2116    		; VRAM Address Registers (Low)     	 
        LDA.B #$70     		 	 
        LDX.W #$0608  		; Load src Address    	
        LDY.W #$0100  		             	 
        STX.W $4302    		; store low, A1TxL                         	 
        STA.W $4304    		; store high, A1TxH                        	 
        STY.W $4305    		; set increment DASxL              	 
       
	    LDA.B #$01     	    ; DMA Enable Register    	 
        STA.W $4300    	             	 
        LDA.B #$18     	    	 
        STA.W $4301    	                     	 
        LDA.B #$01     	       	 
        STA.W $420B    	                    	 
        PLP             	           
		rtl
	
	backupHUDL:
		PHP                	; Push Processor Status Register   
        SEP #$20          	; make A 8bit         
        REP #$10          	; makes Y 16 bit??       
        
		LDA.B #$80   		; set dest     	     
        STA.W $2115       	; VMAIN            
        LDX.W #$5800      	; bg0 offset tilemap
        STX.W $2116       	; VRAM Address Registers (Low)         
       
	    LDA.B #$70        	; Load src Address        
        LDX.W #$0900                       
        LDY.W #$0100                       
        STX.W $4302      	; store low, A1TxL                  
        STA.W $4304      	; store high, A1TxH                
        STY.W $4305      	; set increment DASxL                
       
	    LDA.B #$81       	                
        STA.W $4300      	 ; control register DMAPx               
        LDA.B #$39       	                
        STA.W $4301      	 ; dest Register DMAPx	                
        LDA.B #$01       	                
        STA.W $420B      	 ; DMA Enable Register            
        PLP
		RTL
		
warnpc $9effff        	
	
org $82bb1b
		generelLevelIncreseCode:
org $82ffbc
	loopLevelCode:	
		lda !LoopFlag
		beq +
		lda #$0006
		sta $70

		lda #$0010	; refill health 
		sta $13f4
		lda #$0020
		sta $13f2	; give hearts 

		rtl
	+ 	jml generelLevelIncreseCode	