// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

// Modified from https://github.com/MystenLabs/sui/blob/main/sui_programmability/examples/nfts/sources/marketplace.move



module marketplace::widget {

    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    public struct Widget has key, store {
        id: UID,
    }

    #[lint_allow(self_transfer)]
    public fun mint(ctx: &mut TxContext) {
        let object = Widget {
            id: object::new(ctx)
        };
        transfer::transfer(object, tx_context::sender(ctx));
    }

}