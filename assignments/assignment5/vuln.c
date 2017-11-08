#include <string.h>
#include <stdio.h>
#define VULN_BUFFER_SIZE 500

int fcopy(char *bf)
{
    char buffer[VULN_BUFFER_SIZE];
    strcpy(buffer, bf);
    return 0;
}

int main(int argc, char *argv[])
{
	fcopy(argv[1]);
	return 0;
}
