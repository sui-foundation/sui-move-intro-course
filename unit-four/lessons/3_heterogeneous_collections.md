# Heterogeneous Collections

Homogeneous collections like `Vector` and `Table` can work for marketplaces (or other types of applications) where we need to hold a collection of objects of the same type, but what if we need to hold objects of different types, or if we do not know at compile time what types the objects we need to hold are going to be?

For this type of marketplaces, we need to use a _heterogenerous_ collection to hold the items to be sold. Already having done the heavy lifting of understanding dynamic fields, heterogenerous collection in Sui should be very easy to understand.We will look at the `Bag` collection type more closely here. 

## The `Bag` Type

A `Bag` is a heterogeneous map-like collection. The collection is similar to `Table` in that its keys and values are not stored within the `Bag` value, but instead are stored using Sui's object system. The `Bag` struct acts only as a handle into the object system to retrieve those keys and values. 

### Common `Bag` Operations

A sample code of common `Bag` operations are included below: 

```rust

```

As you can see the functions signatures for interacting with a `Bag` are quite similar to ones interacting with a `Table` with the main difference being