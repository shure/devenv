
#include "utl/thread.h"
#include <stdio.h>
#include <stdlib.h>

using namespace utl;

Thread::Thread() : m_created(false)
{
}

Thread::~Thread()
{
}

void Thread::start()
{
  if (m_created) {
    return;
  }
  if (pthread_create(&m_thread, nullptr, run_wrap, this)) {
    fprintf(stderr, "Error creating thread\n");
    abort();
  }
  m_created = true;
}

void Thread::join()
{
  if (!m_created) {
    return;
  }
  if (pthread_join(m_thread, nullptr)) {
    fprintf(stderr, "Error joining thread\n");
    abort();
  }
}

void* Thread::run_wrap(void* data)
{
  ((Thread*)data)->run();
  return nullptr;
}
