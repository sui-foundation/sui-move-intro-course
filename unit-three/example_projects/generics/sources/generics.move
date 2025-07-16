// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Basic generics example for Sui Move
/// A part of the Sui Move intro course:
module generics::generics;

public struct Box<T: store> has key, store {
    id: UID,
    value: T,
}

public struct SimpleBox has key, store {
    id: UID,
    value: u8,
}

public struct PhantomBox<phantom T: drop> has key {
    id: UID,
}

#[lint_allow(self_transfer)]
public fun create_box<T: store>(value: T, ctx: &mut TxContext) {
    transfer::public_transfer(
        Box<T> { id: object::new(ctx), value },
        ctx.sender(),
    )
}

#[lint_allow(self_transfer)]
public fun create_simple_box(value: u8, ctx: &mut TxContext) {
    transfer::public_transfer(
        SimpleBox { id: object::new(ctx), value },
        ctx.sender(),
    )
}

public fun create_phantom_box<T: drop>(_value: T, ctx: &mut TxContext) {
    transfer::transfer(
        PhantomBox<T> { id: object::new(ctx) },
        ctx.sender(),
    )
}
