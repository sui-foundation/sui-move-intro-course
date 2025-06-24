module counter::counter;

public struct Counter has key {
    id: UID,
    value: u64,
}

fun init(ctx: &mut TxContext) {
    transfer::share_object(Counter {
        id: object::new(ctx),
        value: 0,
    })
}

public fun increment(c: &mut Counter) {
    c.value = c.value + 1;
}

public fun decreament(c: &mut Counter) {
    c.value = c.value - 1;
}