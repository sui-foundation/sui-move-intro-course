// Copyright (c) 2022, Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// A capabiltiy example for Sui Move, part of the Sui Move intro course:
/// https://github.com/sui-foundation/sui-move-intro-course
/// 
module sui_intro_unit_two::capability {
    use sui::transfer;
    use sui::object::{Self, UID};
    use std::string::{Self, String};
    use sui::tx_context::{Self, TxContext};
    
    // Type that marks Capability to create, update, delete transcripts
    struct TeacherCap has key {
        id:UID
    }

    struct SuperTeacherCap has key{
        id: UID,
    }
  
    struct Transcript has key, store {
        id: UID, 
        history: u8,
        math: u8,
        literature: u8,
    }

    fun init(ctx: &mut TxContext) {
        transfer::transfer(
            SuperTeacherCap {
                id: object::new(ctx),
            },
            tx_context::sender(ctx)
        );
    }

    public entry fun create(
        _: &TeacherCap, 
        history: u8, 
        math: u8, 
        literature: u8, 
        ctx: &mut TxContext
        ) {
        transfer::transfer(
            Transcript {
                id: object::new(ctx),
                history: history,
                math: math,
                literature: literature,
            },
            tx_context::sender(ctx)
        );
    }

    public entry fun update(
        _: &TeacherCap,
        history: u8,
        math: u8,
        literature: u8,
        transcript: &mut Transcript
    ) {
        transcript.math = math;
        transcript.history = history;
        transcript.literature = literature;
    }

    public entry fun delete(
        _: &TeacherCap, transcript: Transcript
    ) {
        let Transcript { id, history: _, math: _, literature: _ } = transcript;
        object::delete(id);
    }

    public entry fun new_teacher(
        _: &SuperTeacherCap,
        to: address
     ) {
        transfer::transfer(
            TeacherCap {
                id: object::new(ctx),
            },
            to
        );
    }
}