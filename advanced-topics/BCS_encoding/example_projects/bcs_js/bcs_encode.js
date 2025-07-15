import { bcs, fromHex, toHex } from "@mysten/bcs";

// Define Address as a 32-byte array, then add a transform to/from hex strings
const Address = bcs.fixedArray(32, bcs.u8()).transform({
	input: (id) => fromHex(id),
	output: (id) => toHex(Uint8Array.from(id)),
});

// We construct a test object to serialize, note that we can specify the format of the output to hex
const bcsStruct = bcs.struct("BCSObject", {
  id: Address,
  owner: Address,
  meta: bcs.struct("Metadata", {
    name: bcs.string(),
  }),
});

const serialized = bcsStruct.serialize({
  id: "0x0000000000000000000000000000000000000000000000000000000000000005",
  owner: "0x000000000000000000000000000000000000000000000000000000000000000A",
  meta: {
    name: "aaa"
  }
});

console.log("Hex:", serialized.toHex());
console.log("Deserialized:", serialized.parse());