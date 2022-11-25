# Functions

In this section, we will introduce functions in Sui Move, and write our first Sui Move function as a part of the Hello World example. 

## Function Visibility

Sui Move functions have three types of visibility:

- **private**: the default visibility of a function; it can only be accessed by functions inside the same module
- **public**: the function is accessible by functions inside the same module, and by functions defined in another module
- **public(friend)**: the function is accessible by functions inside the same module and by functions defined in modules that are included on [the module's friends list](https://diem.github.io/move/friends.html).

## Entry Functions

In Sui Move, entry functions are simply functions that can be called by a transactions. They must satisfy the following three requirements:

- Denoted by the keyword `entry`
- have no return value
- (optional) have a mutable reference to an instance of the `TxContext` type in the last parameter

### Transaction Context

Entry functions typically have an instance of `TxContext` as the last parameter. This is a special parameter set by the Sui Move VM, and does not need to be specified by the user calling the function. 

The `TxContext` object contains [essential information](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/sources/tx_context.move) about the transaction used to call the entry function, such as the sender's address, the signer's address, the tx's epoch, etc. 

## Create the `mint` Function 

We can define our minting function in the Hello World example as the following:

```
    public entry fun mint(ctx: &mut TxContext) {
        let object = HelloWorldObject {
            id: object::new(ctx),
            text: string::utf8(b"Hello World!")
        };
        transfer::transfer(object, tx_context::sender(ctx));
    }
```

This function simply creates a new instance of the `HelloWoirldObject` custom type, then uses the Sui system transfer function to send it to the transaction caller. 


