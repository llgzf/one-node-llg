#!/usr/bin/env sh

# 对齐 argosbx.sh 的环境变量
export ARGO_TOKEN="${ARGO_TOKEN:-$(cat $HOME/agsbx/sbargotoken.log 2>/dev/null || echo 'your-argo-token-here')}"
export ARGO_DOMAIN="${ARGO_DOMAIN:-$(cat $HOME/agsbx/sbargoym.log 2>/dev/null || echo 'tunnel.example.com')}"
HOME="${HOME:-/home/user}"
WORKSPACE_DIR="${HOME}/app0926"
PORT_VM_WS="${port_vm_ws:-43301}"  # 对齐 argosbx.sh 的 port_vm_ws，默认为 43301

# 运行原始 Argo 安装脚本
curl -sSL https://raw.githubusercontent.com/llgzf/one-node-llg/refs/heads/main/google-idx/argo/install.sh | sh -s -- ARGO_TOKEN="$ARGO_TOKEN" ARGO_DOMAIN="$ARGO_DOMAIN"

# 设置 systemd 服务以实现开机自启
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

echo "Argo 服务已安装并设置为开机自启，路径：$app0926/app/argo/startup.sh"
