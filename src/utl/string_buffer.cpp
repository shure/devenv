
#include "utl/string_buffer.h"
#include <cstring>
#include <cstdlib>
#include <algorithm>

using namespace utl;

StringBuffer::StringBuffer(int capacity, bool auto_expand)
    : m_auto_expand(auto_expand), m_cookie(0)
{
    m_begin = (char*)malloc(capacity);
    m_write = m_begin;
    m_end = m_begin + capacity;
}

StringBuffer::StringBuffer(const char* str, bool auto_expand)
    : m_auto_expand(auto_expand), m_cookie(0)
{
    init(str);
}

StringBuffer::StringBuffer(const StringBuffer& other)
    : m_auto_expand(other.m_auto_expand), m_cookie(0)
{
    unsigned long capacity = other.get_capacity();
    unsigned long size = other.get_size();
    m_begin = (char*)malloc(capacity);
    memcpy(m_begin, other.m_begin, size);
    m_write = m_begin + size;
    m_end = m_begin + capacity;
}

StringBuffer& StringBuffer::operator=(const StringBuffer& other)
{
    if (m_begin) {
        free(m_begin);
        m_begin = NULL;
    }
    m_auto_expand = other.m_auto_expand;
    unsigned long capacity = other.get_capacity();
    unsigned long size = other.get_size();
    m_begin = (char*)malloc(capacity);
    memcpy(m_begin, other.m_begin, size);
    m_write = m_begin + size;
    m_end = m_begin + capacity;
    return *this;
}

StringBuffer::~StringBuffer()
{
    if (m_cookie) {
        fclose(m_cookie);
    }
    if (m_begin) {
        free(m_begin);
        m_begin = NULL;
    }
}

void StringBuffer::init(const char* str)
{
    unsigned long len = str ? strlen(str) : 0;
    m_begin = (char*)malloc(len + 1);
    memcpy(m_begin, str, len);
    m_write = m_begin + len;
    m_end = m_write + 1;
}

void StringBuffer::clear()
{
    m_write = m_begin;
}

static ssize_t cookie_write_function(void* cookie, const char* buffer, size_t size)
{
    StringBuffer* self = reinterpret_cast<StringBuffer*>(cookie);
    self->append(buffer, size);
    return size;
}

FILE* StringBuffer::get_cookie()
{
    if (!m_cookie) {
        cookie_io_functions_t io;
        bzero(&io, sizeof(io));
        io.write = &cookie_write_function;
        m_cookie = fopencookie(this, "w", io);
    }
    return m_cookie;
}

int StringBuffer::vprintf(const char* format, va_list args)
{
    int retv = vfprintf(get_cookie(), format, args);
    fflush(m_cookie);
    return retv;
}

int StringBuffer::printf(const char* format, ...)
{
    va_list args;
    va_start(args, format);
    int size = vprintf(format, args);
    va_end(args);
    return size;
}

unsigned long StringBuffer::append(char ch)
{
    return append(&ch, 1);
}

unsigned long StringBuffer::append(char ch, unsigned n)
{
    unsigned long retv = 0;
    for (unsigned u = 0; u < n; u++) {
        retv += append(&ch, 1);
    }
    return retv;
}

unsigned long StringBuffer::append(const char* str)
{
    return append(str, str ? strlen(str) : 0);
}

unsigned long StringBuffer::append(const char* buffer, unsigned long size)
{
    unsigned long n;
    if (m_auto_expand) {
        expand(get_size() + size);
        n = size;
    } else {
        n = std::min((unsigned long)(m_end - m_write), size);
    }

    if (n == 0) {
        return 0;
    }

    memcpy(m_write, buffer, n);
    m_write += n;
    return n;
}

void StringBuffer::expand(unsigned long new_size)
{
    /* check the existing capacity,
       return if there is enough space */
    unsigned long capacity = get_capacity();
    if (new_size <= capacity) {
        return;
    }

    /* calculate new capacity */
    while (capacity < new_size) {
        capacity = capacity * 2;
    }

    /* allocate new memory, read all
       the data into this memory */
    unsigned long size = get_size();
    char* memory = (char*)malloc(capacity);
    memcpy(memory, m_begin, size);

    /* replace old storage by the new one */
    free(m_begin);
    m_begin = memory; m_end = m_begin + capacity;
    m_write = memory + size;
}

const char* StringBuffer::make_string() {
    expand(get_size() + 1);
    *m_write = (char)0;
    return m_begin;
}

char* StringBuffer::grab_str()
{
    expand(get_size() + 1);
    *m_write = (char)0;
    char* retv = m_begin;
    m_begin = m_end = m_write = 0;
    return retv;
}

void StringBuffer::translate(const char* from_chars, const char* to_chars)
{
    for (char* ptr = m_begin; ptr != m_write; ++ptr) {
        for (const char* from = from_chars; *from; ++from) {
            if (*from == *ptr) {
                *ptr = to_chars[from - from_chars];
                break;
            }
        }
    }
}

void StringBuffer::write(const char* buffer, int size)
{
    append(buffer, size);
}

std::string utl::sprintf(const char* format, ...)
{
    utl::StringBuffer buf;
    va_list args;
    va_start(args, format);
    buf.vprintf(format, args);
    va_end(args);
    return buf.str();
}
