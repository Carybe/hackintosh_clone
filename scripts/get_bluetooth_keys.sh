#!/bin/sh

# Simple MACOS script to get the registered bluetooth link keys

sudo defaults read com.apple.bluetoothd.plist LinkKeys > /Users/numec/Desktop/bluetooth.keys
