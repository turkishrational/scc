/* TRDOS 386 - Small C Compiler - 'libstd.asm' */
/* "printf" test */
/* Erdogan Tan - 04/04/2026 */

main()
{
  int a,b,d;
  char c;
  char *str;
  str = "TRDOS 386";
  a = 0x1a1;
  b = 417;
  c = 34;
  d = 0641;
  printf("%s %cLIBSTD.C%c Test\n\nDecimal num: %d\n",str,c,c,b);
  printf("Hexadecimal num: %x\nOctal num: %o\nBinary num: %b\n",a,d,b);
}
