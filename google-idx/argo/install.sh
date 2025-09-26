#!/usr/bin/env sh

# 对齐 argosbx.sh 的环境变量
ARGO_TOKEN="${ARGO_TOKEN:-$(cat $HOME/agsbx/sbargotoken.log 2>/dev/null || echo '')}"
ARGO_DOMAIN="${ARGO_DOMAIN:-$(cat $HOME/agsbx/sbargoym.log 2>/dev/null || echo 'example.domain.com')}"
HOME="${HOME:-/home/user}"
WORKSPACE_DIR="${HOME}/app0926"
PORT_VM_WS="${port_vm_ws:-43301}"  # 对齐 argosbx.sh 的 port_vm_ws，默认为 43301

# 1. 初始化目录
mkdir -p "$WORKSPACE_DIR/app/argo"
cd "$WORKSPACE_DIR/app/argo"

# 2. 下载 cloudflared（与 argosbx.sh 的版本一致）
if [ ! -f cloudflared ]; then
  wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/download/2025.9.0/cloudflared-linux-amd64
  chmod +x cloudflared
fi

# 3. 创建 startup.sh
cat > startup.sh <<EOF
#!/usr/bin/env sh
cd $WORKSPACE_DIR/app/argo
ARGO_TOKEN=$ARGO_TOKEN
if [ -n "\$ARGO_TOKEN" ]; then
  ./cloudflared --no-autoupdate tunnel run --token \$ARGO_TOKEN
fi
EOF
chmod +x startup.sh

# 4. 存储 token（类似于 argosbx.sh 的 sbargotoken.log）
echo "$ARGO_TOKEN" > "$HOME/agsbx/sbargotoken.log"

# 5. 设置 systemd 服务以实现开机自启
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
Environment=PORT_VM_WS=$PORT_VM_WS
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

echo "Argo 服务已安装并设置为开机自启，路径：$WORKSPACE_DIR/app/argo/startup.sh"
