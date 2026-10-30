#!/bin/bash
NUMBER="12.0.2"
PURGE_PATH="/home/bg5cgq"

cd "$PURGE_PATH"
PURGE_PATH="$PURGE_PATH/purge"
rm -rf $PURGE_PATH
git clone https://github.com/zny05/Duplicate-Purge.git "$PURGE_PATH"
cd $PURGE_PATH
git checkout "$NUMBER"

cd "$PURGE_PATH/czkawka_core"
cargo package
if [ $(echo $?) != "0"  ]
then
  echo "Cargo package failed CORE"
  exit 1
fi
git reset --hard

cd "$PURGE_PATH/czkawka_core"
cargo publish
git reset --hard

