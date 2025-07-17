// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

#[test_only]
module fungible_tokens::managed_tests;

use fungible_tokens::managed::{Self, MANAGED};
use sui::coin::{Coin, TreasuryCap};
use sui::test_scenario::{Self, next_tx, ctx};

#[test]
fun mint_burn() {
    // Initialize a mock sender address
    let addr1 = @0xA;

    // Begins a multi transaction scenario with addr1 as the sender
    let mut scenario = test_scenario::begin(addr1);

    // Run the managed coin module init function
    {
        managed::test_init(scenario.ctx())
    };

    // Mint a `Coin<MANAGED>` object
    scenario.next_tx(addr1);
    {
        let mut treasurycap = scenario.take_from_sender<TreasuryCap<MANAGED>>();
        managed::mint(&mut treasurycap, 100, addr1, scenario.ctx());
        test_scenario::return_to_address<TreasuryCap<MANAGED>>(
            addr1,
            treasurycap,
        );
    };

    // Burn a `Coin<MANAGED>` object
    next_tx(&mut scenario, addr1);
    {
        let coin = scenario.take_from_sender<Coin<MANAGED>>();
        let mut treasurycap = scenario.take_from_sender<TreasuryCap<MANAGED>>();
        managed::burn(&mut treasurycap, coin);
        test_scenario::return_to_address<TreasuryCap<MANAGED>>(
            addr1,
            treasurycap,
        );
    };

    // Cleans up the scenario object
    scenario.end();
}
