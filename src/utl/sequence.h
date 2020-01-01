/* -*- mode: c++; c-basic-offset: 4 -*- */

#pragma once
#include <stdlib.h>

namespace utl {

template <typename T>
class Sequence {

public:
    virtual ~Sequence() {
    }

    virtual bool has_more() const = 0;

    virtual T get_next() = 0;
};

template <typename T>
class ArraySequence : public Sequence<T> {

public:
    ArraySequence(T* array, size_t count) : array(array), count(count), current(0) {
    }

    void reset() {
        current = 0;
    }
    
    virtual bool has_more() const {
        return current != count;
    }

    virtual T get_next() {
        return array[current++];
    }
    
    T* array;
    size_t count;
    size_t current;
};

}
