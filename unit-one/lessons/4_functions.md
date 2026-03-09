# Functions

In this section, we will introduce functions in Sui Move and write our first Sui Move function as a part of the Hello World example.

## Function Visibility

Sui Move functions have three types of visibility:

- **private**: the default; the function can only be called from within the same module
- **public**: the function can be called from any module (and can be used as a transaction entry point or composed in PTBs)
- **public(package)**: the function can only be called from modules in the same package (use this instead of the deprecated `public(friend)`)

**Entry functions** are transaction endpoints: they are denoted with the `entry` keyword, must have no return value, and are callable directly by transactions. Do not combine `public` and `entry` on the same function—use one or the other.

## Return Value

The return type of a function is specified in the function signature after the function parameters, separated by a colon.

A function's last line (of execution) without a semicolon is the return value.

Example:

```move
public fun addition (a: u8, b: u8): u8 {
    a + b
}
```


## Transaction Context

Functions called directly through a transaction typically have an instance of `TxContext` as the last parameter. This is a special parameter set by the Sui Move VM and does not need to be specified by the user calling the function.

The `TxContext` object contains [essential information](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/tx_context.move) about the transaction used to call the entry function, such as the sender's address, the tx's digest ID, the tx's epoch, etc.

## Create the `mint` Function

We define the minting function as an **entry** function so it can be called directly by a transaction. Entry functions must have no return value:

```move
entry fun mint(ctx: &mut TxContext) {
    let object = HelloWorldObject {
        id: object::new(ctx),
        text: b"Hello World!".to_string(),
    };
    transfer::public_transfer(object, ctx.sender());
}
```

This function creates a new `HelloWorldObject` and uses the Sui framework's `public_transfer` to send it to the transaction sender.
