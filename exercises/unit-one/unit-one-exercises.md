# Unit One Exercises

## Q1  

We introduced [abilities](../../unit-one/lessons/3_custom_types_and_abilities.md) in this unit, which are critical to how assets are defined in Move. However, some combinations of the four abilities are illegal in Move due to how the abilities operate, which may produce unsafe or conflicting behavior if allowed. 

Mark the following ability combinations as either legal or illegal:

1. Copy + Drop
2. Copy + Key
3. Copy + Store
4. Drop + Key
5. Drop + Store
6. Store + Key
7. Copy + Drop + Store
8. Copy + Drop + Key
9. Copy + Key + Store
10. Drop + Key + Store
11. Copy + Drop + Key + Store

For each of the illegal combinations, briefly describe the conflicting behavior that would occur if the combination was allowed. 

*Hint: You can test out these combinations using the compiler.*

## Q2

What's the difference between `sui::transfer::transfer` and `sui::transfer::public_transfer`?

