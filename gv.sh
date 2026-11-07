#!/data/data/com.termux/files/usr/bin/bash

# 安装目录固定在 Termux HOME 下，避免相对路径混乱
INSTALL_DIR="$HOME/gost_share"
PROFILE_AUTOSTART="$PREFIX/etc/profile.d/gost_autostart.sh"

get_arch() {
    case "$(uname -m)" in
        aarch64|arm64) echo "arm64" ;;
        armv7*|armhf)  echo "armv7" ;;
        x86_64|amd64)  echo "amd64" ;;
        i386|i686)     echo "386" ;;
        *)             echo "arm64" ;;
    esac
}

check_dependencies() {
    pkg install -y screen curl tar >/dev/null 2>&1
    # 启用 Termux 防休眠锁，防止锁屏后断网
    if command -v termux-wake-lock >/dev/null 2>&1; then
        termux-wake-lock
    fi
}

gvinstall(){
    check_dependencies
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR" || exit 1

    ARCH=$(get_arch)
    GOST_VER="3.3.3"
    TAR_FILE="gost_${GOST_VER}_linux_${ARCH}.tar.gz"
    DOWNLOAD_URL="https://github.com/go-gost/gost/releases/download/v${GOST_VER}/${TAR_FILE}"
    MIRROR_URL="https://gh-proxy.com/${DOWNLOAD_URL}"

    if [ ! -f "gost" ]; then
        echo "正在下载 GOST (v${GOST_VER} - ${ARCH})..."
        if ! curl -L -# --retry 2 --connect-timeout 8 "$DOWNLOAD_URL" -o "$TAR_FILE"; then
            echo "Github 直连失败，尝试镜像节点中转下载..."
            curl -L -# --retry 2 --connect-timeout 8 "$MIRROR_URL" -o "$TAR_FILE"
        fi

        if [ -f "$TAR_FILE" ]; then
            tar -zxvf "$TAR_FILE" >/dev/null 2>&1
            rm -f "$TAR_FILE" README* LICENSE*
            chmod +x gost
        fi
    fi

    if [ ! -f "gost" ]; then
        echo "❌ 下载失败！请检查网络或开启代理后重试。"
        exit 1
    fi

    # 端口设置与冲突检查
    read -rp "设置 Socks5 端口（回车随机 10000-65535）：" socks_port
    [[ -z "$socks_port" ]] && socks_port=$(shuf -i 10000-65535 -n 1)

    read -rp "设置 Http 端口（回车随机 10000-65535）：" http_port
    [[ -z "$http_port" ]] && http_port=$(shuf -i 10000-65535 -n 1)

    while [ "$socks_port" -eq "$http_port" ]; do
        http_port=$(shuf -i 10000-65535 -n 1)
    done

    echo "✅ 已分配 Socks5 端口: $socks_port | Http 端口: $http_port"

    # 生成 config.yaml (采用 EOF 覆盖写入，支持 fallback DNS)
    cat <<EOF > "$INSTALL_DIR/config.yaml"
services:
  - name: service-socks5
    addr: ":$socks_port"
    resolver: resolver-0
    handler:
      type: socks5
      metadata:
        udp: true
        udpbuffersize: 4096
    listener:
      type: tcp
  - name: service-http
    addr: ":$http_port"
    resolver: resolver-0
    handler:
      type: http
      metadata:
        udp: true
        udpbuffersize: 4096
    listener:
      type: tcp
resolvers:
  - name: resolver-0
    nameservers:
      - addr: 8.8.8.8:53
        ttl: 5m0s
      - addr: 1.1.1.1:53
        ttl: 5m0s
      - addr: tls://8.8.8.8:853
        ttl: 5m0s
        async: true
EOF

    # 停止旧进程
    pkill -f "gost -C.*config.yaml" >/dev/null 2>&1

    # 重新生成 Termux 自动唤起脚本 (修复绝对路径与追加 Bug)
    cat <<EOF > "$PROFILE_AUTOSTART"
#!/data/data/com.termux/files/usr/bin/bash
if ! pgrep -f "$INSTALL_DIR/gost" > /dev/null; then
    screen -wipe >/dev/null 2>&1
    screen -dmS gost_share bash -c 'cd "$INSTALL_DIR" && ./gost -C config.yaml'
fi
EOF
    chmod +x "$PROFILE_AUTOSTART"

    # 立即启动
    screen -wipe >/dev/null 2>&1
    screen -dmS gost_share bash -c "cd '$INSTALL_DIR' && ./gost -C config.yaml"

    echo "================================================"
    echo "🎉 服务已启动！"
    echo "本地局域网 IP 可使用 'ifconfig' 或 Termux WiFi 查看"
    echo "Socks5: :$socks_port"
    echo "HTTP  : :$http_port"
    echo "================================================"
}

uninstall(){
    echo "正在卸载并停止代理服务..."
    pkill -f "gost -C.*config.yaml" >/dev/null 2>&1
    screen -S gost_share -X quit >/dev/null 2>&1
    rm -rf "$INSTALL_DIR"
    rm -f "$PROFILE_AUTOSTART"
    echo "✅ 卸载清理完毕！"
}

show_status(){
    if [ -f "$INSTALL_DIR/config.yaml" ]; then
        s_port=$(grep -A 2 'service-socks5' "$INSTALL_DIR/config.yaml" | grep 'addr' | awk -F':' '{print $3}' | tr -d '\" ')
        h_port=$(grep -A 2 'service-http' "$INSTALL_DIR/config.yaml" | grep 'addr' | awk -F':' '{print $3}' | tr -d '\" ')
        echo "当前状态: 已安装"
        echo "Socks5 端口: ${s_port:-未知}"
        echo "Http   端口: ${h_port:-未知}"
    else
        echo "当前状态: 未安装"
    fi
}

show_menu(){
    clear
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" 
    echo "   Google VPN / 手机代理局域网共享增强版"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" 
    echo " 1. 安装 / 重置配置"
    echo " 2. 停止并完全卸载"
    echo " 0. 退出"
    echo "------------------------------------------------"
    show_status
    echo "------------------------------------------------"
    read -rp "请输入选项 [0-2]: " Input
    case "$Input" in     
        1) gvinstall ;;
        2) uninstall ;;
        *) exit 0 ;;
    esac
}

show_menu
