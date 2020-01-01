/* -*- mode: c++; c-basic-offset: 4 -*- */

#pragma once
#include <cstdio>

namespace utl {

class InputStream;

class OutputStream {

public:
    /* should free all associated resources */
    virtual ~OutputStream() {
    }

public:
    /* this function will blocking until the size bytes will be written or
       an end of file will be reached; return value is count of actually
       copied bytes; in any case when returned value is less than size,
       eof is intended, any subsequentially calls to this function should
       return 0 copied bytes; in most cases, eof is just a state in which
       it is impossible to write more data into the stream */
    virtual void write(const char* buffer, int size) {
    }

    /* should flush all collected data into peer */
    virtual void flush() {
    }

public:
    /* copy an input stream into this output stream, max size bytes (if not -1),
       using buffer of bufferSize bytes during the operation */
    int writeStream(InputStream* input, int size = -1, unsigned bufferSize = 1024);
};

}
