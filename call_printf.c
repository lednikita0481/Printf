//#include <stdlib.h>
#include <stdio.h>

extern void MyPrintf(const char* main_string, ...);

int main()
{
  MyPrintf("Hello, my %d %hui Subscriber!\n", (long)-100);
  printf("%d", sizeof(long));
}