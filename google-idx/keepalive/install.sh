#!/usr/bin/env sh

# 执行提供的保活安装命令
curl -sSL https://raw.githubusercontent.com/vevc/one-node/refs/heads/main/google-idx/keepalive/install.sh | sh

# 环境变量，对齐 argosbx.sh
HOME="${HOME:-/home/user}"
WORKSPACE_DIR="${HOME}/tw"
ARGO_TOKEN="${ARGO_TOKEN:-eyJhIjoiYWEzZGQwNTY1MzY4OThiNWExNWI1ZjQ0NTNjN2UzNTY1UzNTY1UzNTY1ZjQ0NTNjN2UzNTY1MzY4OThiNWExNWI1ZjQ0NTNjN2UzNTYn2UzNTY1UzNTY1UzNTY1UzNTY1UzNTY1ZjQ0NTNjN2UzNTY1UzNTY1UzNTY1UzNTY1UzNTY1UzNTYn2UzNTYn2UzNTY1UzNTY1UzNTYn2UzNTYn2UzNTY1UzNTYn2UzNTYn2UzNTY1UzNTYn2UzNTYn2UzNTYn2UzNTYy1UzNTYjN2UzNTYniLCJ0IjoiNWEyZjNhNDItZDJjZi00Y2JhLThiOGYtMmM1ZGViM2QwY2JhIiwicyI6IlpqWTRPR0U1TURRdE5USXlOUzAwTW1JeUxXRTNaVFF0T0dZd05UZ3dOR0ZoWkdRMSJ9}"

# 1. 拉取 Docker 镜像（原逻辑）
docker pull jlesage/firefox

# 2. 初始化目录（对齐 argosbx.sh 的 $HOME/agsbx）
mkdir -p "$WORKSPACE_DIR/app/firefox/idx"
mkdir -p "$HOME/agsbx/idx-keepalive"
cd "$HOME/agsbx/idx-keepalive"

# 3. 下载保持活跃脚本并安装依赖（添加 token 检查）
wget -O app.js https://raw.githubusercontent.com/vevc/one-node/refs/heads/main/google-idx/keepalive/app.js
wget -O package.json https://raw.githubusercontent.com/vevc/one-node/refs/heads/main/google-idx/keepalive/package.json
npm install
if [ -n "$ARGO_TOKEN" ]; then
  echo "Argo token 已设置，兼容固定隧道。"
fi

# 4. 创建 startup.sh（集成 argosbx.sh 的 lock 机制）
cat > startup.sh <<EOF
#!/usr/bin/env sh
cd $HOME/agsbx/idx-keepalive
if [ -f /tmp/keepalive.lock ]; then echo "Locked, skipping"; exit; fi
touch /tmp/keepalive.lock
nohup npm run start 1>idx-keepalive.log 2>&1 &
sleep 5
rm -f /tmp/keepalive.lock
EOF
chmod +x startup.sh

# 5. 返回主目录
cd -
