/* -*- mode: c++; c-basic-offset: 4 -*- */

#pragma once

#include <pthread.h>

namespace utl {

class SpinLock {

public:
    struct Guard {
        Guard(SpinLock& ref) : ref(ref) { ref.lock(); }
        ~Guard() { ref.unlock(); }
    private:
        SpinLock& ref;
    };

public:
    SpinLock();
    ~SpinLock();

public:
    void lock();
    void unlock();

private:
    pthread_spinlock_t m_lock;
};

}
