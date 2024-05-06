// Copyright (c) 2022, Sui Foundation
// SPDX-License-Identifier: Apache-2.0

module closed_loop_token::parity {
    use std::option;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use std::string::utf8;
    use sui::tx_context::{Self, TxContext};
    use sui::token::{Self, TokenPolicy};
    use 0x0::parity_rule::{Self, ParityRule};


    /// Name of the coin. By convention, this type has the same name as its parent module
    /// and has no fields. The full type of the coin defined by this module will be `COIN<PARITY>`.
    public struct PARITY has drop {}

    /// Register the PARITY currency to acquire its `TreasuryCap`. Because
    /// this is a module initializer, it ensures the currency only gets
    /// registered once.
    fun init(witness: PARITY, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<PARITY>(witness, 2, b"PARITY", b"MNG", b"", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        let (mut policy, policy_cap) = token::new_policy<PARITY>(&treasury_cap, ctx);
        token::add_rule_for_action<PARITY, ParityRule>(&mut policy, &policy_cap, utf8(b"from_coin"), ctx);
        token::share_policy(policy);
        transfer::public_transfer(policy_cap,tx_context::sender(ctx));
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx))
    }

    /// Manager can mint new coins
    public fun mint(
        treasury_cap: &mut TreasuryCap<PARITY>, amount: u64, recipient: address, ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx)
    }

    public fun treasure_cap_mint_token(
        treasury_cap: &mut TreasuryCap<PARITY>, amount: u64, ctx: &mut TxContext
    ) {
        let _coin = coin::mint(treasury_cap, amount, ctx);
        let (_token, _request) = token::from_coin(_coin, ctx);
        token::confirm_with_treasury_cap(treasury_cap, _request, ctx);
        token::keep(_token, ctx)
    }

    public fun policy_mint_token(treasury_cap: &mut TreasuryCap<PARITY>, policy: &TokenPolicy<PARITY>, amount: u64, ctx: &mut TxContext
    ) {
        let _coin = coin::mint(treasury_cap, amount, ctx);
        let (_token, mut _request) = token::from_coin(_coin, ctx);
        parity_rule::verify(policy, &mut _request, ctx);
        token::confirm_request(policy, _request, ctx);
        token::keep(_token, ctx)
    }    

    /// Manager can burn coins
    public fun burn(treasury_cap: &mut TreasuryCap<PARITY>, coin: Coin<PARITY>) {
        coin::burn(treasury_cap, coin);
    }

}
