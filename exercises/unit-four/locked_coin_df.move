module locked_coin::locked_coin_df {
    use std::option;
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{sender, TxContext};
    use sui::coin::{Self, TreasuryCap, CoinMetadata};
    use sui::balance::{Self, Balance};
    use sui::clock::{Self, Clock};

    /// Shared objected used to attach the lockers 
    /// 
    public struct Registry has key {
        id: UID,
        metadata: CoinMetadata<LOCKED_COIN>
    }

    public struct LOCKED_COIN has drop {}

    public struct Locker has store {
        start_date: u64,
        final_date: u64,
        original_balance: u64,
        balance: Balance<LOCKED_COIN>

    }

    /// Withdraw the available vested amount assuming linear vesting
    ///
    public fun withdraw_vested(self: &mut Registry, clock: &Clock, ctx: &mut TxContext){
        let locker: &mut Locker = sui::dynamic_field::borrow_mut(&mut self.id, sender(ctx));
        let total_duration = locker.final_date - locker.start_date;
        let elapsed_duration = clock::timestamp_ms(clock) - locker.start_date;
        let total_vested_amount = if (elapsed_duration > total_duration) {
            locker.original_balance
        } else {
            locker.original_balance * elapsed_duration / total_duration
        };
        // let total_vested_amount = locker.original_balance * percentage_unlocked;
        let available_vested_amount = total_vested_amount - (locker.original_balance-balance::value(&locker.balance));
        transfer::public_transfer(coin::take(&mut locker.balance, available_vested_amount, ctx), sender(ctx))
    }

    fun init(otw: LOCKED_COIN, ctx: &mut TxContext){
        let (treasury_cap, metadata) = coin::create_currency<LOCKED_COIN>(otw, 8, b"LOCKED COIN", b"LOCK", b"", option::none(), ctx);
        //transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, sender(ctx));
        transfer::share_object(Registry { id: object::new(ctx), metadata: metadata })
    }

    public fun locked_mint(treasury_cap: &mut TreasuryCap<LOCKED_COIN>, self: &mut Registry, recipient: address, amount: u64, lock_up_duration: u64, clock: &Clock, ctx: &mut TxContext){
        
        let coin = coin::mint(treasury_cap, amount, ctx);
        let start_date = clock::timestamp_ms(clock);
        let final_date = start_date + lock_up_duration;

        sui::dynamic_field::add(&mut self.id, recipient, Locker {
            start_date: start_date,
            final_date: final_date,
            original_balance: amount,
            balance: coin::into_balance(coin)
        });
    }
}