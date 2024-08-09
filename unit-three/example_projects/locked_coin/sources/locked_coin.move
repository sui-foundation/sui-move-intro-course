// Copyright (c) 2022, Sui Foundation
// SPDX-License-Identifier: Apache-2.0

/// Basic token locking and vesting example for Move on Sui. 
/// Part of the Sui Move intro course:
/// https://github.com/sui-foundation/sui-move-intro-course
/// 
module locked_coin::locked_coin {
    use std::option;
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{sender, TxContext};
    use sui::coin::{Self, TreasuryCap};
    use sui::balance::{Self, Balance};
    use sui::clock::{Self, Clock};
 
    /// Transferable object for storing the vesting coins
    ///
    struct Locker has key, store {
        id: UID,
        start_date: u64,
        final_date: u64,
        original_balance: u64,
        current_balance: Balance<LOCKED_COIN>

    }

    /// Witness
    struct LOCKED_COIN has drop {}

    #[lint_allow(self_transfer)]
    /// Withdraw the available vested amount assuming linear vesting
    ///
    public fun withdraw_vested(locker: &mut Locker, clock: &Clock, ctx: &mut TxContext){
        let total_duration = locker.final_date - locker.start_date;
        let elapsed_duration = clock::timestamp_ms(clock) - locker.start_date;
        let total_vested_amount = if (elapsed_duration > total_duration) {
            locker.original_balance
        } else {
            locker.original_balance * elapsed_duration / total_duration
        };
        let available_vested_amount = total_vested_amount - (locker.original_balance-balance::value(&locker.current_balance));
        transfer::public_transfer(coin::take(&mut locker.current_balance, available_vested_amount, ctx), sender(ctx))
    }

    fun init(otw: LOCKED_COIN, ctx: &mut TxContext){
        let (treasury_cap, metadata) = coin::create_currency<LOCKED_COIN>(otw, 8, b"LOCKED COIN", b"LOCK", b"", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, sender(ctx))
    }

    /// Mints and transfers a locker object with the input amount of coins and specified vesting schedule
    /// 
    public fun locked_mint(treasury_cap: &mut TreasuryCap<LOCKED_COIN>, recipient: address, amount: u64, lock_up_duration: u64, clock: &Clock, ctx: &mut TxContext){
        
        let coin = coin::mint(treasury_cap, amount, ctx);
        let start_date = clock::timestamp_ms(clock);
        let final_date = start_date + lock_up_duration;

        transfer::public_transfer(Locker {
            id: object::new(ctx),
            start_date: start_date,
            final_date: final_date,
            original_balance: amount,
            current_balance: coin::into_balance(coin)
        }, recipient);
    }
}