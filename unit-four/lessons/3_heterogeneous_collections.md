# Heterogeneous Collections

Homogeneous collections like `Vector` and `Table` can work for marketplaces (or other types of applications) where we need to hold a collection of objects of the same type, but what if we need to hold objects of different types, or if we do not know at compile time what types the objects we need to hold are going to be?

For this type of marketplaces, we need to use a _heterogenerous_ collection to hold the items to be sold. Already having done the heavy lifting of understanding dynamic fields, heterogenerous collection in Sui should be very easy to understand.We will look at the `Bag` collection type more closely here. 

## The `Bag` Type

A `Bag` is a heterogeneous map-like collection. The collection is similar to `Table` in that its keys and values are not stored within the `Bag` value, but instead are stored using Sui's object system. The `Bag` struct acts only as a handle into the object system to retrieve those keys and values. 

### Common `Bag` Operations

A sample code of common `Bag` operations are included below: 

```rust
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
```

As you can see the functions signatures for interacting with a `Bag` collection are quite similar to ones interacting with a `Table` collection, with the main difference being not needing to declare any types while creating a new `Bag`, and the the key-value pair types being added to it do not need to be of the same types.