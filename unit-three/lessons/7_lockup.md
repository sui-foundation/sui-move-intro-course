# Token Lock-up

[clock.move](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/clock.move) module provides timestamp and timing functionalities. We can use it to implement token locking, where the project team can only unlock and retrieve tokens after a sufficiently long period of time has passed since the contract was deployed.

This lesson uses the [code](../example_projects/fungible_tokens/sources/managed.move) from [Unit 3, Lesson 5, Managed Coin case](5_managed_coin.md) as basics.

## Token lock-up treasury

### Construct token treasury

Define a token treasury for storing tokens.

```Rust
    use sui::balance::{Self, Balance};
    use sui::object::{Self, UID};

    struct ManageAdmin has key {
        id: UID
    }

    struct ManageStorage has key, store {
        id: UID,
        manage_balance: Balance<MANAGED>,
    }
```

`ManageStorage` is the treasury for storing tokens, and `ManageAdmin` serve as authority for operating the treasury.

Inside the `init` function, declare the number of tokens stored in the `ManageStorage` treasury.

```Rust
    fun init(witness: MANAGED, ctx: &mut TxContext) {
        // Get a treasury cap for the coin and give it to the transaction sender
        let (treasury_cap, metadata) = coin::create_currency<MANAGED>(witness, 2, b"MANAGED", b"MNG", b"", option::none(), ctx);
        // state the number of tokens held in the treasury
        transfer::share_object(
            ManageStorage {
                id: object::new(ctx),
                manage_balance: coin::mint_balance<MANAGED>(&mut treasury_cap, 1000000), 
            }
        );
        transfer::transfer(
            ManageAdmin {
                id: object::new(ctx),
            },
            tx_context::sender(ctx)
        );
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
    }
```

`ManageStorage` is implemented using `share_object`, but it can also be implemented using other methods.

### Withdraw function

Define a function that requires the `ManageAdmin` permission to withdraw all tokens from `ManageStorage`.

```Rust
    // ---Admin Only---
    public entry fun withdraw_all(storage: &mut ManageStorage, _: &ManageAdmin, ctx: &mut TxContext) {
        let return_coin: Coin<MANAGED> = coin::from_balance(balance::withdraw_all(&mut storage.manage_balance), ctx);
        transfer::public_transfer(return_coin, tx_context::sender(ctx));
    }
```

At this point, the token repository and the functionality to retrieve tokens have been implemented.

