module bcs_move::bcs_object {

    use sui::bcs;
    use sui::object::{Self, ID};
    use sui::event;

    struct Metadata has drop, copy {
        name: std::ascii::String
    }

    struct BCSObject has drop, copy {
        id: ID,
        owner: address,
        meta: Metadata
    }

    public fun object_from_bytes(bcs_bytes: vector<u8>): BCSObject {

        let bcs = bcs::new(bcs_bytes);

        // Use `peel_*` functions to peel values from the serialized bytes. 
        // Order has to be the same as we used in serialization!
        let (id, owner, meta) = (
        bcs::peel_address(&mut bcs), bcs::peel_address(&mut bcs), bcs::peel_vec_u8(&mut bcs)
        );
        // Pack a BCSObject struct with the results of serialization
        BCSObject { id: object::id_from_address(id), owner, meta: Metadata {name: std::ascii::string(meta)}  } }

    public entry fun emit_object(bcs_bytes: vector<u8>) {
        event::emit(object_from_bytes(bcs_bytes));
    }

    #[test]
    fun test_deserialization() {
        // using Base16 (HEX) encoded string from our JavaScript sample
        // In Move, byte vectors can be defined with `x"<hex>"`
        let bytes = x"0000000000000000000000000000000000000005000000000000000000000000000000000000000a03616161";
        
        let bcs_object = object_from_bytes(copy bytes);
        // test against values generated in JavaScript
        
        assert!(bcs_object.id == object::id_from_address(@0x0000000000000000000000000000000000000005), 0);
        assert!(bcs_object.owner == @0x000000000000000000000000000000000000000a, 0);
        assert!(bcs_object.meta.name == std::ascii::string(b"aaa"), 0);
    } 
}


