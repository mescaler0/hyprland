#!/bin/bash

# Controlla se Capslock è attivo
if xset q | grep "Caps Lock:   on" > /dev/null 2>&1; then
    echo " CAPS LOCK"
else
    echo ""
fi
