// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

// The code is taken here
// https://github.com/MystenLabs/apps/blob/main/kiosk/docs/creating_a_rule_guide.md#rule-structure-dummy
module kiosk::dummy_rule;

use sui::coin::Coin;
use sui::sui::SUI;
use sui::transfer_policy::{
    Self as policy,
    TransferPolicy,
    TransferPolicyCap,
    TransferRequest
};

/// The Rule Witness; has no fields and is used as a
/// static authorization method for the rule.
public struct Rule has drop {}

/// Configuration struct with any fields (as long as it
/// has `drop`). Managed by the Rule module.
public struct Config has drop, store {}

/// Function that adds a Rule to the `TransferPolicy`.
/// Requires `TransferPolicyCap` to make sure the rules are
/// added only by the publisher of T.
public fun set<T>(policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>) {
    policy::add_rule(Rule {}, policy, cap, Config {})
}

/// Action function - perform a certain action (any, really)
/// and pass in the `TransferRequest` so it gets the Receipt.
/// Receipt is a Rule Witness, so there's no way to create
/// it anywhere else but in this module.
///
/// This example also illustrates that Rules can add Coin<SUI>
/// to the balance of the TransferPolicy allowing creators to
/// collect fees.
public fun pay<T>(
    policy: &mut TransferPolicy<T>,
    request: &mut TransferRequest<T>,
    payment: Coin<SUI>,
) {
    policy::add_to_balance(Rule {}, policy, payment);
    policy::add_receipt(Rule {}, request);
}
