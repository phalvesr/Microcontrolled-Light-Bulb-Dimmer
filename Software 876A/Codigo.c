/*

  ### Dimmer microcontrolado com PIC ###

  uC: PIC 16f876A
  Ciclo de m�quina: 200ns
  Plataforma de desenvolvimento do software: MikroC PRO for PIC v.4.15.0.0

  Data de inicio: 12 Outubro de 2019
  �ltima atualiza��o: 28 Outubro de 2019

  OBS: N�o � recomendado fazer a chamada de uma fun��o dentro da pilha de
  interrup��o.

  OBS2: RA1 esta sendo usado como pino de debug (sa�da), no futuro mud�-lo para input.
  
  OBS3: O tempo de estouro do TMR1 deve ser calibrado de forma impirica

*/

// ############################################################################
// --- Mapeamento do Display LCD ---
// LCD module connections
sbit LCD_RS at RC2_bit;
sbit LCD_EN at RC3_bit;
sbit LCD_D7 at RC7_bit;
sbit LCD_D6 at RC6_bit;
sbit LCD_D5 at RC5_bit;
sbit LCD_D4 at RC4_bit;

// Pin direction
sbit LCD_RS_Direction at TRISC2_bit;
sbit LCD_EN_Direction at TRISC3_bit;
sbit LCD_D7_Direction at TRISC7_bit;
sbit LCD_D6_Direction at TRISC6_bit;
sbit LCD_D5_Direction at TRISC5_bit;
sbit LCD_D4_Direction at TRISC4_bit;

// ############################################################################
// --- Mapeamento de Hardware ---
#define nmenus   5
#define inc      flagsA.B0
#define dec      flagsA.B1
#define GO       flagsA.B2
#define RETURN   flagsA.B3
#define ClearLCD flagsA.B4
#define butinc   RB7_bit
#define butdec   RB6_bit
#define ON       RB5_bit
#define OFF      RB4_bit
#define ENTER    RB3_bit
#define BACK     RB2_bit
#define triac    RB1_bit

// ############################################################################
// --- Vari�veis Globais ---
char auxcont0 = 0x00,
     sel = 0x01,
     flagsA;

// ############################################################################
// --- Vetor de Interrup��o ---
void interrupt ()
{
     // --- Interrup��o externa ---
     if (INTF_bit)                            // Testa se houve interrup��o externa
     {
      T1CON.F0 = 0x01;                        // Habilita a contagem do TMR1
      INTF_bit = 0x00;                        // Limpa a flag de interrup��o externa

     } // end INTF if
     
     // --- Timer 1 ---
     if (TMR1IF_bit)                          // Testa se houve estouro do TMR1
     {

     RA1_bit = 0x01;                          // Gera o pulso em High no pino RA1
     delay_us (100);
     RA1_bit = 0x00;
      
     TMR1H = 0x63;                            // Recarrega para contagem
     TMR1L = 0xC0;


      TMR1IF_bit = 0x00;                      // Limpa a flag de overflow TMR1
     } // end TMR1IF if

     // --- Timer 0 ---
     if (TMR0IF_bit)                          // Testa se houve estouro do timer0
     {
        auxcont0++;                           // Incrementa a vari�vel auxiliar de contagem do TMR0

        if (auxcont0 == 10)                   // Testa se j� se passaram 100ms
        {

           if (!ENTER)                        // Bot�o enter pressionado? Sim...
           {
             RETURN = 0x00;                   // Limpa a flag de retorno do menu
             GO = 0x01;                       // Seta a flag de entrada do menu
           } // end if ENTER

           if (!BACK)                         // Bot�o se saida pressionado? Sim...
           {
            RETURN = 0x01;
            GO = 0x00;
           } // end if BACK
           
           auxcont0 = 0x00;                   // Zera a vari�vel de contagem
           
        } // end auxcount0 if
     TMR0 = 0x3C;                             // Carrega o timer0 com o valor 60 novamente
     TMR0IF_bit = 0x00;                       // Limpa a flag do timer0 ap�s o fim do processamento da interrup��o
     } // end TMR0IF if


} // end interrupt

// ############################################################################
// --- Declara��o de Fun��es Auxiliares ---
void registradores ();                        // Fun��o que configurar� os regitradores
void testabotoes ();                          // Fun��o que testa os botoes
void controlight ();                          // Fun��o que controla a luminosidade
void fade ();                                 // Fun��o respons�vel pelo fade
void flash ();                                // Fun��o respons�vel pelo flash
void timer ();                                // Fun��o respons�vel pelo timer
void sinc ();                                 // Fun��o respons�vel pelo sincronia com musica (Extra!!)

// ############################################################################
// --- Fun��o Principal ---
void main()
{
     GO       = 0x00;                         // Inicializa todas as flags limpas...
     RETURN   = 0x00;
     inc      = 0x00;
     dec      = 0x00;
     ClearLCD = 0x00;

     registradores ();                        // Faz chamada da fun��o que configura os registradores

     Lcd_Init();                              // Inicia o display LCD
     Lcd_Cmd (_LCD_CLEAR);                    // Limpa o display LCD
     Lcd_Cmd(_LCD_CURSOR_OFF);                // Desliga o cursor do display LCD
     Lcd_Out (1, 6,"Dimmer");                 // Imprime mensagem de inicializa��o no display LCD
     Lcd_Out (2, 2,"Microcontrolado");        // (Mensagem generica)

     delay_ms (1000);                         // Aguarda 1 segundo com a mensagem na tela
     Lcd_Cmd (_LCD_CLEAR);

     while (1)
    {
        testabotoes();                        // Chama a fun��o que testa os bot�es de incremento e decremento

        switch (sel)                          // Entra no menu de funcionalidades do dimmer
        {
         case 0x01:

              if (ClearLCD)
              {
                 LCD_Cmd (_LCD_CLEAR);
                 ClearLCD = 0x00;
              } // end if Clear LCD

              Lcd_Chr (1,1, '<');
              Lcd_Chr (1,16, '>');
              Lcd_Chr (1,3, 'C');
              Lcd_Chr_Cp ('o');
              Lcd_Chr_Cp ('n');
              Lcd_Chr_Cp ('t');
              Lcd_Chr_Cp ('r');
              Lcd_Chr_Cp ('o');
              Lcd_Chr_Cp ('l');
              Lcd_Chr_Cp ('e');
              //Lcd_Chr_Cp (' ');
              Lcd_Out (2,1, "                ");

              controlight ();
              break;

         case 0x02:

              if (ClearLCD)
              {
                 LCD_Cmd (_LCD_CLEAR);
                 ClearLCD = 0x00;
              } // end if Clear LCD

              Lcd_Chr (1,1, '<');
              Lcd_Chr (1,16, '>');
              Lcd_Chr (1,3, 'F');
              Lcd_Chr_Cp ('a');
              Lcd_Chr_Cp ('d');
              Lcd_Chr_Cp ('e');
              //Lcd_Chr_Cp (' ');
              //Lcd_Chr_Cp (' ');
              //Lcd_Chr_Cp (' ');
              //Lcd_Chr_Cp (' ');
              //Lcd_Chr_Cp (' ');
              Lcd_Out (2,1, "                ");

              fade ();
              break;

         case 0x03:

              if (ClearLCD)
              {
                 LCD_Cmd (_LCD_CLEAR);
                 ClearLCD = 0x00;
              } // end if Clear LCD

              Lcd_Chr (1,1, '<');
              Lcd_Chr (1,16, '>');
              Lcd_Chr (1,3, 'F');
              Lcd_Chr_Cp ('l');
              Lcd_Chr_Cp ('a');
              Lcd_Chr_Cp ('s');
              Lcd_Chr_Cp ('h');
              //Lcd_Chr_Cp (' ');
              //Lcd_Chr_Cp (' ');
              //Lcd_Chr_Cp (' ');
              //Lcd_Chr_Cp (' ');
              //Lcd_Chr_Cp (' ');
              Lcd_Out (2,1, "                ");

              flash ();
              break;

         case 0x04:

              if (ClearLCD)
              {
                 LCD_Cmd (_LCD_CLEAR);
                 ClearLCD = 0x00;
              } // end if Clear LCD

              Lcd_Chr (1,1, '<');
              Lcd_Chr (1,16, '>');
              Lcd_Chr (1,3, 'T');
              Lcd_Chr_Cp ('i');
              Lcd_Chr_Cp ('m');
              Lcd_Chr_Cp ('e');
              Lcd_Chr_Cp ('r');
              //Lcd_Chr_Cp (' ');
              //Lcd_Chr_Cp (' ');
              //Lcd_Chr_Cp (' ');
              //Lcd_Chr_Cp (' ');
              //Lcd_Chr_Cp (' ');
              Lcd_Out (2,1, "                ");

              timer ();
              break;

         case 0x05:

              if (ClearLCD)
              {
                 LCD_Cmd (_LCD_CLEAR);
                 ClearLCD = 0x00;
              } // end if Clear LCD

              Lcd_Chr (1,1, '<');
              Lcd_Chr (1,16, '>');
              Lcd_Chr (1,3, 'S');
              Lcd_Chr_Cp ('i');
              Lcd_Chr_Cp ('n');
              Lcd_Chr_Cp ('c');
              //Lcd_Chr_Cp (' ');
              //Lcd_Chr_Cp (' ');
              //Lcd_Chr_Cp (' ');
              //Lcd_Chr_Cp (' ');
              //Lcd_Chr_Cp (' ');
              Lcd_Out (2,1, "                ");

              sinc ();
              break;

        } // end switch case sel

    } // end while
  } // end main

// ############################################################################
// --- Desenvolvimento de Fun��es Auxiliares ---
void registradores ()
{

// --- Configura��o TMR0 e External Interrupt ---
     INTCON = 0xF0;     // 1111 0000
                        // Habilita as interrup��es globais para configura��o (INTCON.F7)
                        // Habilita as interrup��es por perif�ricos (INTCON.F6)
                        // Habilita interrup��o do timer 0 (INTCON.F5)
                        // Habilita interrup��o externa no pino RB0 (INTCON.F4)
                        // Desabilita interru��o por mudan�a do PORTB (INTCON.F3)
                        // Limpa a flag de interrup��o do Timer0 (INTCON.F2)
                        // Limpa a flag de interrup��o externa (INTCON.F1)
                        // Limpa a flag de mudan�a do PORTB (INTCON.F0)

     OPTION_REG = 0x87; // 1000 0111
                        // Desabilita os PULLUPS do PORTB (OPTION_REG.F7)
                        // Habilita interrup��o Externa por borda de subida (OPTION_REG.F6)
                        // Associa o clock do timer0 ao ciclo de m�quina (OPTION_REG.F5)
                        // Associa o preescaler ao timer0 (OPTION_REG.F3)
                        // Configura o preescaler em 1:256 (OPTION_REG <F2:F0>)

// --- Configura��o TMR1 ---
     T1CON = 0x00;      // 0000 0000
                        // N�o s�o implementados (T1CON <F7:F6>)
                        // Habilita o prescale em 1:1 (T1CON <F5:F4>)
                        // Desabilita o oscilador do TMR1 (T1CON.F3)
                        // Bit de controle de sincronia do TMR1, don't care pois T1CON.F1 � setado (T1CON.F2)
                        // Config. o incremento do TMR pelo ciclo de m�quina (T1CON.F1)
                        // Inicia o TMR1 desligado, deve ser ligado ap�s interrup��o externa (T1CON.F0)
                        
     PIE1 = PIE1 | 0x01;// 0000 0001
                        // Habilita a interrup��o do TMR1 por overflow
                        
     PIR1 = PIR1 & 0xFE;// 1111 1110
                        // Limpa a flag de overflow do TMR1 (garantia!)

     TMR1H = 0x63;      // Configura o TMR1 para contagem do periodo desligado
     TMR1L = 0xC0;
     
// --- Configura��o dos demais perif�ricos ----
     CMCON = 0x07;      // Desabilita os comparadores
     CVREN_bit = 0;
     CVROE_bit = 0;

     TMR0 = 0x3C;       // Carrega o timer0 com o valor 60 inicialmente

     ADON_bit = 0x00;   // Desabilita o modulo de convers�o AD
     ADCON1 = 0x0F;     // Configura os pinos do PORTA como digitais

     TRISA = 0b11111101;
     TRISB = 0b11111101;
     TRISC = 0xF0;      // 1111 0000


     PORTA = 0x00;      // Inicia o PORTB em LOW
     PORTB = 0xFF;      // Inicia o PORTB em HIGH
     PORTC = 0x00;      // Inicia o PORTC em LOW


     //PORTD = 0x00;      // Configura o PORTD em LOW

} // end registradores

void testabotoes ()
{
        if (!butinc)        inc = 0x01;     // Se bot�o de mais pressionado, seta a flag inc
        if (!butdec)        dec = 0x01;     // Se bot�o de menos pressionado, seta a flag dec

        if (butinc && inc)                  // Bot�o+ solto e flag inc setada? Sim...
        {
                inc = 0x00;                 // Limpa a flag
                sel++;                      // Incrementa a sele��o de menus
                ClearLCD = 0x01;
        } // end but+ && inc

        if (butdec && dec)                  // Bot�o- solto e flag dec setada? Sim...
        {
                dec = 0x00;                 // Limpa a flag
                sel--;                      // Decrementa a sele��o de menus
                ClearLCD = 0x01;
        } // end if but- && dec

        if (sel > nmenus)        sel = 0x01;
        if (sel < 0x01)          sel = nmenus;

} // end testabotoes

void controlight ()
{
              while (GO && !RETURN   )
              {

              Lcd_Chr (1,1, ' ');
              Lcd_Chr (1,16, ' ');
              Lcd_Chr (1,3, 'C');
              Lcd_Chr_Cp ('o');
              Lcd_Chr_Cp ('n');
              Lcd_Chr_Cp ('t');
              Lcd_Chr_Cp ('r');
              Lcd_Chr_Cp ('o');
              Lcd_Chr_Cp ('l');
              Lcd_Chr_Cp ('e');
              Lcd_Chr_Cp (':');
              Lcd_Chr (2,1, '1');
              } // end while
} // end controlight

void fade ()
{
              while (GO && !RETURN)
              {

              Lcd_Chr (1,1, ' ');
              Lcd_Chr (1,16, ' ');
              Lcd_Chr (1,3, 'F');
              Lcd_Chr_Cp ('a');
              Lcd_Chr_Cp ('d');
              Lcd_Chr_Cp ('e');
              Lcd_Chr_Cp (':');
              Lcd_Chr_Cp (' ');
              Lcd_Chr_Cp (' ');
              Lcd_Chr_Cp (' ');
              Lcd_Chr_Cp (' ');
              Lcd_Chr (2,1, '2');
              } // end while
} // end fade

void flash ()
{
              while (GO && !RETURN)
              {

              Lcd_Chr (1,1, ' ');
              Lcd_Chr (1,16, ' ');
              Lcd_Chr (1,3, 'F');
              Lcd_Chr_Cp ('l');
              Lcd_Chr_Cp ('a');
              Lcd_Chr_Cp ('s');
              Lcd_Chr_Cp ('h');
              Lcd_Chr_Cp (':');
              Lcd_Chr_Cp (' ');
              Lcd_Chr_Cp (' ');
              Lcd_Chr_Cp (' ');
              Lcd_Chr_Cp (' ');
              Lcd_Chr (2,1, '3');
              } // end while
} // end flash

void timer ()
{
              while (GO && !RETURN)
              {
              Lcd_Chr (1,1, ' ');
              Lcd_Chr (1,16, ' ');
              Lcd_Chr (1,3, 'T');
              Lcd_Chr_Cp ('i');
              Lcd_Chr_Cp ('m');
              Lcd_Chr_Cp ('e');
              Lcd_Chr_Cp ('r');
              Lcd_Chr_Cp (':');
              Lcd_Chr_Cp (' ');
              Lcd_Chr_Cp (' ');
              Lcd_Chr_Cp (' ');
              Lcd_Chr_Cp (' ');
              Lcd_Chr (2,1, '4');
              } // end while
} // end timer

void sinc ()
{
              while (GO && !RETURN)
              {
              Lcd_Chr (1,1, ' ');
              Lcd_Chr (1,16, ' ');
              Lcd_Chr (1,3, 'S');
              Lcd_Chr_Cp ('i');
              Lcd_Chr_Cp ('n');
              Lcd_Chr_Cp ('c');
              Lcd_Chr_Cp (':');
              Lcd_Chr_Cp (' ');
              Lcd_Chr_Cp (' ');
              Lcd_Chr_Cp (' ');
              Lcd_Chr_Cp (' ');
              Lcd_Chr (2,1, '5');
              } // end while
} // end sinc