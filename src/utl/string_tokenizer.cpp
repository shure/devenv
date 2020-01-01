/* -*- c-basic-offset: 4 -*- */

#include "utl/string_tokenizer.h"
#include <cstring>
#include <cstdlib>

using namespace utl;

StringTokenizer::StringTokenizer(const char* str, const char* delimiters)
    : str(strdup(str)), delimiters(delimiters), multiple_delimeters(true)
{
    this->pos = this->str;
}

StringTokenizer::~StringTokenizer()
{
    free(str);
}

const char* StringTokenizer::get_next()
{
    /* skip delimeters */
    if (multiple_delimeters) {
        pos += strspn(pos, delimiters);
    }

    /* check for eol */
    if (!*pos) {
        return 0;
    }

    /* find the next token */
    char* retv = pos;
    pos += strcspn(pos, delimiters);
    if (*pos) {
        *pos = 0; pos++;
    }
    return retv;
}

bool StringTokenizer::has_more() const
{
    /* skip delimeters */
    if (multiple_delimeters) {
        const_cast<StringTokenizer*>(this)->pos += strspn(pos, delimiters);
    }

    /* check for eol */
    return *pos;
}
