// Copyright (c) 2022, Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// A unittest example for Sui Move, part of the Sui Move intro course:
/// https://github.com/sui-foundation/sui-move-intro-course
/// 
module sui_intro_unit_two::unittest {
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

    public fun get_math(self: &Transcript): u8 {
        self.math
    }

    // === test ===

    #[test]
    fun test_teacher() {
        use sui::test_scenario;
        let super_teacher = @0x1111;
        let teacher = @0x1234;
        
        // first transaction
        let scenario_val = test_scenario::begin(super_teacher);
        let scenario = &mut scenario_val;
        {
                init(test_scenario::ctx(scenario));
        }

        // second transaction
        test_scenario::next_tx(scenario, super_teacher);
        {
            let superTeacherCap = test_scenario::take_from_sender<SuperTeacherCap>(scenario);
            new_teacher(&superTeacherCap, teacher);
            test_scenario::return_to_sender(superTeacherCap);
        }

        // third transaction
        test_scenario::next_tx(scenario, teacher);
        {
            let teacherCap = test_scenario::take_from_sender<TeacherCap>(scenario);
            create(&teacherCap, 98, 99, 100, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, teacherCap);
        }

        // fourth transaction
        test_scenario::next_tx(scenario, teacher);
        {
            let transcript = test_scenario::take_from_sender<Transcript>(scenario);
            assert!(get_math(&transcript) == 99);
            test_scenario::return_to_sender(scenario, transcript);
        };
        
        // final
        test_scenario::end(scenario_val);
    }
}