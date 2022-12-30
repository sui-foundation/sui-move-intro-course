// Copyright (c) 2022, Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// A event example for Sui Move, part of the Sui Move intro course:
/// https://github.com/sui-foundation/sui-move-intro-course
/// 
module sui_intro_unit_two::event {
    use sui::transfer;
    use sui::object::{Self, UID};
    use std::string::{Self, String};
    use sui::tx_context::{Self, TxContext};
    use sui::event;
    
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

    // === event functions ===
    struct SuperTeacherCreated has copy, drop {
        id: ID
    }

    struct CreateTranscript has copy, drop {
        id: ID,
        history: u8,
        math: u8,
        literature: u8
    }

    struct UpdateTranscript has copy, drop {
        id: ID,
        history: u8,
        math: u8,
        literature: u8
    }

    struct DeleteTranscript has copy, drop {
        id: ID,
        history: u8,
        math: u8,
        literature: u8
    }

    struct CreateTeacherCap has copy, drop {
        id: ID,
        teacher_address: address,
    }

    // === functions ===

    fun init(ctx: &mut TxContext) {
        let id = object::new(ctx);
        event::emit(
            SuperTeacherCreated {
                id: object::uid_to_inner(&id),
            }
        );
        transfer::transfer(
            SuperTeacherCap {
                id: id,
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
        let id = object::new(ctx);
        event::emit(CreateTranscript {
            id: object::udi_to_inner(&id),
            history: history,
            math: math,
            literature: literature
        });
        transfer::transfer(
            Transcript {
                id: id,
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
        event::emit(UpdateTranscript {
            id: object::udi_to_inner(&transcript.id),
            history: history,
            math: math,
            literature: literature
        });
        transcript.math = math;
        transcript.history = history;
        transcript.literature = literature;
    }

    public entry fun delete(
        _: &TeacherCap, transcript: Transcript
    ) {
        let Transcript { id, history, math, literature } = transcript;
        event::emit(DeleteTranscript {
            id: object::udi_to_inner(&id),
            history: history,
            math: math,
            literature: literature
        });
        object::delete(id);
    }

    public entry fun new_teacher(
        _: &SuperTeacherCap,
        to: address
     ) {
        let id = object::new(ctx);
        event::emit(CreateTeacherCap {
            id: object::udi_to_inner(&id),
            teacher_address: to,
        });
        transfer::transfer(
            TeacherCap {
                id: id,
            },
            to
        )
    }
}