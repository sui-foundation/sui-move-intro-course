// Copyright (c) 2022, Sui Foundation
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

public struct TestStruct has drop, store, copy {
    //id: UID,
}

/// Event marking when a transcript has been requested
public struct TranscriptRequestEvent has copy, drop {
    // The Object ID of the transcript wrapper
    wrapper_id: ID,
    // The requester of the transcript
    requester: address,
    // The intended address of the transcript
    intended_address: address,
}

// Error code for when a non-intended address tries to unpack the transcript wrapper
const ENotIntendedAddress: u64 = 1;

/// Module initializer is called only once on module publish.
fun init(ctx: &mut TxContext) {
    transfer::transfer(
        TeacherCap {
            id: object::new(ctx),
        },
        tx_context::sender(ctx),
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
    let wrappableTranscript = WrappableTranscript {
        id: object::new(ctx),
        history,
        math,
        literature,
    };
    transfer::transfer(wrappableTranscript, tx_context::sender(ctx))
}

// You are allowed to retrieve the score but cannot modify it
public fun view_score(transcriptObject: &WrappableTranscript): u8 {
    transcriptObject.literature
}

// You are allowed to view and edit the score but not allowed to delete it
public fun update_score(_: &TeacherCap, transcriptObject: &mut WrappableTranscript, score: u8) {
    transcriptObject.literature = score
}

// You are allowed to do anything with the score, including view, edit, delete the entire transcript itself.
public fun delete_transcript(_: &TeacherCap, transcriptObject: WrappableTranscript) {
    let WrappableTranscript { id, history: _, math: _, literature: _ } = transcriptObject;
    object::delete(id);
}

public fun request_transcript(
    transcript: WrappableTranscript,
    intended_address: address,
    ctx: &mut TxContext,
) {
    let folderObject = Folder {
        id: object::new(ctx),
        transcript,
        intended_address,
    };
    event::emit(TranscriptRequestEvent {
        wrapper_id: object::uid_to_inner(&folderObject.id),
        requester: tx_context::sender(ctx),
        intended_address,
    });
    //We transfer the wrapped transcript object directly to the intended address
    transfer::transfer(folderObject, intended_address);
}

#[allow(lint(self_transfer))]
public fun unpack_wrapped_transcript(folder: Folder, ctx: &mut TxContext) {
    // Check that the person unpacking the transcript is the intended viewer
    assert!(folder.intended_address == tx_context::sender(ctx), ENotIntendedAddress);
    let Folder {
        id,
        transcript,
        intended_address: _,
    } = folder;
    transfer::transfer(transcript, tx_context::sender(ctx));
    object::delete(id)
}
