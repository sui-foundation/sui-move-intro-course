// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

module collection::bag {

    use sui::bag::{Bag, Self};
    use sui::tx_context::{TxContext};

    // Defining a table with generic types for the key and value 
    struct GenericBag {
       items: Bag
    }

    // Create a new, empty GenericBag
    public fun create(ctx: &mut TxContext): GenericBag {
        GenericBag{
            items: bag::new(ctx)
        }
    }

    // Adds a key-value pair to GenericBag
    public fun add<K: copy + drop + store, V: store>(bag: &mut GenericBag, k: K, v: V) {
       bag::add(&mut bag.items, k, v);
    }

    /// Removes the key-value pair from the GenericBag with the provided key and returns the value.   
    public fun remove<K: copy + drop + store, V: store>(bag: &mut GenericBag, k: K): V {
        bag::remove(&mut bag.items, k)
    }

    // Borrows an immutable reference to the value associated with the key in GenericBag
    public fun borrow<K: copy + drop + store, V: store>(bag: &GenericBag, k: K): &V {
        bag::borrow(&bag.items, k)
    }

    /// Borrows a mutable reference to the value associated with the key in GenericBag
    public fun borrow_mut<K: copy + drop + store, V: store>(bag: &mut GenericBag, k: K): &mut V {
        bag::borrow_mut(&mut bag.items, k)
    }

    /// Check if a value associated with the key exists in the GenericBag
    public fun contains<K: copy + drop + store>(bag: &GenericBag, k: K): bool {
        bag::contains<K>(&bag.items, k)
    }

    /// Returns the size of the GenericBag, the number of key-value pairs
    public fun length(bag: &GenericBag): u64 {
        bag::length(&bag.items)
    }
}
