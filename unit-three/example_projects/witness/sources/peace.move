/// Module that defines a generic type `Guardian<T>` which can only be
/// instantiated with a witness.
module witness::peace;

/// Phantom parameter T can only be initialized in the `create_guardian`
/// function. But the types passed here must have `drop`.
public struct Guardian<phantom T: drop> has key, store {
    id: UID,
}

/// This type is the witness resource and is intended to be used only once.
public struct PEACE has drop {}

/// The first argument of this function is an actual instance of the
/// type T with `drop` ability. It is dropped as soon as received.
public fun create_guardian<T: drop>(_: T, ctx: &mut TxContext): Guardian<T> {
    Guardian { id: object::new(ctx) }
}

/// Module initializer is the best way to ensure that the
/// code is called only once. With `Witness` pattern it is
/// often the best practice.
fun init(witness: PEACE, ctx: &mut TxContext) {
    transfer::public_transfer(create_guardian(witness, ctx), ctx.sender())
}
