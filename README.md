# Clash 自定义规则库

基于 [ACL4SSR](https://github.com/ACL4SSR/ACL4SSR) 的 Subconverter 自定义规则补充，用于生成 Clash / OpenClash 配置。

## 仓库结构

```
Conversion.ini          # Subconverter 主配置（规则映射 + 代理分组）
List/                   # 自定义规则文件（全部扁平存放）
├── direct/ 逻辑分组
│   ├── UnBan.list          # 广告拦截白名单
│   ├── Tailscale.list      # Tailscale 进程 + 域名
│   ├── TailscaleIP.list    # Tailscale DERP IP
│   ├── ByteDance.list      # 字节跳动 / 抖音 / 头条
│   ├── Xiaohongshu.list    # 小红书 / RedNote
│   ├── NIO.list            # 蔚来
│   ├── WeChat.list         # 微信
│   ├── Xiaomi.list         # 小米
│   ├── ChinaMisc.list      # 国内直连杂项
│   └── ChinaIP.list        # 国内直连 IP
├── proxy/ 逻辑分组
│   ├── Cursor.list         # Cursor IDE
│   ├── GitHub.list         # GitHub + 镜像
│   ├── CloudflareProxy.list
│   ├── Samsung.list
│   ├── Autodesk.list
│   ├── Analytics.list      # 分析 / 追踪（需代理）
│   ├── ProxyMisc.list      # 代理杂项
│   ├── ProxyIP.list        # 代理 IP
│   ├── DnsProxy.list       # DoH/DoT 域名
│   └── DnsProxyIP.list     # DoH/DoT IP
├── streaming/
│   ├── YoutubeVideo.list
│   ├── NetflixVideo.list + NetflixVideoIP.list
│   └── DisneyVideo.list
└── service/
    ├── AISuite.list
    ├── Microsoft.list + MicrosoftIP.list
    ├── Xbox.list
    ├── Speedtest.list
    └── Wi-FiCalling.list + Wi-FiCallingIP.list
```

> 注：以上为逻辑分类，物理路径均在 `List/` 根目录（扁平结构）。

## 使用方法

1. 在 Subconverter 中引用本仓库的 `Conversion.ini` 作为自定义配置
2. 规则文件 URL 格式：
   ```
   https://raw.githubusercontent.com/Yaochen2182/Clash/main/List/<文件名>.list
   ```
3. 生成配置后导入 Clash / OpenClash

## 规则命名约定

| 后缀 / 模式 | 含义 |
|-------------|------|
| `*Add` | 对 ACL4SSR 基础规则的补充（已拆分为具体分类文件） |
| `*Video` | 流媒体视频 CDN 流量（UNL 解锁用） |
| `*IP` | 从域名列表中拆出的 IP-CIDR 规则 |
| `*Misc` | 暂未细分的杂项规则 |

## 添加新规则

1. 确定目标代理分组（参考 `Conversion.ini` 中的 `ruleset=` 行）
2. 在对应 `.list` 文件中追加规则（格式：`DOMAIN-SUFFIX,example.com`）
3. 若是 IP 规则，写入对应的 `*IP.list` 文件
4. 新文件需在 `Conversion.ini` 中添加 `ruleset=` 行
5. 提交 PR 或 push 到 `main`

## 待批准补充

见 [`List/PENDING_APPROVAL.md`](List/PENDING_APPROVAL.md)。

## 未接入的规则

| 文件 | 说明 |
|------|------|
| `Paramount.list` | Paramount+ 流媒体，暂未接入 Conversion.ini |

## 外部依赖

- ACL4SSR `master` 分支远程规则（38 个 ruleset）
- 自定义规则托管于本仓库 `main` 分支
