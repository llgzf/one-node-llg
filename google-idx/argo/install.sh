#!/usr/bin/env sh

# 对齐 argosbx.sh 的环境变量，使用提供的 agk 作为默认 token，并覆盖为长 token
ARGO_TOKEN="${ARGO_TOKEN:-eyJhIjoiYWEzZGQwNTY1MzY4OThiNWExNWI1ZjQ0NTNjN2UzNTY1UzNTY1UzNTY1ZjQ0NTNjN2UzNTY1MzY4OThiNWExNWI1ZjQ0NTNjN2UzNTYn2UzNTY1UzNTY1UzNTY1UzNTY1UzNTY1ZjQ0NTNjN2UzNTY1UzNTY1UzNTY1UzNTY1UzNTY1UzNTYn2UzNTYn2UzNTY1UzNTY1UzNTYn2UzNTYn2UzNTY1UzNTYn2UzNTYn2UzNTY1UzNTYn2UzNTYn2UzNTYn2UzNTYy1UzNTYjN2UzNTYniLCJ0IjoiNWEyZjNhNDItZDJjZi00Y2JhLThiOGYtMmM1ZGViM2QwY2JhIiwicyI6IlpqWTRPR0U1TURRdE5USXlOUzAwTW1JeUxXRTNaVFF0T0dZd05UZ3dOR0ZoWkdRMSJ9}"
ARGO_DOMAIN="${ARGO_DOMAIN:-yongcd.433201.xyz}"  # 使用提供的 agn
HOME="${HOME:-/home/user}"
WORKSPACE_DIR="${HOME}/app0926"
PORT_VM_WS="${vmpt:-43301}"  # 使用提供的 vmpt 端口

# 1. 初始化目录
mkdir -p "$WORKSPACE_DIR/app/argo"
cd "$WORKSPACE_DIR/app/argo"

# 2. 下载 cloudflared（与 argosbx.sh 版本一致，支持固定隧道）
if [ ! -f cloudflared ]; then
  wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/download/2025.9.0/cloudflared-linux-amd64
  chmod +x cloudflared
fi

# 3. 创建 startup.sh，支持 Argo 固定隧道
cat > startup.sh <<EOF
#!/usr/bin/env sh
cd $WORKSPACE_DIR/app/argo
ARGO_TOKEN=$ARGO_TOKEN
ARGO_DOMAIN=$ARGO_DOMAIN
if [ -n "\$ARGO_TOKEN" ]; then
  ./cloudflared --no-autoupdate tunnel run --token \$ARGO_TOKEN
fi
EOF
chmod +x startup.sh

# 4. 存储 token（类似于 argosbx.sh 的 sbargotoken.log）
echo "$ARGO_TOKEN" > "$HOME/agsbx/sbargotoken.log"
echo "$ARGO_DOMAIN" > "$HOME/agsbx/sbargoym.log"

# 5. 设置 systemd 服务以实现开机自启（对齐 argosbx.sh 的 res/del 逻辑）
cat > /etc/systemd/system/argo-ws.service <<EOF
[Unit]
Description=Argo Tunnel Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$WORKSPACE_DIR/app/argo
ExecStart=$WORKSPACE_DIR/app/argo/startup.sh
Environment=ARGO_TOKEN=$ARGO_TOKEN
Environment=ARGO_DOMAIN=$ARGO_DOMAIN
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable argo-ws
systemctl start argo-ws

# 6. 返回主目录
cd -

echo "Argo 服务已安装并设置为开机自启（固定隧道），域名：$ARGO_DOMAIN，端口：$PORT_VM_WS，路径：$WORKSPACE_DIR/app/argo/startup.sh"
