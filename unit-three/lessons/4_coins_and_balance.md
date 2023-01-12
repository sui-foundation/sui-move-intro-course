# Coins and Balance

## The `Coin` Resource

Now we understand how generics work, we can revisit the `Coin` resource from `sui::coin`.  It's [defined](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/sources/coin.move#L29) as the following:

```rust
struct Coin<phantom T> has key, store {
        id: UID,
        balance: Balance<T>
    }
```

The `Coin` resource type is a struct that has a generic type `T` and two fields, `id` and `balance`. `id` is of the type `sui::object::UID`, which we have already seen before. 

`balance` is of the type [`sui::balance::Balance`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/balance.md#0x2_balance_Balance), and is [defined](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/sources/balance.move#L25) as:

```rust 
struct Balance<phantom T> has store {
    value: u64
}
```

### The `phantom` Keyword


`Coin` takes in a generic type `T`, which is passed to `Balance` which also takes in the same generic type `T`. 

However, the `Balance` type does not use the generic type `T` in any of its field, with only an `u64` field denoting the balance value. The generic type `T` then is a phantom generic type, in that it's not used 

this generic type `T` is a `phantom` generic type, in that `T` is not used in a field of the struct that requires it, and is denoted by the keyword `phantom`. This 

For a more in-depth explanation of the `phantom` keyword, please check the [relevant section](https://github.com/move-language/move/blob/main/language/documentation/book/src/generics.md#phantom-type-parameters) of the Move language documentation.


The main use of a phantom generic parameter is in combination with the witness design pattern that we will introduce next. 
