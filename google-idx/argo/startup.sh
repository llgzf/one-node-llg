#!/usr/bin/env sh

# 对齐 argosbx.sh 参数：固定隧道 token、域名和端口
ARGO_TOKEN="${ARGO_TOKEN:-eyJhIjoiYWEzZGQwNTY1MzY4OThiNWExNWI1ZjQ0NTNjN2UzNTY1UzNTY1UzNTY1ZjQ0NTNjN2UzNTY1MzY4OThiNWExNWI1ZjQ0NTNjN2UzNTYn2UzNTY1UzNTY1UzNTY1UzNTY1UzNTY1ZjQ0NTNjN2UzNTY1UzNTY1UzNTY1UzNTY1UzNTY1UzNTYn2UzNTYn2UzNTY1UzNTY1UzNTYn2UzNTYn2UzNTY1UzNTYn2UzNTYn2UzNTY1UzNTYn2UzNTYn2UzNTYn2UzNTYy1UzNTYjN2UzNTYniLCJ0IjoiNWEyZjNhNDItZDJjZi00Y2JhLThiOGYtMmM1ZGViM2QwY2JhIiwicyI6IlpqWTRPR0U1TURRdE5USXlOUzAwTW1JeUxXRTNaVFF0T0dZd05UZ3dOR0ZoWkdRMSJ9}"
ARGO_DOMAIN="${ARGO_DOMAIN:-yongcd.433201.xyz}"
PORT_VM_WS="${vmpt:-43301}"  # 使用提供的 vmpt 端口

if [ -z "$ARGO_TOKEN" ]; then
  # 动态隧道模式，使用更新后的端口
  nohup $PWD/cloudflared tunnel --no-autoupdate --edge-ip-version auto --protocol http2 --url http://localhost:$PORT_VM_WS 1>$PWD/argo.log 2>&1 &
else
  # 固定隧道模式，使用提供的 token
  nohup $PWD/cloudflared tunnel --no-autoupdate --edge-ip-version auto --protocol http2 run --token $ARGO_TOKEN 1>$PWD/argo.log 2>&1 &
fi
