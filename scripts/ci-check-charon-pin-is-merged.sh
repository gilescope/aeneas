#!/usr/bin/env bash
# Checks that the charon pin is merged into Charon.

NEW_CHARON_PIN="$(cat flake.lock | jq -r .nodes.charon.locked.rev)"
OLD_CHARON_PIN="$(git show origin/main:flake.lock | jq -r .nodes.charon.locked.rev)"
echo "This PR updates the charon pin from $OLD_CHARON_PIN to $NEW_CHARON_PIN"

# On a fork, the pin lives in the fork's Charon (`<owner>/charon`); Actions sets the owner.
git clone "https://github.com/${GITHUB_REPOSITORY_OWNER:-AeneasVerif}/charon"
cd charon || exit 1
CHARON_MAIN="$(git rev-parse HEAD)"

if ! git merge-base --is-ancestor "$NEW_CHARON_PIN" "$CHARON_MAIN"; then
    echo "Error: commit $NEW_CHARON_PIN is not merged into Charon."
    exit 1
fi
