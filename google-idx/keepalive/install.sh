#!/usr/bin/env sh

# 环境变量
HOME="${HOME:-/home/user}"
WORKSPACE_DIR="${HOME}/tw"

# 1. 拉取 Docker 镜像
docker pull jlesage/firefox

# 2. 初始化目录
mkdir -p "$WORKSPACE_DIR/app/firefox/idx"
mkdir -p "$HOME/agsbx/idx-keepalive"
cd "$HOME/agsbx/idx-keepalive"

# 3. 下载保持活跃脚本并安装依赖
wget -O app.js https://raw.githubusercontent.com/vevc/one-node/refs/heads/main/google-idx/keepalive/app.js
wget -O package.json https://raw.githubusercontent.com/vevc/one-node/refs/heads/main/google-idx/keepalive/package.json
npm install

# 4. 创建 startup.sh
cat > startup.sh <<EOF
#!/usr/bin/env sh
cd $HOME/agsbx/idx-keepalive
nohup npm run start 1>idx-keepalive.log 2>&1 &
EOF
chmod +x startup.sh

# 5. 返回主目录
cd -
