/*   https://hackaday.io/project/178304-grant-searles-z80-cpm-design/log/190646-fixing-grant-searles-file-package-program  */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int next(FILE *,char *);
int main(int argc,char **argv) {
  int user;
  char to[14];
  char from[14];
  int ch,len,sum;
  FILE *fp1,*fp2;

  if (argc!=4) {
    printf("usage: ./file2hex.run usernumber filename.ext filename.hex\n");
  } else {
    strcpy(from,argv[2]);
    if ((fp1=fopen(from,"rb"))==NULL) {
      printf("file2hex: Source file %s not found\n", from);
    } else {
      strcpy(to,argv[3]);
      if ((fp2=fopen(to,"w"))==NULL) {
        printf("file2hex: Could not create destination file %s\n", to);
      } else {
        user=atoi(argv[1]);
        // fseek(fp1,0L,SEEK_END);
        // len=(char)ftell(fp1);
        // fseek(fp1,0L,SEEK_SET);
        sum=0;
        len=0;
        fprintf(fp2,"A:DOWNLOAD %s\r\n",from);
        fprintf(fp2,"U%d\r\n",user);
        fprintf(fp2,":");
        while ((ch=fgetc(fp1))!=EOF) {
          fprintf(fp2,"%02X",ch&0xff);
          sum+=ch;
          len++;
        }
        // Insert EOF  Marker if not end of record
        if (len%128!=0) {
          fprintf(fp2,"%02X",0x1a);
          sum+=0x1a;
          len++;
        }
        fprintf(fp2,">%02X%02X\r\n\r\n",len&0xff,sum&0xff);
        fclose(fp1);
        fclose(fp2);
      }
    }
  }
  return 0;
}
