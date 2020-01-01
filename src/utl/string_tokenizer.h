/* -*- mode: c++; c-basic-offset: 4 -*- */

#pragma once

#include "utl/sequence.h"

namespace utl {

/**
 * String tokenizer class.
 * Supports the following set of features:
 * - User data is unchanged, and may be passed
 *   by const char*;
 * - All returned tokens are valid until tokenizer
 *   itself is exist (without overhead).
 * - Allow/disallow multiple delimeters.
 */

class StringTokenizer : public utl::Sequence<const char*> {

public:
    /**
     * Create string tokenizer.
     * Space and Tab characters will be used as
     * delimeters by default. Multiple delimeters
     * will be allowed by default.
     */
    StringTokenizer(const char* str, const char* delimeters = " \t");

    /**
     * Destroy string tokenizer.
     * All returned tokens will be invalid
     * pointers after call to this function.
     */
    ~StringTokenizer();

public:
    /**
     * Change current delimeters set.
     */
    inline void set_delimeters(const char* delimiters) {
        this->delimiters = delimiters;
    }

    /**
     * Allow multiple delimeters, i.e. string like "a  b"
     * will be parsed as two tokens: "a" and "b".
     */
    inline void allow_multiple_delimeters() {
        multiple_delimeters = true;
    }

    /**
     * Disallow multiple delimeters, i.e. string like "a  b"
     * will be parsed as three tokens: "a", "" and "b".
     */
    inline void disallow_multiple_delimeters() {
        multiple_delimeters = false;
    }

public:
    /**
     * Return next token as const char*.
     * All tokens returned by this function will be valid pointers
     * until the tokenizer will be destroyed.
     */
    virtual const char* get_next();

    /**
     * Return true if the next token will be available.
     */
    virtual bool has_more() const;

private:
    char *str, *pos;
    const char* delimiters;
    bool multiple_delimeters;
};

}
