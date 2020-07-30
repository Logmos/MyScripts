#include <stdio.h>

int main() {
  //Tigger clang-tidy failure
  int *pInt = NULL;
  char StrArray[32] = {0};
  // Trigger checkAPIs.pl validation failure
  sprintf(StrArray, "%s", "Hello World");
  for (int i = 0; i < 8; i++)
    printf("%d\n", i);
  printf("This is just a test\n");
  return 0;
}
