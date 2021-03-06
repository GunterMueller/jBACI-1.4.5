%{
/* adapted from the Pascal lexical analyzer from the */
/* primost.cs.wisc.edu compiler archive              */

/******************************************************************************
      LEXICAL ANALYSER for ISO standard Pascal
      ----------------------------------------

This lexical analyser satisfies the following requirements in British
Standards Institution Specification for Computer programming language Pascal
BS6192:1982 (ISO 7185:1983)

6.1.1 6.1.2 6.1.3 6.1.4 6.1.5 6.1.6 6.1.7
6.1.8 (except ^Z is considered to be a space)
6.1.9
******************************************************************************/

#include <stdio.h>
#include <ctype.h>
#include <sys/types.h>
#include <string.h>
#include "ytab.h"

#include "../include/globdata.h"
#include "../include/globtabs.h"
#include "../include/compdata.h"
#include "../include/incfiles.h"
extern   int printf(const char*,...);
extern   int fprintf(FILE*,const char*,...);
extern   size_t fwrite(const void*,size_t,size_t,FILE*);
extern   int fgetc(FILE*);
extern   int fputc(int,FILE*);
extern   void yyerror(char*);

/* FLEX doesn't declare malloc and realloc before it uses them  */
/* This causes major problems in the MS-DOS version             */
/* The stdlib.h file declares malloc and realloc in Borland C   */
#ifdef __TURBOC__
#include <stdlib.h>
#endif

BUFFER lbuf;
char numbertext[256];
int  numberbase;
char lastident[256];    /* for identifiers */
char laststring[256];   /* for fname strings, other strings */ 
char lasttoken[256];

void comment(void);
void get_string(char);

extern int yydebug;
extern int yyerrflag;
extern int in_include;  /* yyparse signals entry into #include with this */

/* do it the way flex wants it */
int  baci_yyinput(char* buf, int maxsize);
#undef YY_INPUT
#define YY_INPUT(buf,result,maxsize) (result = baci_yyinput(buf,maxsize))
extern FILE* yyin;


%}

A  [Aa]
B  [Bb]
C  [Cc]
D  [Dd]
E  [Ee]
F  [Ff]
G  [Gg]
H  [Hh]
I  [Ii]
J  [Jj]
K  [Kk]
L  [Ll]
M  [Mm]
N  [Nn]
O  [Oo]
P  [Pp]
Q  [Qq]
R  [Rr]
S  [Ss]
T  [Tt]
U  [Uu]
V  [Vv]
W  [Ww]
X  [Xx]
Y  [Yy]
Z  [Zz]
%%
\n                   ;
[ \t\32]             ;
"//".*\n             ;
"{"                  { comment(); }
"(*"                 { comment(); }

<<EOF>>  {
            curr_infile = close_infile(curr_infile);
            if (curr_infile < 0)  /* EOF in the original file */
               yyterminate();
            else {
               fprintf(yyout,"Returning to file %s\n",
                  infile[curr_infile].fname);
            }
         }

{A}{N}{D}         { strcpy(lasttoken,yytext); return(AND); }
{A}{R}{R}{A}{Y}         { strcpy(lasttoken,yytext); return(ARRAY); }
{A}{T}{O}{M}{I}{C}      { strcpy(lasttoken,yytext); return(ATOMIC); }
{B}{E}{G}{I}{N}         { strcpy(lasttoken,yytext); return(SBEGIN); }
{C}{A}{S}{E}         { strcpy(lasttoken,yytext); return(CASE); }
{C}{O}{B}{E}{G}{I}{N}   { strcpy(lasttoken,yytext); return(CBEGIN); }
{C}{O}{E}{N}{D}      { strcpy(lasttoken,yytext); return(CEND); }
{C}{O}{N}{S}{T}         { strcpy(lasttoken,yytext); return(CONST); }
{D}{I}{V}         { strcpy(lasttoken,yytext); return(DIV);     }
{D}{O}            { strcpy(lasttoken,yytext); return(DO); }
{E}{L}{S}{E}         { strcpy(lasttoken,yytext); return(ELSE); }
{E}{N}{D}         { strcpy(lasttoken,yytext); return(END); }
{E}{X}{T}{E}{R}{N}{A}{L}   { strcpy(lasttoken,yytext); return(EXTERNAL); }
{F}{O}{R}         { strcpy(lasttoken,yytext); return(FOR); }
{F}{U}{N}{C}{T}{I}{O}{N}   { strcpy(lasttoken,yytext); return(FUNCTION); }
{I}{F}            { strcpy(lasttoken,yytext); return(IF); }
{I}{N}{C}{L}{U}{D}{E}   { strcpy(lasttoken,yytext); return(INCLUDE); }
{I}{N}{T}               { strcpy(lasttoken,yytext); return(INT); }
{M}{O}{D}         { strcpy(lasttoken,yytext); return(MOD); }
{M}{O}{N}{I}{T}{O}{R}   { strcpy(lasttoken,yytext); return(MONITOR); }
{N}{O}{T}         { strcpy(lasttoken,yytext); return(NOT); }
{O}{F}            { strcpy(lasttoken,yytext); return(OF); }
{O}{R}            { strcpy(lasttoken,yytext); return(OR); }
{P}{A}{R}{B}{E}{G}{I}{N}   { strcpy(lasttoken,yytext); return(CBEGIN); }         /*Moti*/
{P}{A}{R}{E}{N}{D}      { strcpy(lasttoken,yytext); return(CEND); }              /*Moti*/
{P}{R}{O}{C}{E}{D}{U}{R}{E}   { strcpy(lasttoken,yytext); return(PROCEDURE);  }  
{P}{R}{O}{C}{E}{S}{S}   { strcpy(lasttoken,yytext); return(PROCEDURE);  }        /*Moti*/
{P}{R}{O}{G}{R}{A}{M}      { strcpy(lasttoken,yytext); return(PROGRAM); }
{R}{E}{P}{E}{A}{T}      { strcpy(lasttoken,yytext); return(REPEAT);  }
{S}{P}{R}{I}{N}{T}{F}   { strcpy(lasttoken,yytext); return(SPRINTF); }
{S}{S}{C}{A}{N}{F}      { strcpy(lasttoken,yytext); return(SSCANF); }
{S}{T}{R}{I}{N}{G}      { strcpy(lasttoken,yytext); return(STRING); }
{S}{T}{R}{I}{N}{G}{C}{O}{N}{C}{A}{T} { 
   strcpy(lasttoken,yytext); return(STRINGCONCAT); }
{S}{T}{R}{I}{N}{G}{C}{O}{P}{Y} { 
   strcpy(lasttoken,yytext); return(STRINGCOPY); }
{S}{T}{R}{I}{N}{G}{C}{O}{M}{P}{A}{R}{E} { 
   strcpy(lasttoken,yytext); return(STRINGCOMPARE); }
{S}{T}{R}{I}{N}{G}{L}{E}{N}{G}{T}{H} { 
   strcpy(lasttoken,yytext); return(STRINGLENGTH); }
{T}{H}{E}{N}         { strcpy(lasttoken,yytext); return(THEN); }
{T}{O}            { strcpy(lasttoken,yytext); return(TO); }
{T}{Y}{P}{E}         { strcpy(lasttoken,yytext); return(TYPE); }
{U}{N}{T}{I}{L}         { strcpy(lasttoken,yytext); return(UNTIL); }
{V}{A}{R}         { strcpy(lasttoken,yytext); return(VAR); }
{W}{H}{I}{L}{E}         { strcpy(lasttoken,yytext); return(WHILE); }
{S}{E}{N}{D}      { strcpy(lasttoken,yytext); return(SEND); }
{R}{E}{C}{E}{I}{V}{E}   { strcpy(lasttoken,yytext); return(RECEIVE); }
{B}{R}{O}{A}{D}{C}{A}{S}{T}   { strcpy(lasttoken,yytext); return(BROADCAST); }

{C}{R}{E}{A}{T}{E}  			{ strcpy(lasttoken,yytext); return(CREATE); }        /*Moti*/
{M}{A}{K}{E}{V}{I}{S}{I}{B}{L}{E}  	{ strcpy(lasttoken,yytext); return(MAKEVISIBLE); }   /*Moti*/
{M}{O}{V}{E}{T}{O}  			{ strcpy(lasttoken,yytext); return(MOVETO); }        /*Moti*/
{M}{O}{V}{E}{B}{Y}  			{ strcpy(lasttoken,yytext); return(MOVEBY); }        /*Moti*/
{C}{H}{A}{N}{G}{E}{C}{O}{L}{O}{R}  	{ strcpy(lasttoken,yytext); return(CHANGECOLOR); }   /*Moti*/

{P}{O}{S}{T}{N}{O}{T}{E}	  	{ strcpy(lasttoken,yytext); return(POSTNOTE); }   /*Moti*/
{R}{E}{M}{O}{V}{E}{N}{O}{T}{E}	  	{ strcpy(lasttoken,yytext); return(REMOVENOTE); }   /*Moti*/
{R}{E}{A}{D}{N}{O}{T}{E}	  	{ strcpy(lasttoken,yytext); return(READNOTE); }   /*Moti*/

{R}{E}{M}{O}{V}{E}{N}{O}{T}{E}{E}{Q}  	{ strcpy(lasttoken,yytext); return(REMOVENOTEEQ); }   /*Moti*/
{R}{E}{A}{D}{N}{O}{T}{E}{E}{Q}	  	{ strcpy(lasttoken,yytext); return(READNOTEEQ); }   /*Moti*/


[_a-zA-Z][a-zA-Z0-9_]*     { char *p;
      strcpy(lasttoken,yytext); 
      strcpy(lastident, yytext);
      for (p = lastident; *p != '\0'; p++)
         if (isalpha(*p)) *p = tolower(*p);
      return(IDENTIFIER); /*if strict check no '_' */}
"<="           { strcpy(lasttoken,yytext); return(LE);  }
">="           { strcpy(lasttoken,yytext); return(GE);  }
"<>"           { strcpy(lasttoken,yytext); return(NE);  }
":="           { strcpy(lasttoken,yytext); return(BECOMES);   }
".."           { strcpy(lasttoken,yytext); return(DOTDOT); }
"(."           { strcpy(lasttoken,yytext); return('['); }
".)"           { strcpy(lasttoken,yytext); return(']'); }

";"   |
"."   |
"="   |
"+"   |
"-"   |
"*"   |
"/"   |
">"   |
"("   |
")"   |
"["   |
"]"   |
","   |
"#"   |
":"            { strcpy(lasttoken,yytext); return(yytext[0]); }

"<"      {  if (in_include) {
               get_string('>');
               strcpy(lasttoken,laststring);
               return FNSTRING;
            }
            else
            {
               strcpy(lasttoken,yytext);
               return (yytext[0]);
            }
         }

"\""     {  
            get_string('"');
            strcpy(lasttoken,laststring);
            return (in_include ? FNSTRING : RAWSTRING);
         }

[1-9][0-9]* { 
               strcpy(numbertext,yytext); 
               strcpy(lasttoken,yytext);
               numberbase = 10;
               return(UNSIGNED_INT);   
            }

0[0-9]*     { 
               strcpy(numbertext,yytext); 
               strcpy(lasttoken,yytext);
               numberbase = 8;
               return(UNSIGNED_INT);   
            }

0[xX][0-9a-fA-F]+ { 
                     strcpy(numbertext,&yytext[2]); /* 0x == yytext[0,1] */
                     strcpy(lasttoken,yytext);
                     numberbase = 16;
                     return(UNSIGNED_INT);   
                  }


"'"  { 
         get_string('\''); 
         strcpy(lasttoken,yytext);
         if (strlen(laststring) == 1)
            return(CHAR);
         else
            return (in_include ? FNSTRING : RAWSTRING);
      }

"}"   yyerror("'}' not in comment");

.  { 
      sprintf(lbuf,"Illegal character '\\%x'", (int)yytext[0]);
      yyerror(lbuf);
   }
%%

/* current source line, ll = length, cc = curr. column */
int ll=0,cc=0;

/* the buffer holding the current line */
char  line[LINESIZE+1];

/*
   This routine supplies the next character from the input
   stream, splitting the stream at the newlines and outputting
   the lines.  Returns 0 at EOF
*/
char nextch()
{
   char c;
   int i;
   if (cc < ll) {
      c = line[cc];
      cc++;
      return c;
   }
   /* cc >= ll -- time for a new line */
   i = 0;
   do { /* until EOF, EOL, or line buffer full */
      c = fgetc(yyin);
      if ((i < LINESIZE)&&(c != (char)EOF)){
         line[i] = c;
         i++;
      }
   } while ((i < LINESIZE) && (c != '\n')&&(c != (char)EOF));
   if (c == (char)EOF) {   /* if at EOF */
      if (i == 0) return 0;      /* return 0 to baci_yyinput for EOF */
      if (line[i-1] != '\n') {   /* take care of EOF with no EOL */
         line[i] = '\n';         /* add our own newline */
         i++;
      }
   }
   infile[curr_infile].line_no++;
   if (i >= LINESIZE) {  /* well, almost as usual */
      lasttoken[0] = line[LINESIZE - 1];
      lasttoken[1] = '\0';
      sprintf(lbuf,"Input line exceeds %d characters",LINESIZE );
      yyerror(lbuf);
      lasttoken[0] = '\0';    /* reset lasttoken */
      line[LINESIZE- 1] = '\n';    /* end the line with newline */
      i = LINESIZE;
      while ((c != (char) EOF)&&(c != '\n'))
         c = fgetc(yyin); /* consume the rest of this line */
   }
   line[i] = '\0';     /* terminate the line string */
   ll = i;
   for (i = 0; i < include_level; i++) fputc('>',yyout);
   fprintf(yyout,"%4d %4d  %s",infile[curr_infile].line_no,lc,line);
   if (yydebug)
      printf("%4d %4d  %s\n",infile[curr_infile].line_no,lc,line);
   cc = 1;
   if ((c == (char) EOF) && (ll == 0))   /* really, really EOF */
      return 0;
   else 
      return line[0];
}


/*
   This routine stores the current line from the current source file
   into a FLEX buffer when the lexer calls for input.

   Opening the original source file occurs in global_init, opening
   subsequent include files occurs in bac.y, the grammar, and closing
   the files occurs in the FLEX <<EOF>> specification rule above.
*/

int  baci_yyinput(char* buf, int maxsize)
{
   int i = 0;
   char c;
   char* p = buf;
   do {
      c = nextch();
      if (c) {
         *p = c;
         p++;
         i++;
      }
   } while ((c != 0)&&(i < maxsize)&&(c != '\n'));
   if (c == 0) i = YY_NULL;
   return i;
}

void comment(void)
{
char c, lastc=' ';
   while((c = input()))
      if(c == '}' || (lastc=='*' && c==')'))
         break;
      else if (c == (char)EOF) {
         yyerror("open comment at end-of-file");
         break;
      }
      else
         lastc = c;
}

char get_escape()
   /* read escape char from input */
{
   unsigned char esc = 0;
   char c;
   int reading;
   int digit;

   c = input();
   if ((c == 'x')||(c == 'X')) {
      reading = 1;
      do {
         c = input();
         digit = (c - '0');
         if (digit <= 9 )
            esc = 16*esc + digit;
         else {
            if ((c >= 'a')&& (c <= 'f')) {
               digit = 10 + c - 'a';
               esc = 16*esc + digit;
            } 
            else if ((c >= 'A')&& (c <= 'F')) {
               digit = 10 + c - 'A';
               esc = 16*esc + digit;
            } 
            else {
               reading = 0;
               unput(c);
            }
         }
      } while (reading);
   }
   else {   /* maybe an octal? */
      reading = 1;
      do {
         digit = (c - '0');
         if ((digit >= 0)&&(digit <= 7)) {
            esc = 8*esc + digit;
            c = input();
         }
         else {
            reading = 0;
            unput(c);
         }
      } while (reading);
   }
   return ((esc < 256) ? esc : 0x20);
}

void get_string(char termch)
{
char c,*p=laststring;
   while((c = input())) {
      if (c == termch) { *p++ = '\0'; return; }
      switch (c){
         case '\\':  c = input();
                     switch (c) {
                        case 'b':  *p++ = '\b'; break;
                        case 'f':  *p++ = '\f'; break;
                        case 'n':  *p++ = '\n'; break;
                        case 'r':  *p++ = '\r'; break;
                        case 't':  *p++ = '\t'; break;
                        case 'v':  *p++ = '\v'; break;
                        case '0':  *p++ = get_escape(); break;
                        default:  *p++ = c;
                     }
                     break;
         case '\n':
         case '\014':
         case '\015':   yyerror("Non-terminated string"); return;
         default:       *p++ = c; break;
      } /* switch */
   }
}
   
   
void fname_strings(char termch)
{
char c,*p=laststring;
   while((c = input())) {
      if (c == termch) { *p++ = '\0'; return; }
      switch (c){
         case '\n':
         case '\014':
         case '\015':   yyerror("Non-terminated filename string"); return;
         default:       *p++ = c; break;
      } /* switch */
   }
}

/*
 *
 *  $Log: bapascal.l,v $
 *
 *  Revision 3.2  2003/10/12 Moti 
 *  Linda primitives
 *                                  
 *  Revision 3.1  2003/06/15 Moti 
 *  backward compatibility of source
 *                                  
 *  Revision 3.0  2003/04/03 Moti   
 *  changes for graphics procedures 
 *
 *  Revision 2.9  2002/05/02 13:22:57  bynum
 *  add string.h include
 *
 *  Revision 2.8  2001/07/13 19:29:18  bynum
 *  add globtabs.h include
 *
 *  Revision 2.7  1998/11/26 22:49:44  bynum
 *  add nextch() routine, fix handling of long comments, long lines,
 *  and comments spanning multiple lines
 *
 *  Revision 2.6  1997/11/26 21:01:02  bynum
 *  add code to comment() to check for EOF
 *
 *  Revision 2.5  1997/11/20 01:55:39  bynum
 *  add (char)EOF typecasts for AIX
 *
 *  Revision 2.4  1997/11/20 00:46:18  bynum
 *  fix baci_yyinput() to accept a file with EOF and no preceding EOLN
 *
 *  Revision 2.3  1997/11/04 01:22:13  bynum
 *  change fwrite declaration to make it acceptable to all platforms, (incl AIX)
 *
 * Revision 2.1.1.1  1997/10/27  06:59:28  bynum
 * change malloc, realloc declaraion to #ifdef __TURBOC__ include stdlib.h
 *
 * Revision 2.1  1997/10/21  06:34:43  bynum
 * add sprintf, sscanf, hex unsigned ints, ' string delimiters
 *
 * Revision 2.0  1997/07/09  11:47:00  bynum
 * add EXTERNAL
 *
 * Revision 1.14  1997/06/20  10:04:55  bynum
 * add send, receive, broadcast
 *
 * Revision 1.13  1997/06/17  05:41:43  bynum
 * add string support, switch from ' to " as string delimiter, add
 * escape character support in raw strings
 *
 * Revision 1.12  1997/04/02  09:21:01  bynum
 * add 'lasttoken' to hold last token for yyparse (FLEX destroys yytext)
 *
 * Revision 1.11  1997/03/26  20:50:20  bynum
 * remove isatty, tolower prototypes
 *
 * Revision 1.10  1997/03/25  14:52:10  bynum
 * incorporate changes in the include directory, add prototypes to silence
 * gcc -Wall
 *
 * Revision 1.9  1997/03/01  05:35:12  bynum
 * switch to FLEX
 *
 * Revision 1.8  1996/03/06  13:52:47  bynum
 * add #ifdef MSDOS for ytab.h include
 *
 * Revision 1.7  1995/09/07  14:35:27  bynum
 * change includes to use the new structure of the ../include directory
 *
 * Revision 1.6  1995/08/14  15:14:02  bynum
 * fix problem of non-terminated filename string in include stmt
 *
 * Revision 1.5  1995/07/12  10:43:55  bynum
 * add fname_strings() proc and 'in_include' variable to handle
 * '#include <..>' and '#include ".."' cases
 *
 * Revision 1.4  1995/07/06  14:20:44  bynum
 * add printf to print source line guarded by if (yydebug)
 *
 * Revision 1.3  1995/06/30  14:02:19  bynum
 * add case for ATOMIC symbol
 *
 * Revision 1.2  1995/06/22  06:38:05  bynum
 * add '#' char, INCLUDE token, change input() to switch to & from include file
 *
 *
 */
