// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

// The code is modified from here
// https://github.com/MystenLabs/apps/blob/main/kiosk/sources/rules/royalty_rule.move
module kiosk::fixed_royalty_rule;

use sui::coin::Coin;
use sui::sui::SUI;
use sui::transfer_policy::{
    Self,
    TransferPolicy,
    TransferPolicyCap,
    TransferRequest
};

/// The `amount_bp` passed is more than 100%.
const EIncorrectArgument: u64 = 0;
/// The `Coin` used for payment is not enough to cover the fee.
const EInsufficientAmount: u64 = 1;

/// Max value for the `amount_bp`.
const MAX_BPS: u16 = 10_000;

/// The Rule Witness to authorize the policy
public struct Rule has drop {}

/// Configuration for the Rule
public struct Config has drop, store {
    /// Percentage of the transfer amount to be paid as royalty fee
    amount_bp: u16,
    /// This is used as royalty fee if the calculated fee is smaller than
    /// `min_amount`
    min_amount: u64,
}

/// Function that adds a Rule to the `TransferPolicy`.
/// Requires `TransferPolicyCap` to make sure the rules are
/// added only by the publisher of T.
public fun add<T>(
    policy: &mut TransferPolicy<T>,
    cap: &TransferPolicyCap<T>,
    amount_bp: u16,
    min_amount: u64,
) {
    assert!(amount_bp <= MAX_BPS, EIncorrectArgument);
    transfer_policy::add_rule(
        Rule {},
        policy,
        cap,
        Config { amount_bp, min_amount },
    )
}

/// Buyer action: Pay the royalty fee for the transfer.
public fun pay<T: key + store>(
    policy: &mut TransferPolicy<T>,
    request: &mut TransferRequest<T>,
    payment: Coin<SUI>,
) {
    let paid = transfer_policy::paid(request);
    let amount = fee_amount(policy, paid);

    assert!(payment.value() == amount, EInsufficientAmount);

    transfer_policy::add_to_balance(Rule {}, policy, payment);
    transfer_policy::add_receipt(Rule {}, request)
}

/// Helper function to calculate the amount to be paid for the transfer.
/// Can be used dry-runned to estimate the fee amount based on the Kiosk listing
/// price.
public fun fee_amount<T: key + store>(
    policy: &TransferPolicy<T>,
    paid: u64,
): u64 {
    let config: &Config = transfer_policy::get_rule(Rule {}, policy);
    let mut amount = (
        ((paid as u128) * (config.amount_bp as u128) / 10_000) as u64,
    );

    // If the amount is less than the minimum, use the minimum
    if (amount < config.min_amount) {
        amount = config.min_amount
    };

    amount
}
