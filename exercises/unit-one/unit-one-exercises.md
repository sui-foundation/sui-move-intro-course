# Unit One Exercises

## Q1  

We introduced [abilities](../../unit-one/lessons/3_custom_types_and_abilities.md) in this unit, which are critical to how assets are defined in Move. However, some combinations of the four abilities are illegal in Move due to how the abilities operate, which may produce unsafe or conflicting behavior if allowed. 

Mark the following ability combinations as either legal or illegal:

1. `copy` + `drop`
2. `copy` + `key`
3. `copy` + `store`
4. `drop` + `key`
5. `drop` + `store`
6. `store` + `key`
7. `copy` + `drop` + `store`
8. `copy` + `drop` + `key`
9. `copy` + `key` + `store`
10. `drop` + `key` + `store`
11. `copy` + `drop` + `key` + `store`

For each of the illegal combinations, briefly describe the conflicting behavior that would occur if the combination was allowed. 

*Hint: You can test out these combinations using the compiler.*

## Q2

What's the difference between `sui::transfer::transfer` and `sui::transfer::public_transfer`?

