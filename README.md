# Anti-Defensive Writing（反防御性写作）· dsh 插件

把 [Kiterlin/anti-defensive-writing](https://github.com/Kiterlin/anti-defensive-writing) 与
[Adkid-Zephyr/anti-defensive-writing-Skill](https://github.com/Adkid-Zephyr/anti-defensive-writing-Skill)
两套规则合并成一个可直接用于 **DeepSeek Harness（dsh）** 的插件，同时提供中文与英文两个技能。

> **论文是一场学术发布会，不是项目总结、实验日志或自我审查报告。**

---

## 集两家之长

| 来源 | 贡献 |
| :-- | :-- |
| **Adkid-Zephyr**（发布会原则） | 战略层：只围绕优势组织叙事、打不过的维度不设为比赛、不占优的结果不说输、每个实验承担论证职责、摘要引言 = 发布会开场、处理不理想材料的七级优先级、交稿前“不给审稿人递刀子”自查。 |
| **Kiterlin**（反防御性写作） | 操作层：保留必要限定的判据、逐句检查清单、五步改写流程、技术方案 / SOP 写法、推荐与避免句式、指标与不利结果处理、中英文表达差异、示例只供写法不供事实。 |

合并后的技能不是两份文档的拼接：叙事规则管“写什么、往哪写”，改写规则管“每一句怎么落到准确、直接、有底气”，两条线交叉引用、彼此不重复。

## 安装

### 方式一：作为 dsh 插件（推荐）

插件是纯 ESM、无构建、无第三方运行时依赖。把本目录作为本地包安装到目标 profile：

```sh
# 需要 dsh 命令行（dsh --version 可用）；<profile> 换成目标 profile 名
dsh plugin --profile <profile> add "<本目录的绝对路径>"

# 或显式使用 link: 规格
dsh plugin --profile <profile> add "link:<本目录的绝对路径>"
```

安装后重启 `dsh --profile <profile>`（或等待 HMR 重载）。插件通过 `cordis.patch.yml` 把
`anti-defensive-writing` 插入 profile 的加载树，并在 `ctx.skills` 上注册两个技能。

> **DSH Desktop 用户：** 桌面版通常没有把 `dsh` 命令加入 PATH，profile
> （`~/.dsh/profiles/desktop`）也由桌面壳管理。请优先用下面的“方式二”，或在桌面版
> “插件”页选择本地目录安装；若要用命令行装进 desktop profile，需先完全退出桌面版。

### 方式二：复制技能文件夹（所有宿主通用）

dsh 的 `@deepseek-ai/dsh-skill-filesystem` 会扫描这些目录：

| 排名 | 来源 | 路径 |
| :-- | :-- | :-- |
| 100 | 项目 | `<项目根>/.dsh/skills` |
| 200 | 项目 | `<项目根>/.agents/skills` |
| 400 | 用户 | `~/.dsh/skills`（`$DSH_HOME/skills`） |
| 500 | 用户 | `~/.agents/skills`（`$DSH_AGENTS_HOME/skills`） |

运行随附脚本，把两个技能复制到用户技能目录：

```powershell
# Windows PowerShell
.\install.ps1

# 装到所有兼容 agent 共享的目录
.\install.ps1 -Dest ~\.agents\skills

# 覆盖已有安装
.\install.ps1 -Force
```

```sh
# macOS / Linux
./install.sh
./install.sh --dest ~/.agents/skills
```

也可以手动复制：把 `skills/anti-defensive-writing` 和
`skills/anti-defensive-writing-en` 整个文件夹放进上面任一目录。

### 方式三：只复制提示词

不想安装任何东西时，直接把
[`prompts/精简版提示词.txt`](prompts/精简版提示词.txt)（[English](prompts/quick-prompt-en.txt)）
粘贴到对话开头，再发送你的论文段落。

## 使用

安装后，在 dsh 会话中模型会看到技能目录，可按需加载：

- 中文技能：`anti-defensive-writing`
- 英文技能：`anti-defensive-writing-en`

也可以直接输入斜杠命令（user-invocable）：

```text
/anti-defensive-writing
/anti-defensive-writing-en
```

然后发送要改写的段落，例如：

> 帮我重写这段摘要，围绕最强的证据组织贡献，保留准确的数字与研究范围。

> Revise this introduction around its strongest supported contribution. Preserve facts and essential qualifications.

> 帮我检查这段 rebuttal，直接回答审稿人的问题，并指出哪些表述缺少证据。

## 仓库结构

```text
anti-defensive-writing/
├── package.json                     # dsh 包清单（dsh.bundle.patch / exports）
├── cordis.patch.yml                 # 把插件插入 profile 加载树
├── lib/index.js                     # 技能提供者：注册两个 SKILL.md
├── skills/
│   ├── anti-defensive-writing/SKILL.md       # 中文合并版
│   └── anti-defensive-writing-en/SKILL.md    # 英文合并版
├── prompts/
│   ├── 精简版提示词.txt
│   └── quick-prompt-en.txt
├── install.ps1 / install.sh         # 复制技能到 ~/.dsh/skills
├── README.md / README.en.md
├── PRIVACY.md
└── LICENSE
```

> **维护提示：** 两个技能的目录描述同时写在 [`lib/index.js`](lib/index.js)（插件路由读取）
> 和各 `SKILL.md` 的 frontmatter（文件路由读取）。修改文案时两处要同步，否则两种安装方式
> 在技能目录里显示的描述会不一致。

## 效果对比

| | 防御性写作 | 反防御性写作 |
| :-- | :-- | :-- |
| 劣势表述 | 虽然本方法在两个同领域数据集上提高了准确率，但必须承认，我们尚未测试跨领域泛化，因此应谨慎理解这些结果。 | 本方法在两个同领域数据集上提高了准确率；跨领域泛化尚未评估。 |
| 结构 | 我们首先尝试了 A，然后尝试了 B，最后选择了 C | 问题 X 很关键，现有方法缺 Y，本文提出 Z，证据如下 |
| 实验 | 附录式堆结果，全覆盖无重点 | 每个实验承担一个论证职责 |
| 结论 | 最后一段突然自我否定 | 只强化记忆点：解决了什么、证明了什么、为什么重要 |
| 限定 | 到处都是“可能”“或许”“本文无意……” | 必要限定只写一次，放在方法与局限部分 |

## 适用场景

- 写 / 改论文摘要、引言、结论、贡献陈述
- 压缩论文篇幅（先砍什么，规则给了优先级）
- 组织实验章节（每个实验该承担什么职责）
- 写 rebuttal、模拟审稿前的自查
- 中文技术方案、SOP、报告去冗余与去说教

## 致谢 / Acknowledgements

本插件的全部写作规则都来自下面两个优秀的开源项目。没有它们，就没有这个合并版：

- **[Kiterlin/anti-defensive-writing](https://github.com/Kiterlin/anti-defensive-writing)** — 作者 **Kiterlin**。
  提供了操作层的核心方法：必要限定的判据、逐句检查清单、五步改写流程、技术方案与 SOP 写法、
  推荐与避免句式、指标与不利结果处理、中英文表达差异，以及“示例只供写法不供事实”的边界。
- **[Adkid-Zephyr/anti-defensive-writing-Skill](https://github.com/Adkid-Zephyr/anti-defensive-writing-Skill)** —
  作者 **Adkid-Zephyr**。提供了战略层的核心方法：把论文当作学术发布会的叙事原则、
  “打不过的维度不设为比赛”、“不占优的结果不说输”、实验的论证职责、摘要与结论的结构规则、
  处理不理想材料的七级优先级，以及“不给审稿人递刀子”的交稿自查。

感谢两位作者把这些经验整理成可复用的规则，并以 MIT 协议开放出来。
如果你觉得这个合并版有用，也请去给原仓库点一个 Star。

## 许可

MIT。规则与文档来自上述两个 MIT 项目；原始版权声明见 [LICENSE](LICENSE)。
隐私说明见 [PRIVACY.md](PRIVACY.md)。
