#!/bin/bash

REMOTE=$1

until [ "$(ssh "${REMOTE}" )" = ok ]; do
    printf "Waiting for ssh connection. . . \n"
done
