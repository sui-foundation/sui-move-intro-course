#!/bin/bash
current_dir=$(pwd);
#  add build test project to this
project_path=(unit-one/example_projects/hello_world
unit-two/example_projects/transcript
unit-three/example_projects/fungible_tokens
unit-three/example_projects/generics
unit-three/example_projects/witness
unit-four/example_projects/collections
unit-four/example_projects/marketplace
unit-five/example_projects/flashloan
unit-five/example_projects/kiosk
advanced-topics/BCS_encoding/example_projects/bcs_move
advanced-topics/closed_loop_token/example_projects/closed_loop_token
);

for(( i=0;i<${#project_path[@]};i++)) do
    echo "test for "${current_dir}/${project_path[i]}";"
    sui move build -p "${current_dir}/${project_path[i]}";
done