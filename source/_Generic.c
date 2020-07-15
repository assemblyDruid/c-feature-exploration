#include <stdio.h>
#include <math.h>

#define cbrt(x) _Generic((x),                           \
                         long double: cbrtl,            \
                         float: cbrtf,                  \
                         default: cbrt)(x)



int main(int argc, char** argv)
{
    if (argc && argv) {}

    cbrt(1.0f);
    return 0;
}
