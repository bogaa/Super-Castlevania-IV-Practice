;;  ;;;;;;;;;;;;;;;;;;;;
;;  ;;PracticeROM;;;;
;;  ;;;;;;;;;;;;;;;;

!saveState = 1

	;table "code/text_table_sc4.txt"	
	cleartable	;ASCII Table
	
	;SRAM TablePointer = $00F2
	;SRAM ?? = $00F6
	
	Native_COP = $0082BE             
	Native_NMI = $00FFB0             
	Native_RESET = $008000           
	PTR16_00FFFF = $00FFFF           
	

org $8081BF				; Beginnin of Interup?? Hijack
		JML.L hijackForDMAStuff
if !saveState == 1
org $8081bf
		jml.l code_1FF1EE
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


if !saveState == 1
org $9ff1d0
   UNREACH_1FF1D0: 
		rts 		
    UNREACH_1FF1D1:       
		rts 
	UNREACH_1FF1D2: 
		rts 		
    UNREACH_1FF1D3:                          ;1FF1D3|        |      ;  
		rts
   CODE_1FF1D4: 
		LDA.W $1E80                          ;1FF1D4|AD801E  |001E80;  
        STA.W $2100                          ;1FF1D7|8D0021  |002100;  
        LDA.W $1E82                          ;1FF1DA|AD821E  |001E82;  
        STA.W $4200                          ;1FF1DD|8D0042  |004200;  
    CODE_1FF1E0: 
		PLP                                  ;1FF1E0|28      |      ;  
        PLB                                  ;1FF1E1|AB      |      ;  
        jsr.w MainPracticeMenuDMA               ;1FF1E2|2060F4  |1FF460;  
        SEP #$20                             ;1FF1E5|E220    |      ;  
        LDX.W #$0000                         ;1FF1E7|A20000  |      ;  
        JML.L $8081C4                		 ;1FF1EA|5CC48100|0081C4;  
 
    code_1FF1EE:                                         ;      |        |      ;  
        PHB                                  ;1FF1EE|8B      |      ;  
        PHP                                  ;1FF1EF|08      |      ;  
        REP #$30                             ;1FF1F0|C230    |      ;  
        LDA.B $20                            ;1FF1F2|A520    |000020;  
        BIT.W #$2000                         ;1FF1F4|890020  |      ;  
        BEQ CODE_1FF1E0                      ;1FF1F7|F0E7    |1FF1E0;  
        AND.B $28                            ;1FF1F9|2528    |000028;  
        BEQ CODE_1FF1E0                      ;1FF1FB|F0E3    |1FF1E0;  
        LDA.B $20                            ;1FF1FD|A520    |000020;  
        CMP.W #$2010                         ;1FF1FF|C91020  |      ;  
        BEQ CODE_1FF20C                      ;1FF202|F008    |1FF20C;  
        CMP.W #$2020                         ;1FF204|C92020  |      ;  
        BNE CODE_1FF1E0                      ;1FF207|D0D7    |1FF1E0;  
        JMP.W CODE_1FF316                    ;1FF209|4C16F3  |1FF316;  
                                                            ;      |        |      ;  
    CODE_1FF20C: 
		JSR.W UNREACH_1FF1D2                 ;1FF20C|20D2F1  |1FF1D2;  
        PEA.W $0000                          ;1FF20F|F40000  |000000;  
        PLB                                  ;1FF212|AB      |      ;  
        PLB                                  ;1FF213|AB      |      ;  
        SEP #$20                             ;1FF214|E220    |      ;  
        LDY.W #$0000                         ;1FF216|A00000  |      ;  
        TYX                                  ;1FF219|BB      |      ;  
    CODE_1FF21A: 
		LDA.W $4300,X                        ;1FF21A|BD0043  |004300;  
        STA.L $770000,X                      ;1FF21D|9F000077|770000;  
        INX                                  ;1FF221|E8      |      ;  
        INY                                  ;1FF222|C8      |      ;  
        CPY.W #$000B                         ;1FF223|C00B00  |      ;  
        BNE CODE_1FF21A                      ;1FF226|D0F2    |1FF21A;  
        CPX.W #$007B                         ;1FF228|E07B00  |      ;  
        BEQ CODE_1FF237                      ;1FF22B|F00A    |1FF237;  
        INX                                  ;1FF22D|E8      |      ;  
        INX                                  ;1FF22E|E8      |      ;  
        INX                                  ;1FF22F|E8      |      ;  
        INX                                  ;1FF230|E8      |      ;  
        INX                                  ;1FF231|E8      |      ;  
        LDY.W #$0000                         ;1FF232|A00000  |      ;  
        BRA CODE_1FF21A                      ;1FF235|80E3    |1FF21A;  
                                                            ;      |        |      ;  
    CODE_1FF237: 
		REP #$30                             ;1FF237|C230    |      ;  
        LDX.W #$F244                         ;1FF239|A244F2  |      ;  
    CODE_1FF23C: 
		PEA.W $1F00                          ;1FF23C|F4001F  |001F00;  
        PLB                                  ;1FF23F|AB      |      ;  
        PLB                                  ;1FF240|AB      |      ;  
        JMP.W CODE_1FF426                    ;1FF241|4C26F4  |1FF426;  
                                                            ;      |        |      ;  
        db $00,$31,$80,$00,$00,$52,$00,$00   ;1FF244|        |      ;  saving 
        db $10,$43,$80,$80,$12,$43,$00,$00   ;1FF24C|        |      ;  
        db $14,$43,$71,$00,$16,$43,$80,$00   ;1FF254|        |      ;  
        db $81,$21,$00,$00,$83,$31,$00,$00   ;1FF25C|        |      ;  
        db $0B,$52,$02,$00,$12,$43,$00,$00   ;1FF264|        |      ;  
        db $14,$43,$72,$00,$16,$43,$80,$00   ;1FF26C|        |      ;  
        db $81,$21,$00,$80,$83,$31,$00,$00   ;1FF274|        |      ;  
        db $0B,$52,$02,$00,$12,$43,$00,$00   ;1FF27C|        |      ;  
        db $14,$43,$73,$00,$16,$43,$80,$00   ;1FF284|        |      ;  
        db $81,$21,$00,$00,$83,$31,$01,$00   ;1FF28C|        |      ;  
        db $0B,$52,$02,$00,$12,$43,$00,$00   ;1FF294|        |      ;  
        db $14,$43,$74,$00,$16,$43,$80,$00   ;1FF29C|        |      ;  
        db $81,$21,$00,$80,$83,$31,$01,$00   ;1FF2A4|        |      ;  
        db $0B,$52,$02,$00,$10,$43,$81,$39   ;1FF2AC|        |      ;  
        db $15,$31,$00,$00,$16,$21,$00,$00   ;1FF2B4|        |      ;  
        db $39,$B1,$00,$00,$12,$43,$00,$00   ;1FF2BC|        |      ;  
        db $14,$43,$75,$00,$16,$43,$80,$00   ;1FF2C4|        |      ;  
        db $0B,$52,$02,$00,$16,$21,$00,$40   ;1FF2CC|        |      ;  
        db $39,$B1,$00,$00,$12,$43,$00,$00   ;1FF2D4|        |      ;  
        db $14,$43,$76,$00,$16,$43,$80,$00   ;1FF2DC|        |      ;  
        db $0B,$52,$02,$00,$21,$31,$00,$00   ;1FF2E4|        |      ;  
        db $10,$43,$80,$3B,$12,$43,$00,$20   ;1FF2EC|        |      ;  
        db $14,$43,$77,$00,$16,$43,$02,$00   ;1FF2F4|        |      ;  
        db $0B,$52,$02,$00,$00,$00,$04,$F3   ;1FF2FC|        |      ;  
        
		PEA.W $0000                          ;1FF304|F40000  |000000;  
        PLB                                  ;1FF307|AB      |      ;  
        PLB                                  ;1FF308|AB      |      ;  
        REP #$30                             ;1FF309|C230    |      ;  
        TSC                                  ;1FF30B|3B      |      ;  
        STA.L $774004                        ;1FF30C|8F044077|774004;  
        JSR.W UNREACH_1FF1D3                 ;1FF310|20D3F1  |1FF1D3;  
        JMP.W CODE_1FF1D4                    ;1FF313|4CD4F1  |1FF1D4;  
                                                            ;      |        |      ;  
    CODE_1FF316: 
		JSR.W UNREACH_1FF1D0                 ;1FF316|20D0F1  |1FF1D0;  
        PEA.W $0000                          ;1FF319|F40000  |000000;  
        PLB                                  ;1FF31C|AB      |      ;  
        PLB                                  ;1FF31D|AB      |      ;  
        SEP #$20                             ;1FF31E|E220    |      ;  
        LDX.W #$F326                         ;1FF320|A226F3  |      ;  
        JMP.W CODE_1FF23C                    ;1FF323|4C3CF2  |1FF23C;  
                                                            ;      |        |      ;  
        db $0C,$52,$00,$00,$00,$31,$80,$00   ;1FF326|        |      ;  Loading
        db $00,$52,$00,$00,$10,$43,$00,$80   ;1FF32E|        |      ;  
        db $12,$43,$00,$00,$14,$43,$71,$00   ;1FF336|        |      ;  
        db $16,$43,$80,$00,$81,$21,$00,$00   ;1FF33E|        |      ;  
        db $83,$31,$00,$00,$0B,$52,$02,$00   ;1FF346|        |      ;  
        db $12,$43,$00,$00,$14,$43,$72,$00   ;1FF34E|        |      ;  
        db $16,$43,$80,$00,$81,$21,$00,$80   ;1FF356|        |      ;  
        db $83,$31,$00,$00,$0B,$52,$02,$00   ;1FF35E|        |      ;  
        db $12,$43,$00,$00,$14,$43,$73,$00   ;1FF366|        |      ;  
        db $16,$43,$80,$00,$81,$21,$00,$00   ;1FF36E|        |      ;  
        db $83,$31,$01,$00,$0B,$52,$02,$00   ;1FF376|        |      ;  
        db $12,$43,$00,$00,$14,$43,$74,$00   ;1FF37E|        |      ;  
        db $16,$43,$80,$00,$81,$21,$00,$80   ;1FF386|        |      ;  
        db $83,$31,$01,$00,$0B,$52,$02,$00   ;1FF38E|        |      ;  
        db $10,$43,$01,$18,$15,$31,$00,$00   ;1FF396|        |      ;  
        db $16,$21,$00,$00,$12,$43,$00,$00   ;1FF39E|        |      ;  
        db $14,$43,$75,$00,$16,$43,$80,$00   ;1FF3A6|        |      ;  
        db $0B,$52,$02,$00,$16,$21,$00,$40   ;1FF3AE|        |      ;  
        db $12,$43,$00,$00,$14,$43,$76,$00   ;1FF3B6|        |      ;  
        db $16,$43,$80,$00,$0B,$52,$02,$00   ;1FF3BE|        |      ;  
        db $21,$31,$00,$00,$10,$43,$00,$22   ;1FF3C6|        |      ;  
        db $12,$43,$00,$20,$14,$43,$77,$00   ;1FF3CE|        |      ;  
        db $16,$43,$02,$00,$0B,$52,$02,$00   ;1FF3D6|        |      ;  
        db $00,$00,$E2,$F3                   ;1FF3DE|        |      ;  
                       
		REP #$30                             ;1FF3E2|C230    |      ;  
		LDA.L $774004                        ;1FF3E4|AF044077|774004;  
		TCS                                  ;1FF3E8|1B      |      ;  
		PEA.W $0000                          ;1FF3E9|F40000  |000000;  
		PLB                                  ;1FF3EC|AB      |      ;  
		PLB                                  ;1FF3ED|AB      |      ;  
		LDA.B $20                            ;1FF3EE|A520    |000020;  
		EOR.W #$2010                         ;1FF3F0|491020  |      ;  
		ORA.W #$2020                         ;1FF3F3|092020  |      ;  
		STA.B $20                            ;1FF3F6|8520    |000020;  
		STA.B $28                            ;1FF3F8|8528    |000028;  
		SEP #$20                             ;1FF3FA|E220    |      ;  
		LDX.W #$0000                         ;1FF3FC|A20000  |      ;  
		TXY                                  ;1FF3FF|9B      |      ;  
    CODE_1FF400: 
		LDA.L $770000,X                      ;1FF400|BF000077|770000;  
        STA.W $4300,X                        ;1FF404|9D0043  |004300;  
        INX                                  ;1FF407|E8      |      ;  
        INY                                  ;1FF408|C8      |      ;  
        CPY.W #$000B                         ;1FF409|C00B00  |      ;  
        BNE CODE_1FF400                      ;1FF40C|D0F2    |1FF400;  
        CPX.W #$007B                         ;1FF40E|E07B00  |      ;  
        BEQ CODE_1FF41E                      ;1FF411|F00B    |1FF41E;  
        INX                                  ;1FF413|E8      |      ;  
        INX                                  ;1FF414|E8      |      ;  
        INX                                  ;1FF415|E8      |      ;  
        INX                                  ;1FF416|E8      |      ;  
        INX                                  ;1FF417|E8      |      ;  
        LDY.W #$0000                         ;1FF418|A00000  |      ;  
        JMP.W CODE_1FF400                    ;1FF41B|4C00F4  |1FF400;  
                                                            ;      |        |      ;  
    CODE_1FF41E: 
		REP #$30                             ;1FF41E|C230    |      ;  
        JSR.W UNREACH_1FF1D1                 ;1FF420|20D1F1  |1FF1D1;  1f480b
        JMP.W CODE_1FF1D4                    ;1FF423|4CD4F1  |1FF1D4;  
                                                            ;      |        |      ;  
    CODE_1FF426: 
		REP #$30                             ;1FF426|C230    |      ;  
        LDA.W $0000,X                        ;1FF428|BD0000  |000000;  
        BEQ CODE_1FF44F                      ;1FF42B|F022    |1FF44F;  
        TAY                                  ;1FF42D|A8      |      ;  
        INX                                  ;1FF42E|E8      |      ;  
        INX                                  ;1FF42F|E8      |      ;  
        BIT.W #$1000                         ;1FF430|890010  |      ;  
        BEQ CODE_1FF43B                      ;1FF433|F006    |1FF43B;  
        AND.W #$EFFF                         ;1FF435|29FFEF  |      ;  
        TAY                                  ;1FF438|A8      |      ;  
        SEP #$20                             ;1FF439|E220    |      ;  
    CODE_1FF43B: 
		LDA.W $0000,X                        ;1FF43B|BD0000  |000000;  
        INX                                  ;1FF43E|E8      |      ;  
        INX                                  ;1FF43F|E8      |      ;  
        CPY.W #$8000                         ;1FF440|C00080  |      ;  
        BCS CODE_1FF44A                      ;1FF443|B005    |1FF44A;  
        STA.W $0000,Y                        ;1FF445|990000  |000000;  
        BRA CODE_1FF426                      ;1FF448|80DC    |1FF426;  
                                                            ;      |        |      ;  
    CODE_1FF44A: 
		LDA.W Native_RESET,Y                 ;1FF44A|B90080  |008000;  
        BRA CODE_1FF426                      ;1FF44D|80D7    |1FF426;  
                                                            ;      |        |      ;  
    CODE_1FF44F: 
		JMP.W ($0002,X)                      ;1FF44F|7C0200  |1F0002;                                                             ;      |        |      ;  
	
	;cleanWRAM:
	;	LDA.W #$0000       	;orginal Setup                 
	;	STA.L $7FFFB0                          
	;	STA.L $7FFFB2                          
	;	STA.L $7FFFB4                          
	;	STA.L $7FFFB6                          
	;	STA.L $7FFFB8                          
	;	STA.L $7FFFBA                          
	;	RTS  
endif	

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
		LDA.L $7FFFB2                   
        STA.L $7FFFB8                   
        LDA.L $7FFFB0                   
        STA.L $7FFFB6                   
        LDA.W #$0000                    
        STA.L $7FFFB0                   
        STA.L $7FFFB2                   
        LDA.W #$0001                    
        STA.L $7FFFB4                   
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
		LDA.B $66                       
;        BEQ FrameCoutnterDo        ; dont run while pause
;        RTS                                    

	FrameCoutnterDo: 
		LDA.L $7FFFB0                        
        INC A                                
        CMP.W #$003C       			; compare agains framecoutnter                   
        BNE +                      
        LDA.L $7FFFB2                        
        INC A                                
        STA.L $7FFFB2                        
        LDA.W #$0000     			; ??                    
        STA.L $7FFFBA                        	 
	
	+	STA.L $7FFFB0                        
        RTS                                  
	
	frameCounterHudDisp: 
		STZ.W $1FF0                          
        STZ.W $1FF2                          
        STZ.W $1FF4                          
        STZ.W $1FF6                          
        LDA.L $7FFFB2                        
        CMP.L $7FFFB4                        
        BEQ drawFrameCount2Hud                      
        STA.L $7FFFB4                        
        JSR.W CODE_9EF5A4                    
        LDX.W #$0000                         
        JSR.W CODE_9EF5FD                    
	drawFrameCount2Hud: 
		LDA.L $7FFFB0                        
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
 
 
	musicSelector:
		lda $1e18
		cmp #$0000
		bmi +
		dec 
		sta $1e18
		bra endMusicSelector
	+	lda $28
		cmp #$0080				; A button Press
		bne endMusicSelector
		
		lda $20
		bit #$2000
		beq endMusicSelector	; Select Hold
		
		lda #$00f0				; timer to switch music.. else it crashes
		sta $1e18

		lda $1E16
		inc 
		inc
		cmp #$0036
		bne ++
		lda #$0000
	
	++	sta $1E16
		
		jsl $8280DD				; music change
		JSL.L $80859E  			; donno hopfully fixes shit..
;		lda #$000f0				; reset Music
;		JSL.L $8085E3
	endMusicSelector:	
		LDA.B $28                          
        AND.W #$1000     
		JML.L $8097A5           ; setPauseFlag if equal and continue.. 
 
	doSkywalkerL:
		lda #$0001
		sta $0080		;skywalking
;		lda #$0100		;used for menu stuff
;		sta $00bc		;invincable 
		lda #$0050
		sta $00c2
		lda #$0080
		sta $0084		;damageDebugg
		rtl
	
	goGetStandartGearL:
		lda #$0044			;getz Gearz
		sta $13f2
		and #$000F
		sta $008e
		lda #$0002
		sta $0090
		sta $0092
		rtl
	
	goResetRoomL:
		lda #$0010
		sta $13f4
		lda #$0006			; setTo reload 
		sta $0070
;		jsr resetMod7rooms  ; seems usless because of checkpoints..
		rtl

	goToSelectedLevelL:
		STY.W $0086         ; storeCurrentLevel		
		lda #$0006			;setTo reload 3 does not reset frame counter..
		sta $0070
		rtl

	doRefillL:
		LDA.W #$0010      ; health     
		STA.W $13F4            
		LDA.W #$0040      ; heart     
		STA.W $13F2            
		LDA.W #$0005      ; lifes     
		STA.W $007C 
		rtl
	
	doSwitchSecondQuestL:
		lda $0088
		beq makeSecondQuest
		stz $0088
		bra +
	makeSecondQuest:	
		lda #$0008
		sta $0088
	
	+	lda #$0006
		sta $70
		rtl
		
	goToPlaySongL:
		tya
;       STA.W $13E2                          ;CurrentMusicTrack??
;	   	ASL A 
;		jsl $8280DD
;		jsl $8085E3 sfx
;		LDA.W #$00F1                         ;enable Music in Menu
;       JSL.L $8085E3	
		rtl
		
;	resetMod7rooms:
;		ldy $0086		;else the graphic will not load 
;		cpy #$0000
;		beq +
;		cpy #$0015
;		beq +
;		cpy #$0016
;		beq +
;		cpy #$001b
;		beq +
;		bra ++
;	+	INC.W $007C        ; Life counter 
;        STZ.W $13F4        ; Delete Simons Health
;		lda #$0005
;		sta $0070
;		
;	++	rts		
warnpc $9effff        


org $9ff460				; $9FF3c6 could save space.. may be for patch or editor compatibelity 
	MainPracticeMenuDMA: 
		PHD                            
        PHA                            
        PHP                            
        PEA.W $0000                    
        PLD                            
        REP #$30                       
        LDA.L $7FFFD0                  
        BEQ setPracticeMenuFlag         
       
		JSR.W MenueStatues                 
		REP #$30                          
		JMP.W endMainPracticeMenuDMA     
                                          
	setPracticeMenuFlag: 
		LDA.B $20                     ;9FF477|A520    |000020;  
        CMP.W #$3000                  ;check if start+select is pressed
        BNE endMainPracticeMenuDMA                       
        LDA.W #$0001                          
        STA.L $7FFFD0
	endMainPracticeMenuDMA: 
		PLP                                   
        PLA                                   
        PLD                                   
        RTS                                   
             
	startUpSetup:		 
		PHA                                   
		PHP                                  
		REP #$30                             
		LDA.W #$0000                             
		STA.L $7FFFD0                        
		STA.L $7FFFD2                        
		STA.L $7FFFD4                        
		STA.L $7FFFD6                        
		STA.L $7FFFD8                        
		STA.L $7FFFDA                        
		STA.L $7FFFE0                        
		JSL.L cleanWRAM                    
		PLP                                  
		PLA                                  
		JSL.L $82858F 			; what code??    Loading sequentz at the beginning of the game..               
		RTL                                  


	CheckStartSelectPress:            
		LDA.B $20,X             ; 9FF4B7|B520    |000020;  
        CMP.W #$3000                         
        BEQ endCheckStartSelectPress                      
        LDA.B $28,X                          
        AND.W #$1000                         
		jml musicSelector
	;    JML.L $8097A5           ; setPauseFlag if equal and continue.. 

	endCheckStartSelectPress: 
		rtl    					; endPause orginal JML.L $8097C2.  

	MenueStatues: 
		PHA                                  ;9FF4CB|48      |      ;  
        PHX                                 
        PHY                                 
        PHP                                 
        REP #$30                            
        LDA.L $7FFFD0                       
        CMP.W #$0001      			; goTo if                  
        BEQ randerMenu1                     
        CMP.W #$0002            	; goTo if               
        BEQ randerMenu2                     
        CMP.W #$0003             	; goTo if              
        BEQ randerMenu3                     

	goToSetInitDMA: 
		LDA.L $7FFFD0                        ;9FF4E4|AFD0FF7F|7FFFD0;  
        BEQ endInterupt                      ;9FF4E8|F003    |9FF4ED;  
        JSR.W setInitDMA                    ;9FF4EA|2090F7  |9FF790;  

	endInterupt: 
		PLP              
        PLY              
        PLX              
        PLA              
        REP #$20         
        PLA              
        JSL.L $808788     ;Controller ReadOut??
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
     
randerMenu1: 
		JSR.W CODE_9FF701      
        JSR.W CODE_9FF733      
        JSR.W CODE_9FF51C      
        JMP.W goToSetInitDMA   
                               
randerMenu2: 
		JSR.W userInputChecks  
        JMP.W goToSetInitDMA   
                               
randerMenu3: 
		JSR.W CODE_9FF777      
        JMP.W goToSetInitDMA   

CODE_9FF51C: 
		JSR.W CODE_9FF765      
        LDA.W #mainMenuList                  ;Load List Pointer $1FF937
        STA.L $7FFFDA                        ;WRAM Location 
        LDA.W #$0000       
        STA.L $7FFFD8      
        STA.L $7FFFD2      
        STA.L $7FFFD6      
        STA.L $7FFFE0      
        JSR.W CODE_9FF7F4  
        LDA.W #$0002       
        STA.L $7FFFD0      
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
	BPressAction: 	;enable
		JMP.W BPressActionDo       
	APressAction: 	;leave
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
        BNE ++                 
        JMP.W advanceCurserDo  	
	++	DEC A                  
        STA.L $7FFFD2          
        JMP.W advanceCurserDo  
    
	rightPressAction: 
		LDA.L $7FFFD2          
        BNE +++                
        JMP.W advanceCurserDo      
	+++	DEC A                  
        DEC A                  
        DEC A                  
        DEC A                  
        CMP.W #$0000           
        BPL resetCurserPos     
        LDA.W #$0000           
	resetCurserPos: 
		STA.L $7FFFD2          
        STA.L $7FFFD8          
        JMP.W advanceCurserDo  
                               
	leftPressAction: 
		LDA.L $7FFFD2          
        CMP.L $7FFFD6          
        BNE ++++       
        JMP.W advanceCurserDo  
               
   ++++ INC A                  
        INC A                  
        INC A                  
        INC A                  
        CMP.L $7FFFD6          
        BMI CODE_9FF5E3        
        LDA.L $7FFFD6          
        STA.L $7FFFD2          
        SEC                    
        SBC.W #$0003           
        STA.L $7FFFD8          
        JMP.W advanceCurserDo  
                               
	CODE_9FF5E3: 
		STA.L $7FFFD2          
        STA.L $7FFFD8          
        JMP.W advanceCurserDo  
                               
	startPressActionDo: 
		LDA.W #$0003           
        STA.L $7FFFD0          
        RTS                    
                               
	APressActionDo: 
		LDA.L $7FFFE0          
        BEQ startPressActionDo        
        TAX                    
        DEC A                  
        DEC A                  
        STA.L $7FFFE0          
        LDA.L $7FFFE0,X        
        STA.L $7FFFDA          
        JSR.W CODE_9FF765      
        LDA.W #$0000           
        STA.L $7FFFD8          
        STA.L $7FFFD2          
        STA.L $7FFFD6          
        LDA.W #$0001           
        STA.L $7FFFD4          
        JMP.W CODE_9FF6FD     ;setCurser to End or Beginning?? 
                               
	BPressActionDo: 
		PHB            
        PEA.W $1F00                
        PLB                        
        PLB                        
        LDA.L $7FFFDA              
        STA.B $F0                  
        LDY.W #$0000               
        STY.B $F6                  
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
        BEQ CODE_9FF661            
        CPX.W #$007E               
        BEQ CODE_9FF671            
        CPX.W #$007F               
        BEQ CODE_9FF671            
        CPX.W #$107E               
        BEQ UNREACH_9FF69A         
        CPX.W #$107F               
        BEQ UNREACH_9FF69A         
        JMP.W CODE_9FF6B5          
                                   
	CODE_9FF661: 
		TYA                                  ;9FF661|98      |      ;  
        CLC                                  ;9FF662|18      |      ;  
        ADC.B $F0                            ;9FF663|65F0    |0000F0;  
        TAX                                  ;9FF665|AA      |      ;  
        INY                                  ;9FF666|C8      |      ;  
        INY                                  ;9FF667|C8      |      ;  
        LDA.B ($F0),Y                        ;9FF668|B1F0    |0000F0;  
        TAY                                  ;9FF66A|A8      |      ;  
        JSR.W ($0000,X)                      ;9FF66B|FC0000  |9F0000;  
        JMP.W CODE_9FF6B5                    ;9FF66E|4CB5F6  |9FF6B5;  
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
        JSR.W CODE_9FF7F4                    ;9FF68D|20F4F7  |9FF7F4;  
        LDA.W #$0001                         ;9FF690|A90100  |      ;  
        STA.L $7FFFD4                        ;9FF693|8FD4FF7F|7FFFD4;  
        JMP.W CODE_9FF6B5                    ;9FF697|4CB5F6  |9FF6B5;  

	UNREACH_9FF69A:			;unused? Not in Diz Dissasembly
		STX $B5
		LDA ($F0),Y
		STA $B3
		INY
		INY
		LDA [$B3]
		EOR ($F0),Y
		STA [$B3]
		JSR $F7F4
		LDA #$0001
		STA $7FFFD4
		JMP $f6b5			;label_9FF6B5

	CODE_9FF6B5: 
		PLB                                  ;9FF6B5|AB      |      ;  
        LDA.L $7FFFD4                        ;9FF6B6|AFD4FF7F|7FFFD4;  
        BEQ CODE_9FF6C4                      ;9FF6BA|F008    |9FF6C4;  
        LDA.W #$0000                         ;9FF6BC|A90000  |      ;  
        STA.L $7FFFD4                        ;9FF6BF|8FD4FF7F|7FFFD4;  
        RTS                                  ;9FF6C3|60      |      ;  
                                                  ;      |        |      ;  
	CODE_9FF6C4: 
		LDA.W #$0003                         ;9FF6C4|A90300  |      ;  
        STA.L $7FFFD0                        ;9FF6C7|8FD0FF7F|7FFFD0;  
        RTS                                  ;9FF6CB|60      |      ;  

	advanceCurserDo: 
		LDA.L $7FFFD8                        ;9FF6CC|AFD8FF7F|7FFFD8;  
        CLC                                  ;9FF6D0|18      |      ;  
        ADC.W #$0004                         ;9FF6D1|690400  |      ;  
        CMP.L $7FFFD2                        ;9FF6D4|CFD2FF7F|7FFFD2;  
        BNE CODE_9FF6E6                      ;9FF6D8|D00C    |9FF6E6;  
        LDA.L $7FFFD8                        ;9FF6DA|AFD8FF7F|7FFFD8;  
        INC A                                ;9FF6DE|1A      |      ;  
        STA.L $7FFFD8                        ;9FF6DF|8FD8FF7F|7FFFD8;  
        JMP.W CODE_9FF6FD                    ;9FF6E3|4CFDF6  |9FF6FD;  
                                                  ;      |        |      ;  
	CODE_9FF6E6: 
		LDA.L $7FFFD8                        ;9FF6E6|AFD8FF7F|7FFFD8;  
        SEC                                  ;9FF6EA|38      |      ;  
        SBC.W #$0001                         ;9FF6EB|E90100  |      ;  
        CMP.L $7FFFD2                        ;9FF6EE|CFD2FF7F|7FFFD2;  
        BNE CODE_9FF6FD                      ;9FF6F2|D009    |9FF6FD;  
        LDA.L $7FFFD8                        ;9FF6F4|AFD8FF7F|7FFFD8;  
        DEC A                                ;9FF6F8|3A      |      ;  
        STA.L $7FFFD8                        ;9FF6F9|8FD8FF7F|7FFFD8;  
	CODE_9FF6FD: 
		JSR.W CODE_9FF7F4                    ;9FF6FD|20F4F7  |9FF7F4;  
        RTS                                  ;9FF700|60      |      ;  
                                                  ;      |        |      ;  
	CODE_9FF701: 
		REP #$30                             ;9FF701|C230    |      ;  
        LDX.W #$0000                         ;9FF703|A20000  |      ;  
	CODE_9FF706: 
		LDA.B $B0,X                          ;9FF706|B5B0    |0000B0;  
        STA.L $7000B0,X                      ;9FF708|9FB00070|7000B0;  
        LDA.B $F0,X                          ;9FF70C|B5F0    |0000F0;  
        STA.L $7000F0,X                      ;9FF70E|9FF00070|7000F0;  
        INX                                  ;9FF712|E8      |      ;  
        INX                                  ;9FF713|E8      |      ;  
        CPX.W #$0010                         ;9FF714|E01000  |      ;  
        BNE CODE_9FF706                      ;9FF717|D0ED    |9FF706;  
        RTS                                  ;9FF719|60      |      ;  
                                                  ;      |        |      ;  
	CODE_9FF71A: 
		REP #$30                             ;9FF71A|C230    |      ;  
        LDX.W #$0000                         ;9FF71C|A20000  |      ;  
	CODE_9FF71F: 
		LDA.L $7000B0,X                      ;BackupPointers to ZeroPage??
        STA.B $B0,X                          ;9FF723|95B0    |0000B0;  
        LDA.L $7000F0,X                      ;9FF725|BFF00070|7000F0;  
        STA.B $F0,X                          ;9FF729|95F0    |0000F0;  
        INX                                  ;9FF72B|E8      |      ;  
        INX                                  ;9FF72C|E8      |      ;  
        CPX.W #$0010                         ;9FF72D|E01000  |      ;  
        BNE CODE_9FF71F                      ;9FF730|D0ED    |9FF71F;  
        RTS                                  ;9FF732|60      |      ;  
	CODE_9FF733: 
		PHP                                  ;9FF733|08      |      ;  
        SEP #$20                             ;9FF734|E220    |      ;  
        REP #$10                             ;9FF736|C210    |      ;  
        LDA.B #$80                           ;9FF738|A980    |      ;  
        STA.W $2115                          ;9FF73A|8D1521  |812115;  
        LDX.W #$5800                         ;9FF73D|A20058  |      ;  
        STX.W $2116                          ;9FF740|8E1621  |812116;  
        LDA.B #$70                           ;9FF743|A970    |      ;  
        LDX.W #$0900                         ;9FF745|A20009  |      ;  
        LDY.W #$0100                         ;9FF748|A00001  |      ;  
        STX.W $4302                          ;9FF74B|8E0243  |814302;  
        STA.W $4304                          ;9FF74E|8D0443  |814304;  
        STY.W $4305                          ;9FF751|8C0543  |814305;  
        LDA.B #$81                           ;9FF754|A981    |      ;  
        STA.W $4300                          ;9FF756|8D0043  |814300;  
        LDA.B #$39                           ;9FF759|A939    |      ;  
        STA.W $4301                          ;9FF75B|8D0143  |814301;  
        LDA.B #$01                           ;9FF75E|A901    |      ;  
        STA.W $420B                          ;9FF760|8D0B42  |81420B;  
        PLP                                  ;9FF763|28      |      ;  
        RTS                                  ;9FF764|60      |      ;  
                                                  ;      |        |      ;  
	CODE_9FF765: 
		LDA.W #$0000                         ;9FF765|A90000  |      ;  
		LDX.W #$0000                         ;9FF768|A20000  |      ;  
	CODE_9FF76B: 
		STA.L $700608,X                      ;SRAM Menu Table
        INX                                  ;9FF76F|E8      |      ;  
        INX                                  ;9FF770|E8      |      ;  
        CPX.W #$0100                         ;9FF771|E00001  |      ;  
        BNE CODE_9FF76B                      ;9FF774|D0F5    |9FF76B;  
        RTS                                  ;9FF776|60      |      ;  
                                                  ;      |        |      ;  
	CODE_9FF777: 
		JSR.W CODE_9FF765                    ;9FF777|2065F7  |9FF765;  
        JSR.W CODE_9FF7C2                    ;9FF77A|20C2F7  |9FF7C2;  
        JSR.W CODE_9FF71A                    ;9FF77D|201AF7  |9FF71A;  
        LDA.W #$0000                         ;9FF780|A90000  |      ;  
        STA.L $7FFFD0                        ;9FF783|8FD0FF7F|7FFFD0;  
        STA.L $7FFB50                        ;9FF787|8F50FB7F|7FFB50;  
        STA.L $7FFB52                        ;9FF78B|8F52FB7F|7FFB52;  
        RTS                                  ;9FF78F|60      |      ;  

	setInitDMA: 
		PHP                                  ;9FF790|08      |      ;  
        SEP #$20                             ;9FF791|E220    |      ;  
        REP #$10                             ;9FF793|C210    |      ;  
        LDA.B #$80                           ;9FF795|A980    |      ;  
        STA.W $2115                          ;9FF797|8D1521  |812115;  
        LDX.W #$5800                         ;9FF79A|A20058  |      ;  
        STX.W $2116                          ;9FF79D|8E1621  |812116;  
        LDA.B #$70                           ;9FF7A0|A970    |      ;  
        LDX.W #$0608                         ;SRAM Menu Table
        LDY.W #$0100                         ;9FF7A5|A00001  |      ;  
        STX.W $4302                          ;9FF7A8|8E0243  |814302;  
        STA.W $4304                          ;9FF7AB|8D0443  |814304;  
        STY.W $4305                          ;9FF7AE|8C0543  |814305;  
        LDA.B #$01                           ;9FF7B1|A901    |      ;  
        STA.W $4300                          ;9FF7B3|8D0043  |814300;  
        LDA.B #$18                           ;9FF7B6|A918    |      ;  
        STA.W $4301                          ;9FF7B8|8D0143  |814301;  
        LDA.B #$01                           ;9FF7BB|A901    |      ;  
        STA.W $420B                          ;9FF7BD|8D0B42  |81420B;  
        PLP                                  ;9FF7C0|28      |      ;  
        RTS                                  ;9FF7C1|60      |      ;  
                                                  ;      |        |      ;  
	CODE_9FF7C2: 
		PHP                                  ;9FF7C2|08      |      ;  
        SEP #$20                             ;9FF7C3|E220    |      ;  
        REP #$10                             ;9FF7C5|C210    |      ;  
        LDA.B #$80                           ;9FF7C7|A980    |      ;  
        STA.W $2115                          ;9FF7C9|8D1521  |812115;  
        LDX.W #$57FF                         ;9FF7CC|A2FF57  |      ;  
        STX.W $2116                          ;9FF7CF|8E1621  |812116;  
        LDA.B #$70                           ;9FF7D2|A970    |      ;  
        LDX.W #$0900                         ;9FF7D4|A20009  |      ;  
        LDY.W #$0100                         ;9FF7D7|A00001  |      ;  
        STX.W $4302                          ;9FF7DA|8E0243  |814302;  
        STA.W $4304                          ;9FF7DD|8D0443  |814304;  
        STY.W $4305                          ;9FF7E0|8C0543  |814305;  
        LDA.B #$01                           ;9FF7E3|A901    |      ;  
        STA.W $4300                          ;9FF7E5|8D0043  |814300;  
        LDA.B #$18                           ;9FF7E8|A918    |      ;  
        STA.W $4301                          ;9FF7EA|8D0143  |814301;  
        LDA.B #$01                           ;9FF7ED|A901    |      ;  
        STA.W $420B                          ;9FF7EF|8D0B42  |81420B;  
        PLP                                  ;9FF7F2|28      |      ;  
        RTS                                  ;9FF7F3|60      |      ;  

	CODE_9FF7F4: 
		PHB                                  ;9FF7F4|8B      |      ;  
        PEA.W $9F00                          ;9FF7F5|F4001F  |811F00;  
        PLB                                  ;9FF7F8|AB      |      ;  
        PLB                                  ;9FF7F9|AB      |      ;  
        LDA.W #$7000                         ;9FF7FA|A90070  |      ;  
        STA.B $F3                            ;9FF7FD|85F3    |0000F3;  
        LDA.W #$0608                         ;SRAM Menu Table SetPosition
        STA.B $F2                            ;SRAM TablePointer
        LDA.L $7FFFDA                        ;9FF804|AFDAFF7F|7FFFDA;  
        STA.B $F0                            ;9FF808|85F0    |0000F0;  
        LDA.L $7FFFD8                        ;9FF80A|AFD8FF7F|7FFFD8;  
        STA.B $F8                            ;9FF80E|85F8    |0000F8;  
        LDA.W #$0000                         ;9FF810|A90000  |      ;  
        STA.B $F6                            ;9FF813|85F6    |0000F6;  
        LDA.W #$0000                         ;9FF815|A90000  |      ;  
        LDX.W #$0002                         ;9FF818|A20200  |      ;  
        LDY.W #$0000                         ;9FF81B|A00000  |      ;  
        LDA.B $F8                            ;9FF81E|A5F8    |0000F8;  
        STA.B $F6                            ;9FF820|85F6    |0000F6;  
        ASL A                                ;9FF822|0A      |      ;  
        ASL A                                ;9FF823|0A      |      ;  
        ASL A                                ;9FF824|0A      |      ;  
        TAY                                  ;9FF825|A8      |      ;  
	CODE_9FF826: 
		LDA.B ($F0),Y                        ;9FF826|B1F0    |0000F0;  
        CMP.W #$FFFF                         ;9FF828|C9FFFF  |      ;  
        BNE CODE_9FF830                      ;9FF82B|D003    |9FF830;  
        JMP.W GetDataBankRegister_9FF8F8                    ;9FF82D|4CF8F8  |9FF8F8;  
                                                  ;      |        |      ;  
	CODE_9FF830: 
		STA.B $B5                            ;9FF830|85B5    |0000B5;  
        INY                                  ;9FF832|C8      |      ;  
        INY                                  ;9FF833|C8      |      ;  
        LDA.B ($F0),Y                        ;9FF834|B1F0    |0000F0;  
        STA.B $B3                            ;9FF836|85B3    |0000B3;  
        INY                                  ;9FF838|C8      |      ;  
        INY                                  ;9FF839|C8      |      ;  
        LDA.B $F2                            ;9FF83A|A5F2    |0000F2;  
        CMP.W #$0708                         ;9FF83C|C90807  |      ;  
        BEQ CODE_9FF844                      ;9FF83F|F003    |9FF844;  
        JMP.W CODE_9FF855                    ;9FF841|4C55F8  |9FF855;  

	CODE_9FF844: 
		LDA.L $7FFFD6                        ;Check for Menu Pos??
        BEQ CODE_9FF84C                      ;9FF848|F002    |9FF84C;  
        PLB                                  ;9FF84A|AB      |      ;  
        RTS                                  ;9FF84B|60      |      ;  
	CODE_9FF84C: 
		INY                                  ;9FF84C|C8      |      ;  
        INY                                  ;9FF84D|C8      |      ;  
        INY                                  ;9FF84E|C8      |      ;  
        INY                                  ;9FF84F|C8      |      ;  
        INC.B $F6                            ;9FF850|E6F6    |0000F6;  
        JMP.W CODE_9FF826                    ;9FF852|4C26F8  |9FF826;  
	CODE_9FF855: 
		LDA.B $F6                            ;9FF855|A5F6    |0000F6;  
        CMP.L $7FFFD2                        ;9FF857|CFD2FF7F|7FFFD2;  
        BEQ CODE_9FF865                      ;9FF85B|F008    |9FF865;  
        LDA.W #$0000                         ;9FF85D|A90000  |      ;  
        STA.B [$F2]                          ;9FF860|87F2    |0000F2;  
        JMP.W CODE_9FF86A                    ;9FF862|4C6AF8  |9FF86A;  
	CODE_9FF865: 
		LDA.W #$2C27                         ;9FF865|A9272C  |      ;  
        STA.B [$F2]                          ;9FF868|87F2    |0000F2;  
	CODE_9FF86A: 
		INY                                  ;9FF86A|C8      |      ;  
        INY                                  ;9FF86B|C8      |      ;  
        LDA.B ($F0),Y                        ;9FF86C|B1F0    |0000F0;  
        STA.B $B1                            ;9FF86E|85B1    |0000B1;  
        PHY                                  ;9FF870|5A      |      ;  
        LDY.W #$0000                         ;9FF871|A00000  |      ;  
        LDX.W #$0002                         ;9FF874|A20200  |      ;  
	CODE_9FF877: 
		LDA.W #$0000                         ;9FF877|A90000  |      ;  
        LDA.B ($B1),Y                        ;9FF87A|B1B1    |0000B1;  
        AND.W #$00FF                         ;9FF87C|29FF00  |      ;  
        BNE CODE_9FF884                      ;9FF87F|D003    |9FF884;  
        JMP.W CODE_9FF893                    ;9FF881|4C93F8  |9FF893;  
	CODE_9FF884: 
		PHY                                  ;9FF884|5A      |      ;  
        ASL A                                ;9FF885|0A      |      ;  
        TAY                                  ;9FF886|A8      |      ;  
        LDA.W UNREACH_1FFC8B,Y               ;9FF887|B98BFC  |1FFC8B;  
        TXY                                  ;9FF88A|9B      |      ;  
        STA.B [$F2],Y                        ;9FF88B|97F2    |0000F2;  
        PLY                                  ;9FF88D|7A      |      ;  
        INX                                  ;9FF88E|E8      |      ;  
        INX                                  ;9FF88F|E8      |      ;  
        INY                                  ;9FF890|C8      |      ;  
        BRA CODE_9FF877                      ;9FF891|80E4    |9FF877;  
	CODE_9FF893: 
		INY                                  ;9FF893|C8      |      ;  
        LDA.B $B5                            ;9FF894|A5B5    |0000B5;  
        CMP.W #$0000                         ;9FF896|C90000  |      ;  
        BEQ CODE_9FF8D6                      ;9FF899|F03B    |9FF8D6;  
        BIT.W #$1000                         ;9FF89B|890010  |      ;  
        BNE UNREACH_9FF8B3                   ;9FF89E|D013    |9FF8B3;  
        PLY                                  ;9FF8A0|7A      |      ;  
        DEY                                  ;9FF8A1|88      |      ;  
        DEY                                  ;9FF8A2|88      |      ;  
        LDA.B ($F0),Y                        ;9FF8A3|B1F0    |0000F0;  
        INY                                  ;9FF8A5|C8      |      ;  
        INY                                  ;9FF8A6|C8      |      ;  
        PHY                                  ;9FF8A7|5A      |      ;  
        STA.B $B1                            ;9FF8A8|85B1    |0000B1;  
        LDA.B [$B3]                          ;9FF8AA|A7B3    |0000B3;  
        CMP.B $B1                            ;9FF8AC|C5B1    |0000B1;  
        BNE CODE_9FF8D6                      ;9FF8AE|D026    |9FF8D6;  
        JMP.W CODE_9FF8C3                    ;9FF8B0|4CC3F8  |9FF8C3;  

	UNREACH_9FF8B3: 								;Not is diz.. probably rarly used..
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
		PHY                                  ;9FF8C3|5A      |      ;  
        TXY                                  ;9FF8C4|9B      |      ;  
        LDA.W #$0000                         ;9FF8C5|A90000  |      ;  
        STA.B [$F2],Y                        ;9FF8C8|97F2    |0000F2;  
        INY                                  ;9FF8CA|C8      |      ;  
        INY                                  ;9FF8CB|C8      |      ;  
        LDA.W #$2C22                         ;9FF8CC|A9222C  |      ;   X Letter Pattern Selected??          
		STA.B [$F2],Y                        ;9FF8CF|97F2    |0000F2;  
        PLY                                  ;9FF8D1|7A      |      ;  
        INX                                  ;9FF8D2|E8      |      ;  
        INX                                  ;9FF8D3|E8      |      ;  
        INX                                  ;9FF8D4|E8      |      ;  
        INX                                  ;9FF8D5|E8      |      ;  
	CODE_9FF8D6: 
		PHY                                  ;9FF8D6|5A      |      ;  
        TXY                                  ;9FF8D7|9B      |      ;  
        LDA.W #$0000                         ;9FF8D8|A90000  |      ;  
	CODE_9FF8DB: 
		STA.B [$F2],Y                        ;9FF8DB|97F2    |0000F2;  
        INY                                  ;9FF8DD|C8      |      ;  
        INY                                  ;9FF8DE|C8      |      ;  
        CPY.W #$0040                         ;9FF8DF|C04000  |      ;  
        BNE CODE_9FF8DB                      ;9FF8E2|D0F7    |9FF8DB;  
        PLY                                  ;9FF8E4|7A      |      ;  
        LDA.B $F2                            ;9FF8E5|A5F2    |0000F2;  
        CLC                                  ;9FF8E7|18      |      ;  
        ADC.W #$0040                         ;9FF8E8|694000  |      ;  
        STA.B $F2                            ;9FF8EB|85F2    |0000F2;  
        LDX.W #$0002                         ;9FF8ED|A20200  |      ;  
        INC.B $F6                            ;9FF8F0|E6F6    |0000F6;  
        PLY                                  ;9FF8F2|7A      |      ;  
        INY                                  ;9FF8F3|C8      |      ;  
        INY                                  ;9FF8F4|C8      |      ;  
        JMP.W CODE_9FF826                    ;9FF8F5|4C26F8  |9FF826;  

	GetDataBankRegister_9FF8F8: 
		DEC.B $F6                            ;9FF8F8|C6F6    |0000F6;  
        LDA.B $F6                              
        STA.L $7FFFD6                          
        PLB                                  ;Pull DataBank Register  
        RTS                                    
     
	mainMenuCode: ;      |        |      ;  
        LDA.L $7FFFE0                        ;9FF902|AFE0FF7F|7FFFE0;  
        INC A                                ;9FF906|1A      |      ;  
        INC A                                ;9FF907|1A      |      ;  
        STA.L $7FFFE0                        ;9FF908|8FE0FF7F|7FFFE0;  
        TAX                                  ;9FF90C|AA      |      ;  
        LDA.L $7FFFDA                        ;9FF90D|AFDAFF7F|7FFFDA;  
        STA.L $7FFFE0,X                      ;9FF911|9FE0FF7F|7FFFE0;  
        TYA                                  ;9FF915|98      |      ;  
        STA.L $7FFFDA                        ;9FF916|8FDAFF7F|7FFFDA;  
        JSR.W CODE_9FF765                    ;9FF91A|2065F7  |9FF765;  
        LDA.W #$0000                         ;9FF91D|A90000  |      ;  
        STA.L $7FFFD8                        ;9FF920|8FD8FF7F|7FFFD8;  
        STA.L $7FFFD2                        ;9FF924|8FD2FF7F|7FFFD2;  
        STA.L $7FFFD6                        ;9FF928|8FD6FF7F|7FFFD6;  
        LDA.W #$0001                         ;9FF92C|A90100  |      ;  
        STA.L $7FFFD4                        ;9FF92F|8FD4FF7F|7FFFD4;  
        JSR.W CODE_9FF7F4                    ;9FF933|20F4F7  |9FF7F4;  
        RTS                                  ;9FF936|60      |      ;  
	
	mainMenuList:			;1ff937
		dw $0000,mainMenuCode
		dw levelDisp,textStageSelect
		
		dw $0000,mainMenuCode
		dw subWeaponDisp,textSubweapons
		
		dw $0000,mainMenuCode
		dw multiShotDisp,textMulti
		
		dw $0000,mainMenuCode
		dw whipLevelDisp,textWhip

		dw $0000,doRefill
		dw $0000,textRefill
		
		dw $0000,doSwitchSecondQuest
		dw $0000,textSecondQuest
	
		dw $0000,doSkywalker
		dw $0000,textSkywalker
	
		dw $0000,doNothing
		dw $0000,textExit	
		dw $FFFF
		
	textExit:	
		db "EXIT",$00	
	textSkywalker:	
		db "SKYWALKER-ATTRIBUTE",$00
	textSecondQuest:	
		db "SECOND-QUEST-SWITCH",$00
	textRefill:	
		db "REFILL",$00				;f961
	textSubweapons:
		db "SUBWEAPONS",$00			;f968
	textMulti:
		db "MULTI",$00				;f973
	textWhip:
		db "WHIP",$00				;f979
	textStageSelect:	
		db "STAGE SELECT",$00		;f97e
		
		
	doNothing:
		rts
	
	doSkywalker:
		jsl doSkywalkerL
		rts
	
	doSwitchSecondQuest:
		jsl doSwitchSecondQuestL
		rts
		
	doRefill:
		jsl doRefillL
		RTS                    
     
	subWeaponDisp:			;f99e
		dw $007E,$008E,$0001,textDagger
		dw $007E,$008E,$0002,textAxe
		dw $007E,$008E,$0003,textHoly
		dw $007E,$008E,$0004,textBoomerang
		dw $007E,$008E,$0005,textWatch
		dw $007E,$008E,$0000,textNone
		dw $FFFF	
		
	textDagger:
		db "DAGGER",$00				;f9d0
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
	
	multiShotDisp:
		dw $007E,$0090,$0000,textNone	;$F9F6
		dw $007E,$0090,$0001,textLevel2
		dw $007E,$0090,$0002,textLevel3,$FFFF
	
	textLevel0:		
		db "LEVEL 0",$00		;fa15
	textLevel1:	
		db "LEVEL 1",$00		;fa1d
	textLevel2:
		db "LEVEL 2",$00		;fa25
	textLevel3:
		db "LEVEL 3",$00		;fa2d
	
	;9ffa35
	whipLevelDisp:
		dw $007E,$0092,$0000,textLevel0
		dw $007E,$0092,$0001,textLevel1
		dw $007E,$0092,$0002,textLevel2,$FFFF
	
	;9ffb91	
	levelDisp:	
		dw $0000,goResetRoom,$0000,textReset
		dw $0000,goGetStandartGear,$0000,textCrisSpecial1
		dw $0000,goToSelectedLevel,$0000,textStage1_1_1
		dw $0000,goToSelectedLevel,$0001,textStage1_1_2
		dw $0000,goToSelectedLevel,$0002,textStage1_2_1
		dw $0000,goToSelectedLevel,$0003,textStage1_2_2
		dw $0000,goToSelectedLevel,$0004,textStage1_2_3
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
		dw $0000,goToSelectedLevel,$0024,textStage7_1_2
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
		dw $0000,goToSelectedLevel,$0036,textStage9_2_5
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
		db "1-2-2",$00	
	textStage1_2_3:	
		db "1-2-3",$00
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
		db "3-2-1-RINGGLITCH-1",$00           
	textStage3_3_1:	
		db "3-3-1",$00           
	textStage3_3_2:	
		db "3-3-2",$00		
	textStage3_3_3:	
		db "3-3-3",$00           
	textStage3_3_4:	
		db "3-3-4-RINGGLITCH-2",$00 
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
		db "5-1-1-AMAZONE-AIR-DELEVERY",$00           
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
	textStage7_1_2:	
		db "7-1-2",$00  
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
		db "9-2-1-GLOD-NO-MORE-GHOST",$00           
	textStage9_2_2:	
		db "9-2-2",$00           
	textStage9_2_3:	
		db "9-2-3-SPIKE-JUMP",$00
	textStage9_2_4:	
		db "9-2-4",$00
	textStage9_2_5:	
		db "9-2-5-CHILL",$00		
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
	textCrisSpecial1:	
		db "CRISMAS-SPECIAL",$00 	
		
		
	goToSelectedLevel:
		jsl goToSelectedLevelL
		RTS                                  		 
	
	goToPlaySong: 
		jsl goToPlaySongL
		rts
	goResetRoom:
		jsl goResetRoomL
		RTS
		
	goGetStandartGear:
		jsl goGetStandartGearL
		RTS
	
	
	UNREACH_1FFC8B:			
		dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dw $0000,$0000,$0000
		dw $0CFF,$0CFD,$0CFE,$0CFE,$0C0A,$0CFE,$0CFE,$0CFC,$0CFE,$0CFE
		dw $0CFE,$0CFB,$2026,$0CFA,$0CFE
		dw $2001,$2002,$2003,$2004,$2005
		dw $2006,$2007,$2008,$2009,$200A
		dw $0CFE,$0CFE,$0CFE,$0CFE,$0CFE
		dw $0CFE,$0CFE,$200B,$200C,$200D,$200E,$200F,$2010,$2011,$2012
		dw $2013,$2014,$2015,$2016,$2017,$2018,$2019,$201A,$201B,$201C
		dw $201D,$201E,$201F,$2020,$2021,$2022,$2023,$2024,$2025,$2026,$2027,$2028,$2029
			
			
;		padbyte $ff		;cleanup
;		pad $9FFFFF
			 