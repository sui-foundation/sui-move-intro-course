# Sui Objects

## Introduction

Sui Move is a fully object-centric language. Transactions on Sui are expressed as operations where the inputs and outputs are both objects. 

As we briefly touched on this concept in [Unit 1 Lesson 4](../../unit-one/lessons/4_custom_types_and_abilities.md#custome-types-and-abilities), Sui objects are the basic unit of storage in Sui. It all starts from the `struct` keyword.

Let's first start with an example of a custom type that represents a transcript recording a student's grades:

```rust
struct Transcript {
    history: u8,
    math: u8,
    literature: u8,
}
```

In order to make a custom type instantiate a Sui object in global storage, we need to add the `key` ability, and a globally unique `id: UID` field inside the struct definition. If you need more context regarding of this part, you can refer back to [Unit 1 Lesson 4](../../unit-one/lessons/4_custom_types_and_abilities.md#custome-types-and-abilities).

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

Creating a Sui object requires a unique ID, we uses `sui::object::new(ctx)` function to create a new ID using the current `TxContext`. 

In Sui, every object must have an owner, which can be either an address, another object, or "shared". In our examples, we decided to make our new `transcriptObject` owned by the transaction sender, it is done using the `transfer` function of Sui framework and using `tx_context::sender` function to get the current entry call's sender's address.  

We will discuss object owernship more in-depth in the next section. 

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