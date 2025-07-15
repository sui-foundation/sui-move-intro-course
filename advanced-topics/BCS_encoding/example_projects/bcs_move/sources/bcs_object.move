module bcs_move::bcs_object;

use std::ascii;
use sui::bcs;
use sui::event;

public struct Metadata has copy, drop {
    name: ascii::String,
}

public struct BCSObject has copy, drop {
    id: ID,
    owner: address,
    meta: Metadata,
}

public fun object_from_bytes(bcs_bytes: vector<u8>): BCSObject {
    let mut bcs = bcs::new(bcs_bytes);

    // Use `peel_*` functions to peel values from the serialized bytes.
    // Order has to be the same as we used in serialization!
    let (address, owner, meta) = (
        bcs.peel_address(),
        bcs.peel_address(),
        bcs.peel_vec_u8(),
    );
    // Pack a BCSObject struct with the results of serialization
    BCSObject {
        id: address.to_id(),
        owner,
        meta: Metadata { name: meta.to_ascii_string() },
    }
}

public fun emit_object(bcs_bytes: vector<u8>) {
    event::emit(object_from_bytes(bcs_bytes));
}

#[test]
fun test_deserialization() {
    // using Base16 (HEX) encoded string from our JavaScript sample
    // In Move, byte vectors can be defined with `x"<hex>"`
    let bytes =
        x"0000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000a03616161";

    let bcs_object = object_from_bytes(bytes);
    // test against values generated in JavaScript
    assert!(bcs_object.id == @0x5.to_id(), 0);
    assert!(bcs_object.owner == @0xA, 0);
    assert!(bcs_object.meta.name == std::ascii::string(b"aaa"), 0);
}
