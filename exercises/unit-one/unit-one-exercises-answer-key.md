# Unit One Exercises Answer Key

## Q1

1. `copy` + `drop`: legal
2. `copy` + `key`: illegal, `copy` contradicts `key`
3. `copy` + `store`: legal
4. `drop` + `key`: illegal, `drop` contradicts `key`
5. `drop` + `store`: legal
6. `store` + `key`: legal
7. `copy` + `drop` + `store`: legal
8. `copy` + `drop` + `key`: illegal, `drop` contradicts `key`
9. `copy` + `key` + `store`: illegal, `copy` contradicts `key`
10. `drop` + `key` + `store`: illegal, `drop` contradicts `key`
11. `copy` + `drop` + `key` + `store`: illegal, `drop` contradicts `key`

## Q2

`transfer` require the object to have `key`, and the object must be defined in the same module where `transfer` is invoked.

`public_transfer` requires the object to be transferred to have both the `key` and the `store` abilities, but it can be invoked outside of the module where the object is defined.
