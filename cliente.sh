#!/bin/bash

PORT=8080

echo "Cliente"

echo "ola soi el cli ente" | cowsay | nc localhost $PORT
