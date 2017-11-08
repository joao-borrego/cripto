#include <stdlib.h>
#include <string.h>

// Size of unprotected buffer in Bytes
#define BUFFER_SIZE 20
// Size of string to overflow buffer
#define BIG_STRING_SIZE 128

void overflow_function (char *str)
{
    char buffer[BUFFER_SIZE];

strcpy(buffer, str);  // Function that copies str to buffer
}

int main()
{
    char big_string[BIG_STRING_SIZE];
    int i;

    for(i=0; i < BIG_STRING_SIZE; i++)
    {
        big_string[i] = 'A'; // And fill big_string with 'A's
    }
    overflow_function(big_string);
    exit(0);
}
