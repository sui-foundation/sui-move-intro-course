module best_practice::best_practice;
use best_practice::version::assert_version;

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
    assert_version();
    c.value = c.value + 1;
}