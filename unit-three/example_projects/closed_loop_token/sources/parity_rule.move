// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

/// An implementation of a simple parity rule for the closed loop standard.
module closed_loop_token::parity_rule;

use sui::token::{Self, TokenPolicy, ActionRequest};

/// Trying to `verify` but the parity is not correct for the action.
const EWrongParity: u64 = 0;

/// The Rule witness.
public struct ParityRule has drop {}

/// Verifies that the sender and the recipient (if set) are not on the denylist
/// for the given action.
public fun verify<T>(
    _: &TokenPolicy<T>,
    request: &mut ActionRequest<T>,
    ctx: &mut TxContext,
) {
    if (request.amount() % 2 == 1) {
        token::add_approval(ParityRule {}, request, ctx);
        return
    };
    abort EWrongParity
}
