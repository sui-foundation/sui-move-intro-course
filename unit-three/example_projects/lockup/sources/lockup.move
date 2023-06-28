// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Example coin with a trusted manager responsible for minting/burning (e.g., a stablecoin)
/// By convention, modules defining custom coin types use upper case names, in contrast to
/// ordinary modules, which use camel case.
module lockup::managed {
    use std::option;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::balance::{Self, Balance};
    use sui::object::{Self, UID};
    use sui::clock::{Self, Clock};

    /// Name of the coin. By convention, this type has the same name as its parent module
    /// and has no fields. The full type of the coin defined by this module will be `COIN<MANAGED>`.
    struct MANAGED has drop {}

    struct ManageAdmin has key {
        id: UID
    }

    struct ManageStorage has key, store {
        id: UID,
        manage_balance: Balance<MANAGED>,
        start: u64,
    }

    struct TimeCap has key {
        id: UID,
    }

    // one day in millisecond
    const DAY_IN_MS: u64 = 86_400_000;

    // Errors
    const ENotStart: u64 = 0;
    const EStillClose: u64 = 1;


    /// Register the managed currency to acquire its `TreasuryCap`. Because
    /// this is a module initializer, it ensures the currency only gets
    /// registered once.
    fun init(witness: MANAGED, ctx: &mut TxContext) {
        // Get a treasury cap for the coin and give it to the transaction sender
        let (treasury_cap, metadata) = coin::create_currency<MANAGED>(witness, 2, b"MANAGED", b"MNG", b"", option::none(), ctx);
        // state the number of tokens held in the treasury
        transfer::share_object(
            ManageStorage {
                id: object::new(ctx),
                manage_balance: coin::mint_balance<MANAGED>(&mut treasury_cap, 1000000),
                start: 0,
            }
        );
        transfer::transfer(
            ManageAdmin {
                id: object::new(ctx),
            },
            tx_context::sender(ctx)
        );
        transfer::transfer(
            TimeCap {
                id: object::new(ctx),
            },
            tx_context::sender(ctx)
        );
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
    }

    // ---Admin Only---
    public entry fun withdraw_all(storage: &mut ManageStorage, _: &ManageAdmin, clock_object: &Clock, ctx: &mut TxContext) {
        assert!(storage.start > 0, ENotStart);
        assert!(clock::timestamp_ms(clock_object) >= storage.start + DAY_IN_MS * 365 * 3, EStillClose);
        let return_coin: Coin<MANAGED> = coin::from_balance(balance::withdraw_all(&mut storage.manage_balance), ctx);
        transfer::public_transfer(return_coin, tx_context::sender(ctx));
    }

    public entry fun start_timing(storage: &mut ManageStorage, time_cap: TimeCap, clock_object: &Clock) {
        storage.start = clock::timestamp_ms(clock_object);
        let TimeCap { id } = time_cap;
        object::delete(id);
    }

    /// Manager can mint new coins
    public entry fun mint(
        treasury_cap: &mut TreasuryCap<MANAGED>, amount: u64, recipient: address, ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx)
    }

    /// Manager can burn coins
    public entry fun burn(treasury_cap: &mut TreasuryCap<MANAGED>, coin: Coin<MANAGED>) {
        coin::burn(treasury_cap, coin);
    }

    #[test_only]
    /// Wrapper of module initializer for testing
    public fun test_init(ctx: &mut TxContext) {
        init(MANAGED {}, ctx)
    }
}
