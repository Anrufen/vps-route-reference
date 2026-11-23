# 2026 中文 VPS 跨境线路特征、Looking Glass 汇总与 Docker / AI Agent 安全自托管参考

> 本仓库整理并持续维护中国大陆主流跨境网络（`CN2 GIA / CMIN2 / AS9929 / AS4837 / SoftBank / IIJ`）跳点识别规则、官方 Looking Glass 测试入口、真机 FIO/Docker 生产基准，以及 **Claude Code / OpenClaw / Codex CLI** 云端自托管防火墙防泄漏配置模板。
>
> 完整长测归档、机房实时库存追踪与各商家评测边界披露均维护在 **[VPShare (vpsort.com)](https://www.vpsort.com/)**。

---

## 一、 中国大陆三大运营商跨境骨干网识别表（2026 版）

使用 `NextTrace` 或 `mtr` 回程探测时，通过以下核心跳点 IP 与 ASN 可快速判定真实回国路线（完整解析见 [2026 中国大陆跨境 VPS 线路百科](https://www.vpsort.com/3270.html)）：

| 运营商 | 线路名称 | ASN / 核心跳点特征 | 晚高峰表现（20:00–23:30 CST） | 典型应用场景 |
| :--- | :--- | :--- | :--- | :--- |
| **中国电信** | **CN2 GIA** | `AS4809` 全程 `59.43.*.*` | 极低丢包（通常 < 1%），抖动极小 | 建站主力、企业级 SSH / API 直连 |
| **中国电信** | **CN2 GT** | 国内 `202.97.*` 出国转 `59.43.*` | 半程优化，高峰易受 163 出口拥堵拖累 | 中低预算过渡方案 |
| **中国电信** | **163 骨干网** | `AS4134`（`202.97.*.*`） | 跨洋段丢包常见（10%–30%），需靠 BBR / 中转 | 海外访客业务、非高峰备份 |
| **中国联通** | **CUII / AS9929** | `AS9929` / `AS10099`（`218.105.*` / `210.51.*`） | 轻负载精品 A 网，美西/欧洲直连极稳 | 联通建站与低延迟开发 |
| **中国联通** | **AS4837 / 169** | `AS4837`（`219.158.*.*`） | 总带宽大、性价比高（海缆故障期除外） | 均衡大流量业务 |
| **中国移动** | **CMIN2** | `AS58807` 移动新版精品网 | 对标电信 CN2 GIA 的高优独立通道 | 移动用户跨洋首选 |
| **中国移动** | **CMI** | `AS58453` / `AS9808`（`221.183.*.*`） | 亚太（香港/日本/新加坡）直连主力 | 亚太近距节点 |
| **日本直连** | **SoftBank 软银** | `AS17676`（BBTEC） | 联通 45–65ms 神线；电信晚高峰偶有抖动 | 联通主力、日本容器宿主机 |
| **日本直连** | **IIJ** | `AS2497` | 联通 4837 对接不错；电信晚高峰走 163 易塞车 | 大内存/大流量低价宿主机 |

---

## 二、 官方 Looking Glass 与公开测速参考点（2026-11 核对）

下表仅收录公开可用的官方测速点与测试 IP，买前可先从本地宽带做 `ping / tracert / NextTrace` 验证：

| 地区与线路 | 服务商 / 机房 | 官方 Looking Glass / 测试节点 | 备注与详测档案 |
| :--- | :--- | :--- | :--- |
| 美国洛杉矶 WebNX (`AS18450`) | GreenCloud LA | `64.185.232.162` / `2607:f2d8:6065:1000::1` (`greenping`) | 普通国际 BGP；详看 [绿云洛杉矶评测](https://www.vpsort.com/3174.html) |
| 美国洛杉矶 DC03 (`ColoCrossing`) | RackNerd LAX03 | `https://lg-lax03.racknerd.com/` | 2026-05 原 DC02 停服迁出后的黑五美西主节点；[RackNerd 2026 黑五对比](https://www.vpsort.com/3209.html) |
| 美国洛杉矶 `CERA/CN2 GIA` | HostDare LA | `185.186.146.8` | 三网回程 CN2 GIA / 9929 / CMIN2；[HostDare 洛杉矶评测](https://www.vpsort.com/204.html) |
| 日本东京 / 大阪 `SoftBank` | HostDare JP | `45.12.89.89` / `http://45.12.89.80/100mb.bin` | 双向流量计费；[HostDare 日本软银评测](https://www.vpsort.com/3229.html) |
| 日本东京 `xTom (IIJ+SoftBank)` | GreenCloud JP | `http://91.200.242.41/100MB.test` / `https://ping.pw/` | 下节附本站真机生产长测数据；[3267 完整档案](https://www.vpsort.com/3267.html) |
| 美国西雅图 `AS4837 / CMIN2` | Spartan Host SEA | `http://lg.sea.spartanhost.net/` (`104.37.29.141`) | 注意 2026-09~11 联通海缆拥堵提示；[斯巴达 2026 评测](https://www.vpsort.com/255.html) |

> 更多多节点横向对比（包含搬瓦工 DC6/DC9/DC5 SLA、DMIT AN4/EB、VMISS 等客观参数对照）详见：
> - [2026 国外 VPS 推荐总榜](https://www.vpsort.com/vps-recommend)
> - [2026 搬瓦工 vs DMIT 哪个好](https://www.vpsort.com/3351.html)
> - [2026 日本 VPS 推荐（CN2 GIA / 软银 / IIJ）](https://www.vpsort.com/3352.html)

---

## 三、 真机长期生产样本参考（`Green-JP` 东京 4G NVMe）

以下指标直接采自本站长期在线运行的生产节点 **`Green-JP`**（GreenCloud 东京 Budget KVM，非云厂商临时跑分）：

- **宿主机硬件**：`Intel Xeon CascadeLake @ 2.00GHz`（2 vCPU）/ `3.88 GB` 物理内存 + `4 GB` Swap / `35 GB` NVMe / Debian 12 (`6.1.0-31`)
- **磁盘实测 I/O**：
  - `dd` 1GB `fdatasync` 顺序写：**703 MB/s**
  - `FIO` 4K QD1 随机写：**6,019 IOPS**（`24.7 MB/s`，99% 延迟 ≤ `453 us`）
  - `FIO` 1MB QD4 顺序读：**1,996 MB/s**（平均延迟 `2.08 ms`）
- **网络与 IP 画像**：广播于 `AS3258 xTom Japan`（IIJ + SoftBank `AS17676` 混播）；联通 `45–65ms`、移动 `70–95ms`、电信白天 `65–85ms`（晚高峰因非 CN2 存在常规波动）；Scamalytics Fraud Score `0 / 100`。
- **生产负载**：24×7 并行运行 `one-api` + `browserless/chrome` + `rsshub` + `redis` + `beszel-agent`，常驻内存约 `1.7 GB`。完整评测报告与图表见：[GreenCloud 绿云东京 VPS 深度长测](https://www.vpsort.com/3267.html)。

---

## 四、 “双 ISP 住宅 IP” 验真与常用一键检测命令

市面上大量低价“双 ISP VPS”实际只是托管在洛杉矶数据中心的广播段（如 Cogent `AS174`），只看老牌查询站显绿容易误踩风控。建议开箱先做四步交叉核验（原理与常见坑点见 [2026 双 ISP 住宅 IP 科普与避坑](https://www.vpsort.com/3353.html)）：

1. **`ipapi.is`**：同时检查 `asn.type === "isp"` **且** `company.type === "isp"`；若任意一侧为 `hosting`，即属机房代理段。
2. **`scamalytics.com`**：查看 Fraud Score（推荐 `0–15`），并确认 `Datacenter` 与 `Server` 两项均为 `No`。
3. **`IPQuality` 终端全量核查**：
   ```bash
   bash <(curl -sL https://Check.Place) -I
   ```
4. **常用综合测试脚本目录**：`GoECS` / `NodeQuality` / `NextTrace` 命令与排错合集见 [2026 VPS 一键实测脚本与排错指南](https://www.vpsort.com/227.html)。

---

## 五、 Docker / AI Coding Agent 防泄漏安全自检与 Compose 模板

在 VPS 上运行 **Claude Code、OpenAI Codex CLI 或 OpenClaw** 时，最致命的隐患是 **Docker 的 `ports: ["18789:18789"]` 会直接修改底层 `iptables DOCKER` 链并绕过 UFW 防火墙**，把未鉴权网关或密钥暴露在公网。

本仓库提供了可直接运行的只读自检脚本与加固 Compose 模板：

```bash
# 1. 运行只读健康与 Docker 公网暴露审计脚本（不会修改任何系统配置）
bash scripts/vps_quick_audit.sh
```

- 安全隔离模板见：[docker/openclaw-hardened-compose.yml](./docker/openclaw-hardened-compose.yml)（强制 `127.0.0.1:18789:18789` 回环绑定 + `OPENCLAW_CONFIG_READONLY=1` + `mem_limit`）。
- 完整 4GB+ 内存选型对比与 Tailscale / SSH 隧道接入教程见：[2026 跑 Claude Code / Codex / OpenClaw 与 Docker 的稳定 VPS 推荐与安全部署](https://www.vpsort.com/3354.html)。

---

## License

MIT License — 欢迎提交 PR 补充更多 2026 年真实节点 Looking Glass 与自托管加固实践。
