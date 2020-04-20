#line 1 "C:/Users/Pedro Henrique/Documents/Projeto uC/Documentação/Software 876A/Codigo.c"
#line 24 "C:/Users/Pedro Henrique/Documents/Projeto uC/Documentação/Software 876A/Codigo.c"
sbit LCD_RS at RC2_bit;
sbit LCD_EN at RC3_bit;
sbit LCD_D7 at RC7_bit;
sbit LCD_D6 at RC6_bit;
sbit LCD_D5 at RC5_bit;
sbit LCD_D4 at RC4_bit;


sbit LCD_RS_Direction at TRISC2_bit;
sbit LCD_EN_Direction at TRISC3_bit;
sbit LCD_D7_Direction at TRISC7_bit;
sbit LCD_D6_Direction at TRISC6_bit;
sbit LCD_D5_Direction at TRISC5_bit;
sbit LCD_D4_Direction at TRISC4_bit;
#line 57 "C:/Users/Pedro Henrique/Documents/Projeto uC/Documentação/Software 876A/Codigo.c"
char auxcont0 = 0x00,
 sel = 0x01,
 flagsA;



void interrupt ()
{

 if (INTF_bit)
 {
 T1CON.F0 = 0x01;
 INTF_bit = 0x00;

 }


 if (TMR1IF_bit)
 {

 RA1_bit = 0x01;
 delay_us (100);
 RA1_bit = 0x00;

 TMR1H = 0x63;
 TMR1L = 0xC0;


 TMR1IF_bit = 0x00;
 }


 if (TMR0IF_bit)
 {
 auxcont0++;

 if (auxcont0 == 10)
 {

 if (! RB3_bit )
 {
  flagsA.B3  = 0x00;
  flagsA.B2  = 0x01;
 }

 if (! RB2_bit )
 {
  flagsA.B3  = 0x01;
  flagsA.B2  = 0x00;
 }

 auxcont0 = 0x00;

 }
 TMR0 = 0x3C;
 TMR0IF_bit = 0x00;
 }


}



void registradores ();
void testabotoes ();
void controlight ();
void fade ();
void flash ();
void timer ();
void sinc ();



void main()
{
  flagsA.B2  = 0x00;
  flagsA.B3  = 0x00;
  flagsA.B0  = 0x00;
  flagsA.B1  = 0x00;
  flagsA.B4  = 0x00;

 registradores ();

 Lcd_Init();
 Lcd_Cmd (_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);
 Lcd_Out (1, 6,"Dimmer");
 Lcd_Out (2, 2,"Microcontrolado");

 delay_ms (1000);
 Lcd_Cmd (_LCD_CLEAR);

 while (1)
 {
 testabotoes();

 switch (sel)
 {
 case 0x01:

 if ( flagsA.B4 )
 {
 LCD_Cmd (_LCD_CLEAR);
  flagsA.B4  = 0x00;
 }

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

 Lcd_Out (2,1, "                ");

 controlight ();
 break;

 case 0x02:

 if ( flagsA.B4 )
 {
 LCD_Cmd (_LCD_CLEAR);
  flagsA.B4  = 0x00;
 }

 Lcd_Chr (1,1, '<');
 Lcd_Chr (1,16, '>');
 Lcd_Chr (1,3, 'F');
 Lcd_Chr_Cp ('a');
 Lcd_Chr_Cp ('d');
 Lcd_Chr_Cp ('e');





 Lcd_Out (2,1, "                ");

 fade ();
 break;

 case 0x03:

 if ( flagsA.B4 )
 {
 LCD_Cmd (_LCD_CLEAR);
  flagsA.B4  = 0x00;
 }

 Lcd_Chr (1,1, '<');
 Lcd_Chr (1,16, '>');
 Lcd_Chr (1,3, 'F');
 Lcd_Chr_Cp ('l');
 Lcd_Chr_Cp ('a');
 Lcd_Chr_Cp ('s');
 Lcd_Chr_Cp ('h');





 Lcd_Out (2,1, "                ");

 flash ();
 break;

 case 0x04:

 if ( flagsA.B4 )
 {
 LCD_Cmd (_LCD_CLEAR);
  flagsA.B4  = 0x00;
 }

 Lcd_Chr (1,1, '<');
 Lcd_Chr (1,16, '>');
 Lcd_Chr (1,3, 'T');
 Lcd_Chr_Cp ('i');
 Lcd_Chr_Cp ('m');
 Lcd_Chr_Cp ('e');
 Lcd_Chr_Cp ('r');





 Lcd_Out (2,1, "                ");

 timer ();
 break;

 case 0x05:

 if ( flagsA.B4 )
 {
 LCD_Cmd (_LCD_CLEAR);
  flagsA.B4  = 0x00;
 }

 Lcd_Chr (1,1, '<');
 Lcd_Chr (1,16, '>');
 Lcd_Chr (1,3, 'S');
 Lcd_Chr_Cp ('i');
 Lcd_Chr_Cp ('n');
 Lcd_Chr_Cp ('c');





 Lcd_Out (2,1, "                ");

 sinc ();
 break;

 }

 }
 }



void registradores ()
{


 INTCON = 0xF0;









 OPTION_REG = 0x87;







 T1CON = 0x00;







 PIE1 = PIE1 | 0x01;


 PIR1 = PIR1 & 0xFE;


 TMR1H = 0x63;
 TMR1L = 0xC0;


 CMCON = 0x07;
 CVREN_bit = 0;
 CVROE_bit = 0;

 TMR0 = 0x3C;

 ADON_bit = 0x00;
 ADCON1 = 0x0F;

 TRISA = 0b11111101;
 TRISB = 0b11111101;
 TRISC = 0xF0;


 PORTA = 0x00;
 PORTB = 0xFF;
 PORTC = 0x00;




}

void testabotoes ()
{
 if (! RB7_bit )  flagsA.B0  = 0x01;
 if (! RB6_bit )  flagsA.B1  = 0x01;

 if ( RB7_bit  &&  flagsA.B0 )
 {
  flagsA.B0  = 0x00;
 sel++;
  flagsA.B4  = 0x01;
 }

 if ( RB6_bit  &&  flagsA.B1 )
 {
  flagsA.B1  = 0x00;
 sel--;
  flagsA.B4  = 0x01;
 }

 if (sel >  5 ) sel = 0x01;
 if (sel < 0x01) sel =  5 ;

}

void controlight ()
{
 while ( flagsA.B2  && ! flagsA.B3  )
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
 }
}

void fade ()
{
 while ( flagsA.B2  && ! flagsA.B3 )
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
 }
}

void flash ()
{
 while ( flagsA.B2  && ! flagsA.B3 )
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
 }
}

void timer ()
{
 while ( flagsA.B2  && ! flagsA.B3 )
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
 }
}

void sinc ()
{
 while ( flagsA.B2  && ! flagsA.B3 )
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
 }
}
