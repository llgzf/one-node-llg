#!/usr/bin/env sh

# 对齐 argosbx.sh 的环境变量
PORT="${port_xh:-8080}"  # 使用 argosbx.sh 的 port_xh，默认为 8080
UUID="${uuid:-$(uuidgen)}"  # 使用 argosbx.sh 的 uuid，未设置则生成
ARGO_TOKEN="${ARGO_TOKEN:-}"  # 对齐 argosbx.sh
ARGO_DOMAIN="${ARGO_DOMAIN:-}"  # 可选的 Argo 域名
HOME="${HOME:-/home/user}"  # 确保 HOME 已设置
WORKSPACE_DIR="${HOME}/tw"  # 与 app.js 的 projectDir 对齐

# 1. 初始化目录结构，与 argosbx.sh 一致
mkdir -p "$HOME/agsbx/xray"
cd "$HOME/agsbx/xray"

# 2. 下载并解压 Xray
wget -O Xray-linux-64.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip Xray-linux-64.zip
rm -f Xray-linux-64.zip
chmod +x xray

# 3. 添加配置文件
wget -O config.json https://raw.githubusercontent.com/vevc/one-node/refs/heads/main/google-idx/xray-config-template.json
sed -i "s/\$PORT/$PORT/g" config.json
sed -i "s/\$UUID/$UUID/g" config.json

# 4. 创建 startup.sh 用于 Xray
cat > startup.sh <<EOF
#!/usr/bin/env sh
cd $HOME/agsbx/xray
./xray run -c config.json
EOF
chmod +x startup.sh

# 5. 安装 Argo 服务
if [ -n "$ARGO_TOKEN" ]; then
  curl -sSL https://raw.githubusercontent.com/vevc/one-node/refs/heads/main/google-idx/argo/install.sh | sh
fi

# 6. 启动 Xray
./startup.sh &

# 7. 输出节点信息（对齐 argosbx.sh 的输出样式）
echo "---------------------------------------------------------------"
if [ -n "$ARGO_DOMAIN" ]; then
  echo "vless://$UUID@$ARGO_DOMAIN:443?encryption=none&security=tls&alpn=http%2F1.1&fp=chrome&type=xhttp&path=%2F&mode=auto#idx-xhttp-argo"
else
  echo "vless://$UUID@example.domain.com:443?encryption=none&security=tls&alpn=http%2F1.1&fp=chrome&type=xhttp&path=%2F&mode=auto#idx-xhttp"
fi
if [ -n "$port_vm_ws" ]; then
  echo "vmess://$(echo -n '{\"v\":\"2\",\"ps\":\"idx-vmess-1\",\"add\":\"$ARGO_DOMAIN\",\"port\":\"${port_vm_ws:-43301}\",\"id\":\"$UUID\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"\",\"path\":\"/$UUID-vm?ed=2048\",\"tls\":\"\"}' | base64 -w0)#idx-vmess-1"
  echo "vmess://$(echo -n '{\"v\":\"2\",\"ps\":\"idx-vmess-2\",\"add\":\"$ARGO_DOMAIN\",\"port\":\"${port_vm_ws:-43302}\",\"id\":\"$UUID\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"\",\"path\":\"/$UUID-vm?ed=2048\",\"tls\":\"\"}' | base64 -w0)#idx-vmess-2"
fi
echo "---------------------------------------------------------------"
