
#include "utl/spin_lock.h"

using namespace utl;

SpinLock::SpinLock()
{
    pthread_spin_init(&m_lock, PTHREAD_PROCESS_PRIVATE);
}

SpinLock::~SpinLock()
{
    pthread_spin_destroy(&m_lock);
}

void SpinLock::lock()
{
    pthread_spin_lock(&m_lock);
}

void SpinLock::unlock()
{
    pthread_spin_unlock(&m_lock);
}
