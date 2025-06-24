module best_practice::version;

const PACKAGE_VERSION: u64 = 1;
const ErrVersion: u64 = 0x1;

public fun package_version(): u64 { PACKAGE_VERSION }


public fun assert_version() {
    assert!(PACKAGE_VERSION >= 1,ErrVersion);
}