// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

#[test_only]
module fungible_tokens::managed_tests {

    use fungible_tokens::managed::{Self, MANAGED};
    use sui::coin::{Coin, TreasuryCap};
    use sui::test_scenario::{Self, next_tx, ctx};

    #[test]
    fun mint_burn() {
        // Initialize a mock sender address
        let addr1 = @0xA;

        // Begins a multi transaction scenario with addr1 as the sender
        let scenario = test_scenario::begin(addr1);
        
        // Run the managed coin module init function
        {
            managed::test_init(ctx(&mut scenario))
        };

        // Mint a `Coin<MANAGED>` object
        next_tx(&mut scenario, addr1);
        {
            let treasurycap = test_scenario::take_from_sender<TreasuryCap<MANAGED>>(&scenario);
            managed::mint(&mut treasurycap, 100, addr1, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_address<TreasuryCap<MANAGED>>(addr1, treasurycap);
        };

        // Burn a `Coin<MANAGED>` object
        next_tx(&mut scenario, addr1);
        {
            let coin = test_scenario::take_from_sender<Coin<MANAGED>>(&scenario);
            let treasurycap = test_scenario::take_from_sender<TreasuryCap<MANAGED>>(&scenario);
            managed::burn(&mut treasurycap, coin);
            test_scenario::return_to_address<TreasuryCap<MANAGED>>(addr1, treasurycap);
        };

        // Cleans up the scenario object
        test_scenario::end(scenario);
    }

}