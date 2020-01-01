/* -*- mode: c++; c-basic-offset: 4 -*- */

#pragma once
#include <string>
#include <cstdio>
#include <cstdarg>
#include "utl/output_stream.h"
#include "utl/portability.h"

namespace utl {

class StringBuffer : public OutputStream {

public:
    /* create a string buffer object with initial capacity and auto_expand flag;
       when auto_expand is true the "write" call will always return exactly "size"
       successfull written bytes */
    StringBuffer(int capacity = 80, bool auto_expand = true);

    /* create a string buffer object initialized by the specified string and
       auto_expand flag; see also the previous constructor convention */
    StringBuffer(const char* str, bool auto_expand = true);

    /* conventional copy constructor */
    StringBuffer(const StringBuffer& other);

    /* conventional assignment operator */
    StringBuffer& operator=(const StringBuffer& other);

    /* virtual destructor */
    virtual ~StringBuffer();

public:
    /* return an actual amount of chars in the buffer */
    inline unsigned long get_size() const {
        return m_write - m_begin;
    }

    /* return current (or final, if !auto_expand) capacity of buffer */
    inline unsigned long get_capacity() const {
        return m_end - m_begin;
    }

    /* check whether the buffer is empty */
    inline bool empty() const {
        return m_write == m_begin;
    }

    /* check whether the buffer is full and can not be extended */
    inline bool full() const {
        return m_write == m_end;
    }

    /* conventional casting to c-string; See 'str's function
       convention */
    inline operator const char*() const {
        return str();
    }

    inline const char* begin() const {
        return m_begin;
    }

    inline char* begin() {
        return m_begin;
    }

    void skip(size_t nBytes) {
        expand(get_size() + nBytes);
        m_write += nBytes;
    }

public:
    /* clear the buffer; capacity will be unchanged but size will
       be zero */
    void clear();

    FILE* get_cookie();

    /* conventional printf function */
    int printf(const char* format, ...) FORMAT_PRINTF(2, 3);

    /* conventional vprintf function */
    int vprintf(const char* format, va_list ap);

public:
    /* append a char to the buffer */
    unsigned long append(char ch);

    /* append a char n times to the buffer */
    unsigned long append(char ch, unsigned n);

    /* append a null terminated string to the buffer */
    unsigned long append(const char* str);

    /* append a buffer content to the buffer */
    unsigned long append(const char* buffer, unsigned long size);

    /* expand the buffer to be able to contain specified amount of chars */
    void expand(unsigned long capacity);

    /* convert to c-string and return pointer to it; note that it should be
       at least one available position in the buffer for terminating zero character;
       if auto_expand is true buffer may be expanded to appropriated size; if
       auto_expand is false and there is no more place in the buffer 0 will be
       returned */
    const char* str() const {
        return const_cast<StringBuffer *>(this)->make_string();
    }

    /* grab the string from the buffer; after this call the buffer changes
       the state to invalid; the only function that you can call in this
       state is the destructor */
    char* grab_str();

    /* Translate the buffer according to the specified translation table. */
    void translate(const char* from_chars, const char* to_chars);

public: /* ::utl::OutputStream implementation */
    virtual void write(const char* buffer, int size);

private:
    const char* make_string();
    void init(const char* str);

private:
    char *m_begin, *m_end, *m_write;
    bool m_auto_expand;
    FILE* m_cookie;
};

std::string sprintf(const char* format, ...) FORMAT_PRINTF(1, 2);

}
