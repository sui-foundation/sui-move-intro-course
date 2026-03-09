// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

/// A basic object example for Sui Move, part of the Sui Move intro course:
/// https://github.com/sui-foundation/sui-move-intro-course
///
module sui_intro_unit_two::transcript;

use sui::event;

// === Constants ===

// Error code when a non-intended address tries to unpack the transcript wrapper.
const ENotIntendedAddress: u64 = 1;

// === Structs ===

public struct WrappableTranscript has key, store {
    id: UID,
    history: u8,
    math: u8,
    literature: u8,
}

public struct Folder has key {
    id: UID,
    transcript: WrappableTranscript,
    intended_address: address,
}

public struct TeacherCap has key {
    id: UID,
}

public struct TestStruct has drop, store, copy {}

/// Event emitted when a transcript has been requested.
public struct TranscriptRequested has copy, drop {
    wrapper_id: ID,
    requester: address,
    intended_address: address,
}

// === Init ===

/// Called only once on module publish.
fun init(ctx: &mut TxContext) {
    transfer::transfer(
        TeacherCap {
            id: object::new(ctx),
        },
        ctx.sender(),
    )
}

// === Public Functions ===

public fun add_additional_teacher(
    _: &TeacherCap,
    new_teacher_address: address,
    ctx: &mut TxContext,
) {
    transfer::transfer(
        TeacherCap {
            id: object::new(ctx),
        },
        new_teacher_address,
    )
}

#[allow(lint(self_transfer))]
public fun create_wrappable_transcript_object(
    _: &TeacherCap,
    history: u8,
    math: u8,
    literature: u8,
    ctx: &mut TxContext,
) {
    let wrappable_transcript = WrappableTranscript {
        id: object::new(ctx),
        history,
        math,
        literature,
    };
    transfer::public_transfer(wrappable_transcript, ctx.sender())
}

/// Returns the literature score (read-only).
public fun view_score(wrappable_transcript: &WrappableTranscript): u8 {
    wrappable_transcript.literature
}

/// Updates the literature score; requires TeacherCap. Parameter order: mutable object, capability, primitives.
public fun update_score(
    wrappable_transcript: &mut WrappableTranscript,
    _: &TeacherCap,
    score: u8,
) {
    wrappable_transcript.literature = score
}

/// Deletes the transcript object; requires TeacherCap. Parameter order: object, capability.
public fun delete_transcript(
    transcript_object: WrappableTranscript,
    _: &TeacherCap,
) {
    let WrappableTranscript { id, .. } = transcript_object;
    id.delete();
}

public fun request_transcript(
    transcript: WrappableTranscript,
    intended_address: address,
    ctx: &mut TxContext,
) {
    let folder_object = Folder {
        id: object::new(ctx),
        transcript,
        intended_address,
    };
    event::emit(TranscriptRequested {
        wrapper_id: object::id(&folder_object),
        requester: ctx.sender(),
        intended_address,
    });
    transfer::transfer(folder_object, intended_address);
}

#[allow(lint(self_transfer))]
public fun unpack_wrapped_transcript(folder: Folder, ctx: &mut TxContext) {
    assert!(folder.intended_address == ctx.sender(), ENotIntendedAddress);
    let Folder { id, transcript, .. } = folder;
    transfer::transfer(transcript, ctx.sender());
    id.delete();
}
