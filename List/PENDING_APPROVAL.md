# 待批准补充域名

以下域名在整理规则时发现可能遗漏，**尚未写入任何 `.list` 文件**。请逐条确认是否添加及目标分组。

## AI 服务 → `AISuite.list`（💬 AISuite）

| 域名 | 理由 |
|------|------|
| `DOMAIN-SUFFIX,huggingface.co` | Hugging Face 模型平台，常用 AI 工具 |
| `DOMAIN-SUFFIX,midjourney.com` | Midjourney 图像生成 |
| `DOMAIN-SUFFIX,stability.ai` | Stable Diffusion 官方 |
| `DOMAIN-SUFFIX,cohere.com` | Cohere AI API |
| `DOMAIN-SUFFIX,mistral.ai` | Mistral AI |

## 字节跳动 → `ByteDance.list`（🎯 全球直连）

| 域名 | 理由 |
|------|------|
| `DOMAIN-SUFFIX,douyin.com` | 抖音主域名，当前仅有 `douyinstatic` / `douyinvod` |
| `DOMAIN-SUFFIX,bytedance.com` | 字节跳动集团主域名 |
| `DOMAIN-SUFFIX,bytedance.net` | 字节跳动常用后缀 |

## 代理补充 → `ProxyMisc.list`（🚀 节点选择）

| 域名 | 理由 |
|------|------|
| `DOMAIN-SUFFIX,workers.dev` | Cloudflare Workers，部分 API 可能漏网 |
| `DOMAIN-SUFFIX,replicate.com` | Replicate AI 推理平台 |

---

**操作方式：** 回复「全部批准」或逐条说明（如「批准 douyin.com 和 huggingface.co，其余不要」），我会更新对应 `.list` 并同步 `Conversion.ini`（如有新文件）。
