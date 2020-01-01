
#include <stdio.h>
#include "utl/thread.h"

class MyThread : public utl::Thread {

public:
    void run() {
        printf(".");
    }
};

int main()
{
    enum { N = 100 };
    MyThread threads[N];

    for (int i = 0; i < N; i++) {
        threads[i].start();
    }
  
    for (int i = 0; i < N; i++) {
        threads[i].join();
    }

    printf("\nAll finished.\n");
    return 0;
}
