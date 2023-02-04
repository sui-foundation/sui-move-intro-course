// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

module collection::vector {

    use std::vector;

    struct Widget {
    }

    // Vector for a specified  type
    struct WidgetVector {
        widgets: vector<Widget>
    }

    // Vector for a generic type 
    struct GenericVector<T> {
        values: vector<T>
    }

    // Creates a GenericVector that hold a generic type T
    public fun create<T>(): GenericVector<T> {
        GenericVector<T> {
            values: vector::empty<T>()
        }
    }

    // Push a value of type T into a GenericVector
    public fun put<T>(vec: &mut GenericVector<T>, value: T) {
        vector::push_back<T>(&mut vec.values, value);
    }

    // Pops a value of type T from a GenericVector
    public fun remove<T>(vec: &mut GenericVector<T>): T {
        vector::pop_back<T>(&mut vec.values)
    }

    // Returns the size of a given GenericVector
    public fun size<T>(vec: &mut GenericVector<T>): u64 {
        vector::length<T>(&vec.values)
    }

}
