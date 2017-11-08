#include <string.h>
#include <stdio.h>

int fcopy(char *bf)
{
    char buffer[4];
    strcpy(buffer, bf);
    return 0;
}

int main(int argc, char *argv[])
{
	fcopy(argv[1]);
	return 0;
}
