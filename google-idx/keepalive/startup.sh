#!/usr/bin/env sh

cd $HOME/agsbx/idx-keepalive
nohup npm run start 1>idx-keepalive.log 2>&1 &
