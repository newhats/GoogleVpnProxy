### 基于gost的局域网共享代理一键脚本，支持Socks5+Http双代理，Google VPN用户推荐使用

### 功能与Every Proxy应用一样，但在传输性能上，gost更加优秀

### Google Pixel手机先安装[Termux](https://github.com/termux/termux-app/releases)运行一键脚本

#### 一键脚本如下，快捷运行方式 ```bash gv.sh```

```
pkg upgrade -y && bash <(curl -Ls https://gh-proxy.com/https://raw.githubusercontent.com/yonggekkk/google_vpn_proxy/main/gv.sh)
```

#### 可在Termux输入命令 ```ifconfig``` 查看内网IP地址，并填写在支持Socks5或者Http的客户端上

#### 使用注意：

1、安装完毕后，每当进入Termux，共享代理会自动启用

2、退出Termux后，共享代理会自动保持在后台运行

3、输入命令 ```exit``` 才可退出共享代理

--------------------------------------------------
### 教程：

#### 相关说明及注意点请查看[甬哥博客说明与google-pixel-VPN视频教程](https://ygkkk.blogspot.com/2025/02/pixelgooglevpn.html)

Google pixel手机及VPN使用心得[视频教程系列](https://www.youtube.com/playlist?list=PLMgly2AulGG_wlFVKqKmr6_8RQYG5UgI6)

[最新！永久免费的Google VPN教程（五）：解决前置代理引导Google VPN报错问题，一键脚本支持socks+http共享Google VPN到局域网](https://youtu.be/Wt7c-4pnLCg)

-----------------------------------------------------
### 交流平台：[甬哥博客地址](https://ygkkk.blogspot.com)、[甬哥YouTube频道](https://www.youtube.com/@ygkkk)、[甬哥TG电报群组](https://t.me/+jZHc6-A-1QQ5ZGVl)、[甬哥TG电报频道](https://t.me/+DkC9ZZUgEFQzMTZl)

--------------------------------------------------------
### 感谢支持！微信打赏甬哥侃侃侃ygkkk
![41440820a366deeb8109db5610313a1](https://github.com/user-attachments/assets/551cc2e1-a55a-444b-9c9c-2419ee5f14df)

--------------------------------------------------------

### 感谢你右上角的star🌟
[![Stargazers over time](https://starchart.cc/yonggekkk/google_vpn_proxy.svg)](https://starchart.cc/yonggekkk/google_vpn_proxy)

---------------------------------------
#### 声明：所有代码来源于Github社区与ChatGPT的整合，[gost](https://github.com/go-gost/gost/releases)、[Termux](https://github.com/termux/termux-app/releases)
