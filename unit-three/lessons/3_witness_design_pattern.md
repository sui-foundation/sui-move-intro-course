# The Witness Design Pattern

Next, we need to understand the witness pattern to peek under the hood of how a fungible token is implemented in Sui Move. 

Witness is a design pattern used to prove that the a resource or type in question, `A`, can be initiated only once after the ephemeral `witness` resource has been consumed. The `witness` resource must be immediately consumed or dropped after use, ensuring that it cannot be reused to create multiple instances of `A`.

## Witness Pattern Example

In the below example, the `witness` resource is `PEACE`, while the type `A` that we want to control instantiation of is `Guardian`. 

The `witness` resource type must have the `drop` keyword, so that this resource can be dropped after being passed into a function. We see that the instance of `PEACE` resource is passed into the `create_guardian` method and dropped (note the underscore before `witness`), ensuring that only one instance of `Guardian` can be created.

```rust
    /// Module that defines a generic type `Guardian<T>` which can only be
    /// instantiated with a witness.
    module examples::peace {
        use sui::object::{Self, UID};
        use sui::transfer;
        use sui::tx_context::{Self, TxContext};

        /// Phantom parameter T can only be initialized in the `create_guardian`
        /// function. But the types passed here must have `drop`.
        struct Guardian<phantom T: drop> has key, store {
            id: UID
        }

        /// This type is the witness resource and is intended to be used only once.
        struct PEACE has drop {}

        /// The first argument of this function is an actual instance of the
        /// type T with `drop` ability. It is dropped as soon as received.
        public fun create_guardian<T: drop>(
            _witness: T, ctx: &mut TxContext
        ): Guardian<T> {
            Guardian { id: object::new(ctx) }
        }

        /// Module initializer is the best way to ensure that the
        /// code is called only once. With `Witness` pattern it is
        /// often the best practice.
        fun init(witness: PEACE, ctx: &mut TxContext) {
            transfer::transfer(
                create_guardian(witness, ctx),
                tx_context::sender(ctx)
            )
        }
    }
```

*The example above is modified from the book [Sui Move by Example](https://examples.sui.io/patterns/witness.html) by [Damir Shamanaev](https://github.com/damirka).*

### The `phantom` Keyword

In the above example, we want the `Guardian` type to have the `key` and `store` abilities, so that it's an asset and is transferrable and persistent in storage. 

However, we need to 

`Coin` takes in a generic type `T`, which is passed to `Balance` which also takes in the same generic type `T`. 

However, the `Balance` type does not use the generic type `T` in any of its field, with only an `u64` field denoting the balance value. The generic type `T` then is a phantom generic type, in that it's not used 

this generic type `T` is a `phantom` generic type, in that `T` is not used in a field of the struct that requires it, and is denoted by the keyword `phantom`. This 

For a more in-depth explanation of the `phantom` keyword, please check the [relevant section](https://github.com/move-language/move/blob/main/language/documentation/book/src/generics.md#phantom-type-parameters) of the Move language documentation.

## One Time Witness

One Time Witness (OTW) is a sub-pattern of the Witness pattern, where we utilize the module `init` function to ensure that there is only one instance of the `witness` resource created (so type `A` is guaranteed to be a singleton). 

In Sui Move a type is considered an OTW if its definition has the following properties:

- The type is named after the module but uppercased
- The type only has the `drop` ability

To get an instance of this type, you need to add it as the first argument to the module `init` function as in the above example. The Sui runtime will then generate the OTW struct automatically at module publish time. 

The above example uses the One Time Witness design pattern to guarantee that `Guardian` is a singtleton.