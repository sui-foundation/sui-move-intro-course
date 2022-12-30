# Types of Ownership of Sui Objects

Each object in Sui has an owner field that indicates how this object is being owned. In Sui Move, there are total of four types of ownership. 

## Owned Objects

The first two types of ownership fall under the `Owned Objects` category. Owned objects in Sui are processed differently from shared objects and do not require global ordering. 

### Owned by an Address

Let's continue using our `transcript` example here. This type of ownership is pretty straightforward as the object is owned by an address which the object is transfered to upon object creation, such as in above example at this line:

```rust
    transfer::transfer(transcriptObject, tx_context::sender(ctx)) // where tx_context::sender(ctx) is the recipient
```

where the `transcriptObject` is transfered to the address of the transaction sender upon creation.

### Owned by Another Object

In order for an object to be owned by another object, it is done using `dynamic_object_field`, which we will explore in the next section. Basically, when an object is owned by another object, we will call it a child object. A child object is able to be looked up in global storage using its object ID.

## Immutable Objects

Certain objects in Sui cannot be mutated by anyone, and because of this, these objects do not have an exclusive owner. All published packages and modules in Sui are immutable objects. 

To make an object immutable manually, one can call the following special function:

```rust
    transfer::freeze_object(obj);
```

## Shared Objects

Shared objects in Sui can be read or mutated by anyone. Shared object transactions require global ordering through a consensus layer protocol, unliked owned objects. 

To create a shared object, one can call this method:

```rust
    transfer::share_object(obj);
```

Once an object is shared, it stays mutable and can be accessed by anyone to send a transaction to mutate the object. 

## Parameter Passing (by `value`, `ref` and `mut ref`)

If you are familiar with rustlang, then you are probably familiar the Rust ownership system. One advantage of movelang compare to Solidity is that, you can get a sense of what a function call might do to your asset that you used for the function interaction. Here are some examples:

```rust
use sui::object::{Self};

// You are allowed to retrieve the score but cannot modify it
public fun view_score(transcriptObject: &TranscriptObject): u8{
    transcriptObject.literature
}

// You are allowed to view and edit the score but not allowed to delete it
public entry fun update_score(transcriptObject: &mut TranscriptObject, score: u8){
    transcriptObject.literature = score
}

// You are allowed to do anything with the score, including view, edit, delete the entire transcript itself.
public entry fun delete_transcript(transcriptObject: TranscriptObject){
    let TranscriptObject {id, history: _, math: _, literature: _ } = transcriptObject;
    object::delete(id);
}
```

### Object Deletion and Struct Unpacking

The `delete_transcript` method above illustrates how to delete an object on Sui. 

You must first unpack the object and retrieve its object ID. Unpacking can only be done inside the module that defines the object due to Move's privileged struct operation rules:

- Struct types can only be created ("packed"), destroyed ("unpacked") inside the module that defines the struct.
- The fields of a struct are only accessible inside the module that defines the struct.

Following these rules, if you want to modify your struct outside its defining module, you will need to provide public APIs for these operations. 

After unpacking the struct and retrieving its id, the object can be deleted by simply calling the `object::delete` framework method.



