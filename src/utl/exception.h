/* -*- mode: c++; c-basic-offset: 4 -*- */

#pragma once
#include <string>
#include "utl/portability.h"

namespace utl {

class Exception {

public:
    Exception();
    Exception(const std::string& message);
    Exception(const char* format, ...) FORMAT_PRINTF(2, 3);
    Exception(const Exception& other);

    Exception& operator=(const Exception& other) {
        m_message = other.m_message;
        return *this;
    }

    inline const char* get_message() const {
        return m_message.c_str();
    }

private:
    std::string m_message;
};

}
