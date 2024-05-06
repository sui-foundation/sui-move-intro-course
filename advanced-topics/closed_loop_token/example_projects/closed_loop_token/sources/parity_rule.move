// Copyright (c) 2022, Sui Foundation
// SPDX-License-Identifier: Apache-2.0

/// An implementation of a simple parity rule for the Closed Loop system. 
///
module closed_loop_token::parity_rule {
    use sui::tx_context::TxContext;
    use sui::token::{Self, TokenPolicy, ActionRequest};

    /// Trying to `verify` but the sender or the recipient is on the denylist.
    const EWrongParity: u64 = 0;

    /// The Rule witness.
    public struct ParityRule has drop {}

    /// Verifies that the sender and the recipient (if set) are not on the
    /// denylist for the given action.
    public fun verify<T>(
        _policy: &TokenPolicy<T>,
        request: &mut ActionRequest<T>,
        ctx: &mut TxContext
    ) {

        let amount = token::amount(request);

        if (amount % 2 == 1) {
            token::add_approval(ParityRule {}, request, ctx);
            return
        };
        
        abort EWrongParity
    }

}