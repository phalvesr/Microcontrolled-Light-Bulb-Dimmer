
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;Codigo.c,63 :: 		void interrupt ()
;Codigo.c,66 :: 		if (INTF_bit)                            // Testa se houve interrupção externa
	BTFSS      INTF_bit+0, 1
	GOTO       L_interrupt0
;Codigo.c,68 :: 		T1CON.F0 = 0x01;                        // Habilita a contagem do TMR1
	BSF        T1CON+0, 0
;Codigo.c,69 :: 		INTF_bit = 0x00;                        // Limpa a flag de interrupção externa
	BCF        INTF_bit+0, 1
;Codigo.c,71 :: 		} // end INTF if
L_interrupt0:
;Codigo.c,74 :: 		if (TMR1IF_bit)                          // Testa se houve estouro do TMR1
	BTFSS      TMR1IF_bit+0, 0
	GOTO       L_interrupt1
;Codigo.c,77 :: 		RA1_bit = 0x01;                          // Gera o pulso em High no pino RA1
	BSF        RA1_bit+0, 1
;Codigo.c,78 :: 		delay_us (100);
	MOVLW      166
	MOVWF      R13+0
L_interrupt2:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt2
	NOP
;Codigo.c,79 :: 		RA1_bit = 0x00;
	BCF        RA1_bit+0, 1
;Codigo.c,81 :: 		TMR1H = 0x63;                            // Recarrega para contagem
	MOVLW      99
	MOVWF      TMR1H+0
;Codigo.c,82 :: 		TMR1L = 0xC0;
	MOVLW      192
	MOVWF      TMR1L+0
;Codigo.c,85 :: 		TMR1IF_bit = 0x00;                      // Limpa a flag de overflow TMR1
	BCF        TMR1IF_bit+0, 0
;Codigo.c,86 :: 		} // end TMR1IF if
L_interrupt1:
;Codigo.c,89 :: 		if (TMR0IF_bit)                          // Testa se houve estouro do timer0
	BTFSS      TMR0IF_bit+0, 2
	GOTO       L_interrupt3
;Codigo.c,91 :: 		auxcont0++;                           // Incrementa a variável auxiliar de contagem do TMR0
	INCF       _auxcont0+0, 1
;Codigo.c,93 :: 		if (auxcont0 == 10)                   // Testa se já se passaram 100ms
	MOVF       _auxcont0+0, 0
	XORLW      10
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt4
;Codigo.c,96 :: 		if (!ENTER)                        // Botão enter pressionado? Sim...
	BTFSC      RB3_bit+0, 3
	GOTO       L_interrupt5
;Codigo.c,98 :: 		RETURN = 0x00;                   // Limpa a flag de retorno do menu
	BCF        _flagsA+0, 3
;Codigo.c,99 :: 		GO = 0x01;                       // Seta a flag de entrada do menu
	BSF        _flagsA+0, 2
;Codigo.c,100 :: 		} // end if ENTER
L_interrupt5:
;Codigo.c,102 :: 		if (!BACK)                         // Botão se saida pressionado? Sim...
	BTFSC      RB2_bit+0, 2
	GOTO       L_interrupt6
;Codigo.c,104 :: 		RETURN = 0x01;
	BSF        _flagsA+0, 3
;Codigo.c,105 :: 		GO = 0x00;
	BCF        _flagsA+0, 2
;Codigo.c,106 :: 		} // end if BACK
L_interrupt6:
;Codigo.c,108 :: 		auxcont0 = 0x00;                   // Zera a variável de contagem
	CLRF       _auxcont0+0
;Codigo.c,110 :: 		} // end auxcount0 if
L_interrupt4:
;Codigo.c,111 :: 		TMR0 = 0x3C;                             // Carrega o timer0 com o valor 60 novamente
	MOVLW      60
	MOVWF      TMR0+0
;Codigo.c,112 :: 		TMR0IF_bit = 0x00;                       // Limpa a flag do timer0 após o fim do processamento da interrupção
	BCF        TMR0IF_bit+0, 2
;Codigo.c,113 :: 		} // end TMR0IF if
L_interrupt3:
;Codigo.c,116 :: 		} // end interrupt
L__interrupt59:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;Codigo.c,130 :: 		void main()
;Codigo.c,132 :: 		GO       = 0x00;                         // Inicializa todas as flags limpas...
	BCF        _flagsA+0, 2
;Codigo.c,133 :: 		RETURN   = 0x00;
	BCF        _flagsA+0, 3
;Codigo.c,134 :: 		inc      = 0x00;
	BCF        _flagsA+0, 0
;Codigo.c,135 :: 		dec      = 0x00;
	BCF        _flagsA+0, 1
;Codigo.c,136 :: 		ClearLCD = 0x00;
	BCF        _flagsA+0, 4
;Codigo.c,138 :: 		registradores ();                        // Faz chamada da função que configura os registradores
	CALL       _registradores+0
;Codigo.c,140 :: 		Lcd_Init();                              // Inicia o display LCD
	CALL       _Lcd_Init+0
;Codigo.c,141 :: 		Lcd_Cmd (_LCD_CLEAR);                    // Limpa o display LCD
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;Codigo.c,142 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);                // Desliga o cursor do display LCD
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;Codigo.c,143 :: 		Lcd_Out (1, 6,"Dimmer");                 // Imprime mensagem de inicialização no display LCD
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      6
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr1_Codigo+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;Codigo.c,144 :: 		Lcd_Out (2, 2,"Microcontrolado");        // (Mensagem generica)
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr2_Codigo+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;Codigo.c,146 :: 		delay_ms (1000);                         // Aguarda 1 segundo com a mensagem na tela
	MOVLW      26
	MOVWF      R11+0
	MOVLW      94
	MOVWF      R12+0
	MOVLW      110
	MOVWF      R13+0
L_main7:
	DECFSZ     R13+0, 1
	GOTO       L_main7
	DECFSZ     R12+0, 1
	GOTO       L_main7
	DECFSZ     R11+0, 1
	GOTO       L_main7
	NOP
;Codigo.c,147 :: 		Lcd_Cmd (_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;Codigo.c,149 :: 		while (1)
L_main8:
;Codigo.c,151 :: 		testabotoes();                        // Chama a função que testa os botões de incremento e decremento
	CALL       _testabotoes+0
;Codigo.c,153 :: 		switch (sel)                          // Entra no menu de funcionalidades do dimmer
	GOTO       L_main10
;Codigo.c,155 :: 		case 0x01:
L_main12:
;Codigo.c,157 :: 		if (ClearLCD)
	BTFSS      _flagsA+0, 4
	GOTO       L_main13
;Codigo.c,159 :: 		LCD_Cmd (_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;Codigo.c,160 :: 		ClearLCD = 0x00;
	BCF        _flagsA+0, 4
;Codigo.c,161 :: 		} // end if Clear LCD
L_main13:
;Codigo.c,163 :: 		Lcd_Chr (1,1, '<');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      60
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,164 :: 		Lcd_Chr (1,16, '>');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      16
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      62
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,165 :: 		Lcd_Chr (1,3, 'C');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      3
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      67
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,166 :: 		Lcd_Chr_Cp ('o');
	MOVLW      111
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,167 :: 		Lcd_Chr_Cp ('n');
	MOVLW      110
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,168 :: 		Lcd_Chr_Cp ('t');
	MOVLW      116
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,169 :: 		Lcd_Chr_Cp ('r');
	MOVLW      114
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,170 :: 		Lcd_Chr_Cp ('o');
	MOVLW      111
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,171 :: 		Lcd_Chr_Cp ('l');
	MOVLW      108
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,172 :: 		Lcd_Chr_Cp ('e');
	MOVLW      101
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,174 :: 		Lcd_Out (2,1, "                ");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr3_Codigo+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;Codigo.c,176 :: 		controlight ();
	CALL       _controlight+0
;Codigo.c,177 :: 		break;
	GOTO       L_main11
;Codigo.c,179 :: 		case 0x02:
L_main14:
;Codigo.c,181 :: 		if (ClearLCD)
	BTFSS      _flagsA+0, 4
	GOTO       L_main15
;Codigo.c,183 :: 		LCD_Cmd (_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;Codigo.c,184 :: 		ClearLCD = 0x00;
	BCF        _flagsA+0, 4
;Codigo.c,185 :: 		} // end if Clear LCD
L_main15:
;Codigo.c,187 :: 		Lcd_Chr (1,1, '<');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      60
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,188 :: 		Lcd_Chr (1,16, '>');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      16
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      62
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,189 :: 		Lcd_Chr (1,3, 'F');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      3
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      70
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,190 :: 		Lcd_Chr_Cp ('a');
	MOVLW      97
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,191 :: 		Lcd_Chr_Cp ('d');
	MOVLW      100
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,192 :: 		Lcd_Chr_Cp ('e');
	MOVLW      101
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,198 :: 		Lcd_Out (2,1, "                ");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr4_Codigo+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;Codigo.c,200 :: 		fade ();
	CALL       _fade+0
;Codigo.c,201 :: 		break;
	GOTO       L_main11
;Codigo.c,203 :: 		case 0x03:
L_main16:
;Codigo.c,205 :: 		if (ClearLCD)
	BTFSS      _flagsA+0, 4
	GOTO       L_main17
;Codigo.c,207 :: 		LCD_Cmd (_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;Codigo.c,208 :: 		ClearLCD = 0x00;
	BCF        _flagsA+0, 4
;Codigo.c,209 :: 		} // end if Clear LCD
L_main17:
;Codigo.c,211 :: 		Lcd_Chr (1,1, '<');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      60
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,212 :: 		Lcd_Chr (1,16, '>');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      16
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      62
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,213 :: 		Lcd_Chr (1,3, 'F');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      3
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      70
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,214 :: 		Lcd_Chr_Cp ('l');
	MOVLW      108
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,215 :: 		Lcd_Chr_Cp ('a');
	MOVLW      97
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,216 :: 		Lcd_Chr_Cp ('s');
	MOVLW      115
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,217 :: 		Lcd_Chr_Cp ('h');
	MOVLW      104
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,223 :: 		Lcd_Out (2,1, "                ");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr5_Codigo+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;Codigo.c,225 :: 		flash ();
	CALL       _flash+0
;Codigo.c,226 :: 		break;
	GOTO       L_main11
;Codigo.c,228 :: 		case 0x04:
L_main18:
;Codigo.c,230 :: 		if (ClearLCD)
	BTFSS      _flagsA+0, 4
	GOTO       L_main19
;Codigo.c,232 :: 		LCD_Cmd (_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;Codigo.c,233 :: 		ClearLCD = 0x00;
	BCF        _flagsA+0, 4
;Codigo.c,234 :: 		} // end if Clear LCD
L_main19:
;Codigo.c,236 :: 		Lcd_Chr (1,1, '<');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      60
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,237 :: 		Lcd_Chr (1,16, '>');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      16
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      62
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,238 :: 		Lcd_Chr (1,3, 'T');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      3
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      84
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,239 :: 		Lcd_Chr_Cp ('i');
	MOVLW      105
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,240 :: 		Lcd_Chr_Cp ('m');
	MOVLW      109
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,241 :: 		Lcd_Chr_Cp ('e');
	MOVLW      101
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,242 :: 		Lcd_Chr_Cp ('r');
	MOVLW      114
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,248 :: 		Lcd_Out (2,1, "                ");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr6_Codigo+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;Codigo.c,250 :: 		timer ();
	CALL       _timer+0
;Codigo.c,251 :: 		break;
	GOTO       L_main11
;Codigo.c,253 :: 		case 0x05:
L_main20:
;Codigo.c,255 :: 		if (ClearLCD)
	BTFSS      _flagsA+0, 4
	GOTO       L_main21
;Codigo.c,257 :: 		LCD_Cmd (_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;Codigo.c,258 :: 		ClearLCD = 0x00;
	BCF        _flagsA+0, 4
;Codigo.c,259 :: 		} // end if Clear LCD
L_main21:
;Codigo.c,261 :: 		Lcd_Chr (1,1, '<');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      60
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,262 :: 		Lcd_Chr (1,16, '>');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      16
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      62
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,263 :: 		Lcd_Chr (1,3, 'S');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      3
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      83
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,264 :: 		Lcd_Chr_Cp ('i');
	MOVLW      105
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,265 :: 		Lcd_Chr_Cp ('n');
	MOVLW      110
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,266 :: 		Lcd_Chr_Cp ('c');
	MOVLW      99
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,272 :: 		Lcd_Out (2,1, "                ");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr7_Codigo+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;Codigo.c,274 :: 		sinc ();
	CALL       _sinc+0
;Codigo.c,275 :: 		break;
	GOTO       L_main11
;Codigo.c,277 :: 		} // end switch case sel
L_main10:
	MOVF       _sel+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_main12
	MOVF       _sel+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_main14
	MOVF       _sel+0, 0
	XORLW      3
	BTFSC      STATUS+0, 2
	GOTO       L_main16
	MOVF       _sel+0, 0
	XORLW      4
	BTFSC      STATUS+0, 2
	GOTO       L_main18
	MOVF       _sel+0, 0
	XORLW      5
	BTFSC      STATUS+0, 2
	GOTO       L_main20
L_main11:
;Codigo.c,279 :: 		} // end while
	GOTO       L_main8
;Codigo.c,280 :: 		} // end main
	GOTO       $+0
; end of _main

_registradores:

;Codigo.c,284 :: 		void registradores ()
;Codigo.c,288 :: 		INTCON = 0xF0;     // 1111 0000
	MOVLW      240
	MOVWF      INTCON+0
;Codigo.c,298 :: 		OPTION_REG = 0x87; // 1000 0111
	MOVLW      135
	MOVWF      OPTION_REG+0
;Codigo.c,306 :: 		T1CON = 0x00;      // 0000 0000
	CLRF       T1CON+0
;Codigo.c,314 :: 		PIE1 = PIE1 | 0x01;// 0000 0001
	BSF        PIE1+0, 0
;Codigo.c,317 :: 		PIR1 = PIR1 & 0xFE;// 1111 1110
	MOVLW      254
	ANDWF      PIR1+0, 1
;Codigo.c,320 :: 		TMR1H = 0x63;      // Configura o TMR1 para contagem do periodo desligado
	MOVLW      99
	MOVWF      TMR1H+0
;Codigo.c,321 :: 		TMR1L = 0xC0;
	MOVLW      192
	MOVWF      TMR1L+0
;Codigo.c,324 :: 		CMCON = 0x07;      // Desabilita os comparadores
	MOVLW      7
	MOVWF      CMCON+0
;Codigo.c,325 :: 		CVREN_bit = 0;
	BCF        CVREN_bit+0, 7
;Codigo.c,326 :: 		CVROE_bit = 0;
	BCF        CVROE_bit+0, 6
;Codigo.c,328 :: 		TMR0 = 0x3C;       // Carrega o timer0 com o valor 60 inicialmente
	MOVLW      60
	MOVWF      TMR0+0
;Codigo.c,330 :: 		ADON_bit = 0x00;   // Desabilita o modulo de conversão AD
	BCF        ADON_bit+0, 0
;Codigo.c,331 :: 		ADCON1 = 0x0F;     // Configura os pinos do PORTA como digitais
	MOVLW      15
	MOVWF      ADCON1+0
;Codigo.c,333 :: 		TRISA = 0b11111101;
	MOVLW      253
	MOVWF      TRISA+0
;Codigo.c,334 :: 		TRISB = 0b11111101;
	MOVLW      253
	MOVWF      TRISB+0
;Codigo.c,335 :: 		TRISC = 0xF0;      // 1111 0000
	MOVLW      240
	MOVWF      TRISC+0
;Codigo.c,338 :: 		PORTA = 0x00;      // Inicia o PORTB em LOW
	CLRF       PORTA+0
;Codigo.c,339 :: 		PORTB = 0xFF;      // Inicia o PORTB em HIGH
	MOVLW      255
	MOVWF      PORTB+0
;Codigo.c,340 :: 		PORTC = 0x00;      // Inicia o PORTC em LOW
	CLRF       PORTC+0
;Codigo.c,345 :: 		} // end registradores
	RETURN
; end of _registradores

_testabotoes:

;Codigo.c,347 :: 		void testabotoes ()
;Codigo.c,349 :: 		if (!butinc)        inc = 0x01;     // Se botão de mais pressionado, seta a flag inc
	BTFSC      RB7_bit+0, 7
	GOTO       L_testabotoes22
	BSF        _flagsA+0, 0
L_testabotoes22:
;Codigo.c,350 :: 		if (!butdec)        dec = 0x01;     // Se botão de menos pressionado, seta a flag dec
	BTFSC      RB6_bit+0, 6
	GOTO       L_testabotoes23
	BSF        _flagsA+0, 1
L_testabotoes23:
;Codigo.c,352 :: 		if (butinc && inc)                  // Botão+ solto e flag inc setada? Sim...
	BTFSS      RB7_bit+0, 7
	GOTO       L_testabotoes26
	BTFSS      _flagsA+0, 0
	GOTO       L_testabotoes26
L__testabotoes53:
;Codigo.c,354 :: 		inc = 0x00;                 // Limpa a flag
	BCF        _flagsA+0, 0
;Codigo.c,355 :: 		sel++;                      // Incrementa a seleção de menus
	INCF       _sel+0, 1
;Codigo.c,356 :: 		ClearLCD = 0x01;
	BSF        _flagsA+0, 4
;Codigo.c,357 :: 		} // end but+ && inc
L_testabotoes26:
;Codigo.c,359 :: 		if (butdec && dec)                  // Botão- solto e flag dec setada? Sim...
	BTFSS      RB6_bit+0, 6
	GOTO       L_testabotoes29
	BTFSS      _flagsA+0, 1
	GOTO       L_testabotoes29
L__testabotoes52:
;Codigo.c,361 :: 		dec = 0x00;                 // Limpa a flag
	BCF        _flagsA+0, 1
;Codigo.c,362 :: 		sel--;                      // Decrementa a seleção de menus
	DECF       _sel+0, 1
;Codigo.c,363 :: 		ClearLCD = 0x01;
	BSF        _flagsA+0, 4
;Codigo.c,364 :: 		} // end if but- && dec
L_testabotoes29:
;Codigo.c,366 :: 		if (sel > nmenus)        sel = 0x01;
	MOVF       _sel+0, 0
	SUBLW      5
	BTFSC      STATUS+0, 0
	GOTO       L_testabotoes30
	MOVLW      1
	MOVWF      _sel+0
L_testabotoes30:
;Codigo.c,367 :: 		if (sel < 0x01)          sel = nmenus;
	MOVLW      1
	SUBWF      _sel+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_testabotoes31
	MOVLW      5
	MOVWF      _sel+0
L_testabotoes31:
;Codigo.c,369 :: 		} // end testabotoes
	RETURN
; end of _testabotoes

_controlight:

;Codigo.c,371 :: 		void controlight ()
;Codigo.c,373 :: 		while (GO && !RETURN   )
L_controlight32:
	BTFSS      _flagsA+0, 2
	GOTO       L_controlight33
	BTFSC      _flagsA+0, 3
	GOTO       L_controlight33
L__controlight54:
;Codigo.c,376 :: 		Lcd_Chr (1,1, ' ');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,377 :: 		Lcd_Chr (1,16, ' ');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      16
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,378 :: 		Lcd_Chr (1,3, 'C');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      3
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      67
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,379 :: 		Lcd_Chr_Cp ('o');
	MOVLW      111
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,380 :: 		Lcd_Chr_Cp ('n');
	MOVLW      110
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,381 :: 		Lcd_Chr_Cp ('t');
	MOVLW      116
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,382 :: 		Lcd_Chr_Cp ('r');
	MOVLW      114
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,383 :: 		Lcd_Chr_Cp ('o');
	MOVLW      111
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,384 :: 		Lcd_Chr_Cp ('l');
	MOVLW      108
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,385 :: 		Lcd_Chr_Cp ('e');
	MOVLW      101
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,386 :: 		Lcd_Chr_Cp (':');
	MOVLW      58
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,387 :: 		Lcd_Chr (2,1, '1');
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      49
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,388 :: 		} // end while
	GOTO       L_controlight32
L_controlight33:
;Codigo.c,389 :: 		} // end controlight
	RETURN
; end of _controlight

_fade:

;Codigo.c,391 :: 		void fade ()
;Codigo.c,393 :: 		while (GO && !RETURN)
L_fade36:
	BTFSS      _flagsA+0, 2
	GOTO       L_fade37
	BTFSC      _flagsA+0, 3
	GOTO       L_fade37
L__fade55:
;Codigo.c,396 :: 		Lcd_Chr (1,1, ' ');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,397 :: 		Lcd_Chr (1,16, ' ');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      16
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,398 :: 		Lcd_Chr (1,3, 'F');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      3
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      70
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,399 :: 		Lcd_Chr_Cp ('a');
	MOVLW      97
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,400 :: 		Lcd_Chr_Cp ('d');
	MOVLW      100
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,401 :: 		Lcd_Chr_Cp ('e');
	MOVLW      101
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,402 :: 		Lcd_Chr_Cp (':');
	MOVLW      58
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,403 :: 		Lcd_Chr_Cp (' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,404 :: 		Lcd_Chr_Cp (' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,405 :: 		Lcd_Chr_Cp (' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,406 :: 		Lcd_Chr_Cp (' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,407 :: 		Lcd_Chr (2,1, '2');
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      50
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,408 :: 		} // end while
	GOTO       L_fade36
L_fade37:
;Codigo.c,409 :: 		} // end fade
	RETURN
; end of _fade

_flash:

;Codigo.c,411 :: 		void flash ()
;Codigo.c,413 :: 		while (GO && !RETURN)
L_flash40:
	BTFSS      _flagsA+0, 2
	GOTO       L_flash41
	BTFSC      _flagsA+0, 3
	GOTO       L_flash41
L__flash56:
;Codigo.c,416 :: 		Lcd_Chr (1,1, ' ');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,417 :: 		Lcd_Chr (1,16, ' ');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      16
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,418 :: 		Lcd_Chr (1,3, 'F');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      3
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      70
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,419 :: 		Lcd_Chr_Cp ('l');
	MOVLW      108
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,420 :: 		Lcd_Chr_Cp ('a');
	MOVLW      97
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,421 :: 		Lcd_Chr_Cp ('s');
	MOVLW      115
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,422 :: 		Lcd_Chr_Cp ('h');
	MOVLW      104
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,423 :: 		Lcd_Chr_Cp (':');
	MOVLW      58
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,424 :: 		Lcd_Chr_Cp (' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,425 :: 		Lcd_Chr_Cp (' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,426 :: 		Lcd_Chr_Cp (' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,427 :: 		Lcd_Chr_Cp (' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,428 :: 		Lcd_Chr (2,1, '3');
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      51
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,429 :: 		} // end while
	GOTO       L_flash40
L_flash41:
;Codigo.c,430 :: 		} // end flash
	RETURN
; end of _flash

_timer:

;Codigo.c,432 :: 		void timer ()
;Codigo.c,434 :: 		while (GO && !RETURN)
L_timer44:
	BTFSS      _flagsA+0, 2
	GOTO       L_timer45
	BTFSC      _flagsA+0, 3
	GOTO       L_timer45
L__timer57:
;Codigo.c,436 :: 		Lcd_Chr (1,1, ' ');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,437 :: 		Lcd_Chr (1,16, ' ');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      16
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,438 :: 		Lcd_Chr (1,3, 'T');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      3
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      84
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,439 :: 		Lcd_Chr_Cp ('i');
	MOVLW      105
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,440 :: 		Lcd_Chr_Cp ('m');
	MOVLW      109
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,441 :: 		Lcd_Chr_Cp ('e');
	MOVLW      101
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,442 :: 		Lcd_Chr_Cp ('r');
	MOVLW      114
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,443 :: 		Lcd_Chr_Cp (':');
	MOVLW      58
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,444 :: 		Lcd_Chr_Cp (' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,445 :: 		Lcd_Chr_Cp (' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,446 :: 		Lcd_Chr_Cp (' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,447 :: 		Lcd_Chr_Cp (' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,448 :: 		Lcd_Chr (2,1, '4');
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      52
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,449 :: 		} // end while
	GOTO       L_timer44
L_timer45:
;Codigo.c,450 :: 		} // end timer
	RETURN
; end of _timer

_sinc:

;Codigo.c,452 :: 		void sinc ()
;Codigo.c,454 :: 		while (GO && !RETURN)
L_sinc48:
	BTFSS      _flagsA+0, 2
	GOTO       L_sinc49
	BTFSC      _flagsA+0, 3
	GOTO       L_sinc49
L__sinc58:
;Codigo.c,456 :: 		Lcd_Chr (1,1, ' ');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,457 :: 		Lcd_Chr (1,16, ' ');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      16
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,458 :: 		Lcd_Chr (1,3, 'S');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      3
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      83
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,459 :: 		Lcd_Chr_Cp ('i');
	MOVLW      105
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,460 :: 		Lcd_Chr_Cp ('n');
	MOVLW      110
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,461 :: 		Lcd_Chr_Cp ('c');
	MOVLW      99
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,462 :: 		Lcd_Chr_Cp (':');
	MOVLW      58
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,463 :: 		Lcd_Chr_Cp (' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,464 :: 		Lcd_Chr_Cp (' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,465 :: 		Lcd_Chr_Cp (' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,466 :: 		Lcd_Chr_Cp (' ');
	MOVLW      32
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Codigo.c,467 :: 		Lcd_Chr (2,1, '5');
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      53
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;Codigo.c,468 :: 		} // end while
	GOTO       L_sinc48
L_sinc49:
;Codigo.c,469 :: 		} // end sinc
	RETURN
; end of _sinc
