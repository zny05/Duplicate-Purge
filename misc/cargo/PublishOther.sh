#!/bin/bash
NUMBER="12.0.2"
PURGE_PATH="/home/bg5cgq"

cd "$PURGE_PATH"
PURGE_PATH="$PURGE_PATH/purge"
rm -rf $PURGE_PATH
git clone https://github.com/zny05/Duplicate-Purge.git "$PURGE_PATH"
cd $PURGE_PATH
git checkout "$NUMBER"


cd "$PURGE_PATH/czkawka_cli"
cargo package
if [ $(echo $?) != "0"  ]
then
  echo "Cargo package failed CLI"
  exit 1
fi
git reset --hard


cd "$PURGE_PATH/czkawka_gui"
cargo package
if [ $(echo $?) != "0"  ]
then
  echo "Cargo package failed GUI"
  exit 1
fi
git reset --hard

cd "$PURGE_PATH/krokiet"
cargo package
if [ $(echo $?) != "0"  ]
then
  echo "Cargo package failed krokiet"
  exit 1
fi
git reset --hard




cd "$PURGE_PATH/czkawka_cli"
# sed -i "s/{ path = \"..\/czkawka_core\" }/\"=$NUMBER\"/g" "$PURGE_PATH/czkawka_cli/Cargo.toml"
cargo publish # --allow-dirty
git reset --hard

cd "$PURGE_PATH/czkawka_gui"
# sed -i "s/{ path = \"..\/czkawka_core\" }/\"=$NUMBER\"/g" "$PURGE_PATH/czkawka_gui/Cargo.toml"
cargo publish # --allow-dirty
git reset --hard

cd "$PURGE_PATH/krokiet"
# sed -i "s/{ path = \"..\/czkawka_core\" }/\"=$NUMBER\"/g" "$PURGE_PATH/czkawka_gui/Cargo.toml"
cargo publish # --allow-dirty
git reset --hard
