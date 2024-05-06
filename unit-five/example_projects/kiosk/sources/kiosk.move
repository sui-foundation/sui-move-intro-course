// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

module kiosk::kiosk {
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::tx_context::{TxContext, sender};
    use sui::object::{Self, UID};
    use sui::coin::{Coin};
    use sui::sui::{SUI};
    use sui::transfer_policy::{Self, TransferRequest, TransferPolicy, TransferPolicyCap};
    use sui::package::{Self, Publisher};
    use sui::transfer::{Self};

    public struct TShirt has key, store {
        id: UID,
    }

    public struct KIOSK has drop {}

    fun init(otw: KIOSK, ctx: &mut TxContext) {
        let publisher = package::claim(otw, ctx);
        transfer::public_transfer(publisher, sender(ctx));
    }

    public fun new_tshirt(ctx: &mut TxContext): TShirt {
        TShirt {
            id: object::new(ctx),
        }
    }

    #[allow(lint(share_owned, self_transfer))]
    /// Create new kiosk
    public fun new_kiosk(ctx: &mut TxContext) {
        let (kiosk, kiosk_owner_cap) = kiosk::new(ctx);
        transfer::public_share_object(kiosk);
        transfer::public_transfer(kiosk_owner_cap, sender(ctx));
    }

    /// Place item inside Kiosk
    public fun place(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item: TShirt) {
        kiosk::place(kiosk, cap, item)
    }

    /// Withdraw item from Kiosk
    public fun withdraw(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item_id: object::ID): TShirt {
        kiosk::take(kiosk, cap, item_id)
    }

    /// List item for sale
    public fun list(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item_id: object::ID, price: u64) {
        kiosk::list<TShirt>(kiosk, cap, item_id, price)
    }

    /// Buy listed item
    public fun buy(kiosk: &mut Kiosk, item_id: object::ID, payment: Coin<SUI>): (TShirt, TransferRequest<TShirt>){
        kiosk::purchase(kiosk, item_id, payment)
    }

    /// Confirm the TransferRequest
    public fun confirm_request(policy: &TransferPolicy<TShirt>, req: TransferRequest<TShirt>) {
        transfer_policy::confirm_request(policy, req);
    }

    #[allow(lint(share_owned, self_transfer))]
    /// Create new policy for type `T`
    public fun new_policy(publisher: &Publisher, ctx: &mut TxContext) {
        let (policy, policy_cap) = transfer_policy::new<TShirt>(publisher, ctx);
        transfer::public_share_object(policy);
        transfer::public_transfer(policy_cap, sender(ctx));
    }
}