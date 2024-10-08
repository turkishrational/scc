/*-----------------------------------------------------------
* Small C Compiler for TRDOS 386 (v2.0.9 and later)
* Erdogan Tan - 2024
* Beginning: 05/09/2024
* Last Update: 23/09/2024
* -----------------------------------------------------------
* Derived from 'stdio.h' file of KolibriOS SCC source code
* 2024
*/

/*
** STDIO.H -- Standard Small C Definitions.
*/

/* TRDOS 386 Modification
extern char _iob[];
*/

#define exit	OS_exit
#define fopen	OS_fopen
#define fgetc	OS_fgetc
#define fputc	OS_fputc
#define fclose	OS_fclose
#define calloc	OS_calloc	// stdlib.h

#define SIZEOF_FILE 32		// sizeof (FILE)

/* TRDOS 386 Modification
#define stdin  (&_iob[0])
#define stdout (&_iob[1*SIZEOF_FILE])
#define stderr (&_iob[2*SIZEOF_FILE])
*/

/* TRDOS 386 Modification */
#define stdin  -1  /* sign for using '_OS_getc' instead of '_OS_fgetc' */
#define stdout -1  /* sign for using '_OS_putc' instead of '_OS_fputc' */	
#define stderr -1  /* sign for using '_OS_putc' instead of '_OS_fputc' */

#define stdaux   3  /* file descriptor for standard auxiliary port */
#define stdprn   4  /* file descriptor for standard printer */
#define FILE  char  /* supports "FILE *fp;" declarations */
#define ERR   (-2)  /* return value for errors */
#define EOF   (-1)  /* return value for end-of-file */
#define YES      1  /* true */
#define NO       0  /* false */
#define NULL     0  /* zero */
#define CR      13  /* ASCII carriage return */
#define LF      10  /* ASCII line feed */
#define BELL     7  /* ASCII bell */
#define SPACE  ' '  /* ASCII space */
#define NEWLINE LF  /* Small C newline character */

