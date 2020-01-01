
#include "utl/os_utils.h"
#include <stdlib.h>
#include <time.h>

void utl::millisleep(int ms)
{
    struct timespec interval;
    unsigned int sec = ms / 1000;
    interval.tv_sec = sec;
    ms -= (sec*1000);
    interval.tv_nsec = ms * 1000000;

    nanosleep(&interval, nullptr);
}

