import { BCS, getSuiMoveConfig } from "@mysten/bcs";

const bcs = new BCS(getSuiMoveConfig());

// Simply follow the definition onchain
bcs.registerStructType("Metadata", {
  name: BCS.STRING,
});

// Same for the main object that we intend to read
bcs.registerStructType("BCSObject", {
  // BCS.ADDRESS is used for ID types as well as address types
  id: BCS.ADDRESS,
  owner: BCS.ADDRESS,
  meta: "Metadata",
});

// We construct a test object to serialize, note that we can specify the format of the output to hex
let _bytes = bcs
  .ser("BCSObject", {
    id: "0x0000000000000000000000000000000000000005",
    owner: "0x000000000000000000000000000000000000000a",
    meta: {name: "aaa"}
  })
  .toString("hex");

const de_string = bcs.de("BCSObject", _bytes, "hex");

console.log(_bytes.toString());
console.log(de_string);