// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0

/// A basic object example for Sui Move, part of the Sui Move intro course:
/// https://github.com/sui-foundation/sui-move-intro-course
///
module sui_intro_unit_two::transcript;

use sui::event;

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

/// Event marking when a transcript has been requested
public struct TranscriptRequestEvent has copy, drop {
    // The Object ID of the transcript wrapper
    wrapper_id: ID,
    // The requester of the transcript
    requester: address,
    // The intended address of the transcript
    intended_address: address,
}

// Error code for when a non-intended address tries to unpack the transcript
// wrapper
const ENotIntendedAddress: u64 = 1;

/// Module initializer is called only once on module publish.
fun init(ctx: &mut TxContext) {
    transfer::transfer(
        TeacherCap {
            id: object::new(ctx),
        },
        ctx.sender(),
    )
}

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

// You are allowed to retrieve the score but cannot modify it
public fun view_score(wrappable_transcript: &WrappableTranscript): u8 {
    wrappable_transcript.literature
}

// You are allowed to view and edit the score but not allowed to delete it
public fun update_score(
    _: &TeacherCap,
    wrappable_transcript: &mut WrappableTranscript,
    score: u8,
) {
    wrappable_transcript.literature = score
}

// You are allowed to do anything with the score, including view, edit, delete
// the entire transcript itself.
public fun delete_transcript(
    _: &TeacherCap,
    transcript_object: WrappableTranscript,
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
    event::emit(TranscriptRequestEvent {
        wrapper_id: folder_object.id.to_inner(),
        requester: ctx.sender(),
        intended_address,
    });
    // e transfer the wrapped transcript object directly to the intended address
    transfer::transfer(folder_object, intended_address);
}

#[allow(lint(self_transfer))]
public fun unpack_wrapped_transcript(folder: Folder, ctx: &mut TxContext) {
    // Check that the person unpacking the transcript is the intended viewer
    assert!(folder.intended_address == ctx.sender(), ENotIntendedAddress);
    let Folder { id, transcript, .. } = folder;
    transfer::transfer(transcript, ctx.sender());
    id.delete();
}
