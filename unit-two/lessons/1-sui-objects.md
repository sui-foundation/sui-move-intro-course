# Sui Objects

## Introduction

As we briefly touched on this concept in [Unit 1 Lesson 4](../../unit-one/lessons/4_custom_types_and_abilities.md#custome-types-and-abilities). Sui objects is a unique data type exists in Sui Move. It all starts from the `struct` type.

Let's first start with an example of your school transcript

```rust
struct Transcript {
    english: u8,
    math: u8,
    programming: u8,
}
```

The above struct is a struct for recording your school grades. In order to make a Sui Object in Sui Move, you just need to add `key` abilities, and additional `id: UID` field inside the struct. If you need more context regarding of this part, you can refer back to [Unit 1 Lesson 4](../../unit-one/lessons/4_custom_types_and_abilities.md#custome-types-and-abilities).

```rust
struct TranscriptObject has key {
    id: UID,
    english: u8,
    math: u8,
    programming: u8,
}
```

