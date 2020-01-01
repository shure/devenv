
#include "utl/exception.h"
#include "utl/string_buffer.h"
#include <cstdio>
#include <cstdarg>

using namespace ::utl;

/* Use this function for debugging purposes */
#ifdef DEBUG
extern "C" void on_utl_exception(const char* err)
{
    fprintf(stderr, "An exception thrown: %s\n", err ? err : "[NO MESSAGE]");
}
#endif

Exception::Exception() 
{
#ifdef DEBUG
    on_utl_exception("");
#endif
}

Exception::Exception(const std::string& message)
  : m_message(message)
{
#ifdef DEBUG
    on_utl_exception(m_message.c_str());
#endif
}

Exception::Exception(const char* format, ...)
{
    va_list args;
    va_start(args, format);
    StringBuffer buf;
    buf.vprintf(format, args);
    m_message = (const char*)buf;
}

Exception::Exception(const Exception& other)
    : m_message(other.m_message)
{
}
