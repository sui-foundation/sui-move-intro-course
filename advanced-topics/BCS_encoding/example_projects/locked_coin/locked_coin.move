module coins::locked_coin {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    
    const LOCKUP_INTERVALS: u64 = 24 * 60 * 60 * 1000;

    struct Registry has key {
        id: UID,
        cap: TreasuryCap<LOCKED_COIN>
    }

    struct LOCKED_COIN has drop {}

    struct Locked has key {
        balance: Balance<LOCKED_COIN>
    }

    struct Locker has store {
        start_date: u64,
        final_date: u64,
        balance
    }

    // Clock: shared object
    // as immutable
    // address: 0x6
    //
    // 

    /// Withdraw the unlocked amount.
    public fun withdraw(self: &mut Registry, clock: &Clock, ctx: &mut TxContext): Coin<LOCKED_COIN> {
        let locker: Locker = sui::dynamic_field::borrow_mut(&mut self.id, sender(ctx));
        
        let duration = final_date - start_date;
        let passed = clock::timestamp_ms(clock) - start_date;
        let percentage = duration * balance::value(locker.balance) / passed;

        coin::take(&mut locker.balance, percentage, ctx)
    }

    // fun init(otw: LOCKED_COIN, ctx: &mut TxContext) {
    //     // otw to create new currency
    //     Registry { id: object::new(ctx), cap: TreasuryCap<LOCKED_COIN>() }
    // }

    public fun lock_for(_: &AdminCap, self: &mut Registry, recipient: address, amount: u64, final_date: u64, ctx: &mut TxContext) {
        let coin = coin::mint(&mut self.cap, amount, ctx);

        sui::dynamic_field::add(&mut self.id, recipient, Locker {
            start_date: u64,
            final_date: u64,
            coin
        });
    }
}