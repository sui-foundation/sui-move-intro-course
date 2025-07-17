// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

/// A basic Hello World example for Sui Move, part of the Sui Move intro course:
/// https://github.com/sui-foundation/sui-move-intro-course
///
module hello_world::hello_world;

use std::string;

/// An object that contains an arbitrary string
public struct HelloWorldObject has key, store {
    id: UID,
    /// A string contained in the object
    text: string::String,
}

#[lint_allow(self_transfer)]
public fun mint(ctx: &mut TxContext) {
    let object = HelloWorldObject {
        id: object::new(ctx),
        text: b"Hello World!".to_string(),
    };
    transfer::public_transfer(object, ctx.sender());
}
