# Sui Objects

## Introduction

As we briefly touched on this concept in [Unit 1 Lesson 4](../../unit-one/lessons/4_custom_types_and_abilities.md#custome-types-and-abilities). Sui objects is a unique data type exists in Sui Move, it is the basic unit of storage in Sui. It all starts from the `struct` type.

Let's first start with an example of your school transcript

```rust
struct Transcript {
    history: u8,
    math: u8,
    literature: u8,
}
```

The above struct is a struct for recording your school grades. In order to make a Sui Object in Sui Move, you just need to add `key` abilities, and additional `id: UID` field inside the struct. If you need more context regarding of this part, you can refer back to [Unit 1 Lesson 4](../../unit-one/lessons/4_custom_types_and_abilities.md#custome-types-and-abilities).

```rust
use sui::object::{UID};

struct TranscriptObject has key {
    id: UID,
    history: u8,
    math: u8,
    literature: u8,
}
```

## Create a Sui Object

```rust
use sui::object::{Self};
use sui::tx_context::{Self, TxContext};
use sui::transfer;

public entry fun create_transcript_object(history: u8, math: u8, literature: u8, ctx: &mut TxContext) {
  let transcriptObject = TranscriptObject {
    id: object::new(ctx),
    history,
    math,
    literature,
  };
  transfer::transfer(transcriptObject, tx_context::sender(ctx))
}
```

Creating a Sui object requires a unique ID, we uses `sui::object::new(ctx)` function to create a new ID using the current `TxContect`. 

In Sui, every object must have an owner, which can be either an address, another object, or "shared". In our examples, we decided to make our new `transcriptObject` owned by the transaction sender, it is done using the `transfer` function of sui framework and using `tx_context::sender` function to get the current entry call's sender's address.  

## Different Ownerships of Sui Objects

Each object has a owner field that indicates how this object is being owned, in Sui, there is 4 types of ownership, let's using our TranscriptObject example here:

### Owned by an Address

This is pretty straight forward as the object is owned by an address which the object is transfered to upon object creation, such as in above example:

```rust
transfer::transfer(transcriptObject, tx_context::sender(ctx)) // where tx_context::sender(ctx) is the recipient
```

where the `transcriptObject` is transfered to the address `sender` upon creation.

### Owned by an Object

It is important to distinguish the difference between owned by an object versus wrapped by an object.

Where wrapped by an object makes the wrapped object not accessible in global environment via object ID. Instead it would just be parts of the wrapper object itself. Below is an example of wrapped object (`TranscriptObject`), and wrapper object ( `Folder`). For further info about Object wrapping, go check out [here](https://docs.sui.io/devnet/build/programming-with-objects/ch4-object-wrapping)

```rust
use sui::obejct::{Self};
use sui::tx_context::{Self, TxContext};
use sui::transfer;

struct Folder {
  id: UID,
  transcript: TranscriptObject,
}
```

In order for an object to be owned by another object, it is done using `dynamic_object_field`, which we will explore in the later section of this unit. Basically, when an object is owned by another object, we will call it a child object. A child object is able to be founded in global runtime using object ID.

### Immutable Object(Not owned by anyone)

To make an object immutable, one can call:

```rust
transfer::freeze_object(obj);
```

Once an object has become immutable, since it cannot be mutated by anyone, it will not have its own exclusive owner.

### Shared Object

To make an shared object, one can call:

```rust
transfer::share_object(obj);
```

Once an object is shared, it stays mutable and can be accessed by anyone to send a transaction to mutate the object. 

## Different ways of passing in parameters (by value, ref and mut ref)

If you are familiar with rustlang, then you are probably familiar the rust ownership system. One advantage of movelang compare to solidity is that, you can get a sense of what a function call might do to your asset that you used for the function interaction. Here's why:

```rust
use sui::object::{Self};

// You are allowed to view the score but cannot modify it
public entry fun view_score(transcriptObject: &TranscriptObject): u8{
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



## Dynamic Fields & Dynamic Object Fields

These might be new terminology for a lot of people so lets first get to what are `fields` and `object fields` first.

- **Fields** can store any value that has `store`, however an object stored in this kind of field will be considered wrapped and will not be accessible via its ID by external tools (explorers, wallets, etc) accessing storage.
- **Object field** values *must* be objects (have the `key` ability, and `id: UID` as the first field), but will still be accessible at their ID to external tools.

Here's the API to use for adding **dynamic field**:

```rust
public fun add<Name: copy + drop + store, Value: store>(
  object: &mut UID,
  name: Name,
  value: Value,
);
```

Here's the API to use for adding **dynamic object field**:

```rust
public fun add<Name: copy + drop + store, Value: key + store>(
  object: &mut UID,
  name: Name,
  value: Value,
);
```

As you can see, the difference between the two api access is by Value, whether the value is and object field or fields.

### Adding a child object

Here's an example of adding the `transcript`object as a dynamic object field of a `folder` object, this can be understood as the `transcript` object is owned by `folder` object as child object.

```rust
use sui::dynamic_object_field as ofield;
use sui::object::{UID};

// Now you want to have your transcript inside an envelope for storing. Let's forst define an envelope object
struct Envelope has key {
  id: UID
}

public entry fun add_transcript(envelope: &mut Envelope, transcript: TranscriptObject) {
	ofield::add(&mut envelope.id, b"transcript", transcript);
}
```

### Accessing/Modifying a child object

Now let's say you want to update a score in your transcript, then you can use `borrow` and `borrow_mut` to access and even modify them. Here's how:

```rust
module sui::dynamic_field {
  public fun borrow<Name: copy + drop + store, Value: store>(
      object: &UID,
      name: Name,
  ): &Value;
  public fun borrow_mut<Name: copy + drop + store, Value: store>(
      object: &mut UID,
      name: Name,
  ): &mut Value;
}
```

```rust
// If you just want to get a score
public entry fun get_english_score(envelope: &Envelope): u8 {
	let transcript = ofield::borrow<vector<u8>, Transcript>(&mut envelope.id, b"transcript");
  transcript.history
}

// If you wish to update your history score
public entry fun update_english_score(envelope: &Envelope, score: u8){
	let transcript = ofield::borrow_mut<vector<u8>, Transcript>(&mut envelope.id, b"transcript");
  transcript.history = score;
}
```

### Removing a child object

```rust
module sui::dynamic_field {
  public fun remove<Name: copy + drop + store, Value: store>(
      object: &mut UID,
      name: Name,
  ): Value;
}
```

```rust
// If you wish to take out your transcript from the envelope.
public entry fun remove_transcript_from_envelope(envelope: &mut Envelope) {
    let Transcript { id, history: _, math: _, literature: _ } = ofield::remove<vector<u8>, Child>(
        &mut envelope.id,
        b"transcript",
    );
    // object::delete(id); // step is used if you want to delete the transcript instance.
}
```

