# Capability Design Pattern

Capability is a pattern that allows authorizing actions with an object. As Sui Move is all about owning objects/assets. Therefore the concept of authority is also in the form of object. Let's take a look at below example:

```rust
module sui_intro_unit_two::capability {
  use sui::transfer;
  use sui::object::{Self, UID};
  use std::string::{Self, String};
  use sui::tx_context::{Self, TxContext};
  
  // Type that marks Capability to create, update, delete transcripts
  struct TeacherCap has key {
    id:UID
  }
  
  struct Transcript has key, store {
    id: UID, 
    history: u8,
    math: u8,
    literature: u8,
  } 
}
```

We have first declared two types of objects, one is named `TeacherCap` where it is the authority object, transactions with out passing this authority object will not be able to call certain restricted functions. `Transcript` object is an object that contains student's score information, should only be able to modified by teachers, and students can only view them but cannot operate any action to them.

```rust
fun init(ctx: &mut TxContext) {
  transfer::transfer(
    TeacherCap {
      id: object::new(ctx),
    },
    tx_context::sender(ctx)
  )
}
```

Then we have the init function, the constructor function in sui move.  It creates one TeacherCap instance and send it to publisher, which in this case, should be teachers themselves.

```rust
public entry fun create(
  _: &TeacherCap, 
  history: u8, 
  math: u8, 
  literature: u8, 
  ctx: &mut TxContext
) {
  transfer::transfer(
    Transcript {
      id: object::new(ctx),
      history: history,
      math: math,
      literature: literature,
    },
    tx_context::sender(ctx)
  )
}
```

This is a create function, where it requires a `TeacherCap` object for calling this entry function. It can only be called by owners of `TeacherCap` object.

```rust
public entry fun update(
  _: &TeacherCap,
  history: u8,
  math: u8,
  literature: u8,
  transcript: &mut Transcript
) {
  transcript.math = math;
  transcript.history = history;
  transcript.literature = literature;
}

public entry fun delete(
  _: &TeacherCap, transcript: Transcript
) {
  let Transcript { id, history: _, math: _, literature: _ } = transcript;
  object::delete(id);
}
```

Same goes to update and delete functions, they cannot be called if the transaction sender doesn't have `TeacherCap` object. But now, how can we manage the capabilities among teachers?

We could create a new capability type named `SuperTeacherCap`.

```rust
struct SuperTeacherCap has key{
  id: UID,
}

fun init(ctx: &mut TxContext) {
  transfer::transfer(
    SuperTeacherCap {
      id: object::new(ctx),
    },
    tx_context::sender(ctx)
  )
}
```

In the above code, we have created a new capability named `SuperTeacherCap`, which will have access to add teachers to modity transcripts. 

```rust
public entry fun new_teacher(){
	_: &SuperTeacherCap,
	to: address
} {
	transfer::transfer(
    TeacherCap {
      id: object::new(ctx),
      name: string::utf8(name)
    },
    to
  )
}
```

The entire code can be found in [*HERE*](../example_projects/transcript/sources/capability.move)
