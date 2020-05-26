#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>

struct termios saved_attributes;
extern int startASM();

void reset_input_mode ()
{
    tcsetattr (0, TCSANOW, &saved_attributes);
}

int main() {
    struct termios tattr;
    tcgetattr(0, &saved_attributes);
    atexit(reset_input_mode);

    tcgetattr(0, &tattr);
    tattr.c_lflag &= ~(ICANON|ECHO); /* Clear ICANON and ECHO. */
    tattr.c_cc[VMIN] = 1;
    tattr.c_cc[VTIME] = 0;
    tcsetattr(0, TCSAFLUSH, &tattr);

    startASM();
    //printf("%zu\n", sizeof(saved_attributes));
    //printf("Hello\n");
    reset_input_mode();
    return 0;
}
