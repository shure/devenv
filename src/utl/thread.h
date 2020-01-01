
#pragma once

#include <pthread.h>
#include <stdint.h>

namespace utl {

class Thread {

public:
  Thread();
  virtual ~Thread();

public:
  void start();
  void join();
  
public:
  virtual void run() = 0;
  
private:
  pthread_t m_thread;
  bool m_created;
  static void* run_wrap(void* data);
};

}
