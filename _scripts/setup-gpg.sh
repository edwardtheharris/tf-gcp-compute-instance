#!/bin/bash

GPG_KEY_B64=$1

if [ -z "$GPG_KEY_B64" ]; then
    printf "Skipping GPG commit signing setup.\n"
else
    printf "Importing commit signing key.\n"
    echo "$GPG_KEY_B64" | base64 -d | gpg --import -
    echo "$GPG_KEY_B64" > "$HOME/.gnupg/private-key.gpg"
    # GPG_KEY_PATH="$HOME/.gnupg/private-key.gpg"
    printf "Import complete.\n"
    # printf "Configuring key trust on remote.\n"
    # Thanks to this StackOverflow answer for the code below.
    # https://security.stackexchange.com/questions/129474/how-to-raise-a-key-to-ultimate-trust-on-another-machine
    # (echo 5; echo y; echo save) | gpg --command-fd 0 --no-tty --no-greeting -q --edit-key "$(gpg --list-packets < "$GPG_KEY_PATH" | awk '$1=="keyid:"{print$2;exit}')" trust
fi
