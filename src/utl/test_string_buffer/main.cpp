
#include <stdio.h>
#include "utl/string_buffer.h"

int main()
{
    std::string s = utl::sprintf("Hello %d\n", 10);
    printf("%s", s.c_str());
    
    return 0;
}
