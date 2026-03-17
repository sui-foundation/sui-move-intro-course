// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

/// A basic Hello World example for Sui Move (Move 2024), part of the Sui Move intro course.
module hello_world::hello_world;

use std::string;

/// An object that contains an arbitrary string.
public struct HelloWorldObject has key {
    id: UID,
    /// The string stored in the object.
    text: string::String,
}

/// Mints a new HelloWorldObject and transfers it to the transaction sender.
#[lint_allow(self_transfer)]
entry fun mint(ctx: &mut TxContext) {
    let object = HelloWorldObject {
        id: object::new(ctx),
        text: b"Hello World!".to_string(),
    };
    transfer::transfer(object, ctx.sender());
}
