// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

module collection::vector;

public struct Widget {}

#[allow(unused_field)]
// Vector for a specified type
public struct WidgetVector {
    widgets: vector<Widget>,
}

// Vector for a generic type
public struct GenericVector<T> {
    values: vector<T>,
}

// Creates a GenericVector that hold a generic type T
public fun create<T>(): GenericVector<T> {
    GenericVector<T> {
        values: vector::empty<T>(),
    }
}

// Push a value of type T into a GenericVector
public fun put<T>(vec: &mut GenericVector<T>, value: T) {
    vec.values.push_back(value);
}

// Pops a value of type T from a GenericVector
public fun remove<T>(vec: &mut GenericVector<T>): T {
    vec.values.pop_back()
}

// Returns the size of a given GenericVector
public fun size<T>(vec: &mut GenericVector<T>): u64 {
    vec.values.length()
}
