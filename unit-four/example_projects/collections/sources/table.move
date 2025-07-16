// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

module collection::table;

use sui::table::{Self, Table};

#[allow(unused_field)]
// Defining a table with specified types for the key and value
public struct IntegerTable {
    table_values: Table<u8, u8>,
}

// Defining a table with generic types for the key and value
public struct GenericTable<phantom K: copy + drop + store, phantom V: store> {
    table_values: Table<K, V>,
}

// Create a new, empty GenericTable with key type K, and value type V
public fun create<K: copy + drop + store, V: store>(
    ctx: &mut TxContext,
): GenericTable<K, V> {
    GenericTable<K, V> {
        table_values: table::new<K, V>(ctx),
    }
}

// Adds a key-value pair to GenericTable
public fun add<K: copy + drop + store, V: store>(
    table: &mut GenericTable<K, V>,
    k: K,
    v: V,
) {
    table.table_values.add(k, v);
}

/// Removes the key-value pair in the GenericTable `table: &mut Table<K, V>` and
/// returns the value.
public fun remove<K: copy + drop + store, V: store>(
    table: &mut GenericTable<K, V>,
    k: K,
): V {
    table.table_values.remove(k)
}

// Borrows an immutable reference to the value associated with the key in
// GenericTable
public fun borrow<K: copy + drop + store, V: store>(
    table: &GenericTable<K, V>,
    k: K,
): &V {
    table.table_values.borrow(k)
}

/// Borrows a mutable reference to the value associated with the key in
/// GenericTable
public fun borrow_mut<K: copy + drop + store, V: store>(
    table: &mut GenericTable<K, V>,
    k: K,
): &mut V {
    table.table_values.borrow_mut(k)
}

/// Check if a value associated with the key exists in the GenericTable
public fun contains<K: copy + drop + store, V: store>(
    table: &GenericTable<K, V>,
    k: K,
): bool {
    table.table_values.contains(k)
}

/// Returns the size of the GenericTable, the number of key-value pairs
public fun length<K: copy + drop + store, V: store>(
    table: &GenericTable<K, V>,
): u64 {
    table.table_values.length()
}
