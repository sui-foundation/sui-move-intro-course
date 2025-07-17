// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

// Modified from
// https://github.com/MystenLabs/sui/blob/main/sui_programmability/examples/nfts/sources/marketplace.move
module marketplace::widget;

public struct Widget has key, store {
    id: UID,
}

#[lint_allow(self_transfer)]
public fun mint(ctx: &mut TxContext) {
    let object = Widget {
        id: object::new(ctx),
    };
    transfer::public_transfer(object, ctx.sender());
}
