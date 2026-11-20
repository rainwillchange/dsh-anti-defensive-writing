# Anti-Defensive Writing · dsh plugin

A single [DeepSeek Harness (dsh)](https://github.com/deepseek-ai/deepseek-harness) plugin that merges
[Kiterlin/anti-defensive-writing](https://github.com/Kiterlin/anti-defensive-writing) and
[Adkid-Zephyr/anti-defensive-writing-Skill](https://github.com/Adkid-Zephyr/anti-defensive-writing-Skill)
into one set of rules, shipping both a Simplified Chinese and an English skill.

> **A paper is a press conference, not a project summary, a lab log, or a self-audit.**

---

## What the merge adds

| Source | Contribution |
| :-- | :-- |
| **Adkid-Zephyr** (press-release principle) | Strategy: organize around strengths only, never set a contest you cannot win, never say you lost, give every experiment an argumentative duty, open like a press conference, seven-step priority for unfavorable material, “don’t hand the reviewer a knife” checklist. |
| **Kiterlin** (anti-defensive writing) | Operations: the test for a necessary limitation, sentence-level checklist, five-step rewrite procedure, technical-plan / SOP rules, preferred and discouraged patterns, metrics and unfavorable-result handling, Chinese/English phrasing differences, examples supply phrasing but not facts. |

The merged skill is not a concatenation. The narrative rules decide *what* to write and *where*; the rewrite rules decide *how each sentence* becomes accurate, direct, and confident. The two cross-reference each other instead of repeating themselves.

## Install

### Option 1 — install as a dsh plugin (market listing, per-profile switch)

The plugin is pure ESM with no build step and no third-party runtime dependencies. Install this folder as a local package into a target profile:

```sh
# Requires the dsh CLI (dsh --version); replace <profile> with your profile name
dsh plugin --profile <profile> add "<absolute path to this folder>"

# or use the explicit link: spec
dsh plugin --profile <profile> add "link:<absolute path to this folder>"
```

Restart `dsh --profile <profile>` (or wait for HMR). `cordis.patch.yml` inserts the
`anti-defensive-writing` entry into the profile’s loader tree, and the entry
registers both skills on `ctx.skills`.

> ⚠️ **A plugin install applies to that profile only.** It is recorded in that
> profile’s `package.json → dsh.profile.bundles` and its own `node_modules`.
> After creating or switching to another profile, install it again there; for a
> setup shared by every profile, use Option 2 (`install.ps1` writes to
> `~/.dsh/skills` by default).

> **DSH Desktop users:** the desktop app usually does not put `dsh` on PATH, and it
> owns its profile (`~/.dsh/profiles/desktop`). Use Option 2, or install this folder
> as a local source from the desktop Plugins page; to install into the desktop
> profile from a terminal, quit the desktop app completely first.

### Option 2 — copy the skill folders (easiest across profiles and hosts)

The copy route writes to a **user-level skill root**, independent of any profile and
without the `dsh` CLI or a plugin restart: every dsh profile scans it, and
`~/.agents/skills` is also shared with compatible hosts such as Claude Code and Codex.

dsh’s `@deepseek-ai/dsh-skill-filesystem` scans these roots:

| Rank | Source | Path |
| :-- | :-- | :-- |
| 100 | project | `<project root>/.dsh/skills` |
| 200 | project | `<project root>/.agents/skills` |
| 400 | user | `~/.dsh/skills` (`$DSH_HOME/skills`) |
| 500 | user | `~/.agents/skills` (`$DSH_AGENTS_HOME/skills`) |

Copy both skills into the user root with the bundled scripts:

```powershell
# Windows PowerShell
.\install.ps1

# shared across compatible agents
.\install.ps1 -Dest ~\.agents\skills

# replace an existing install
.\install.ps1 -Force
```

```sh
# macOS / Linux
./install.sh
./install.sh --dest ~/.agents/skills
```

Or copy `skills/anti-defensive-writing` and
`skills/anti-defensive-writing-en` into any of those directories by hand.

### Option 3 — copy the prompt only

Paste [`prompts/quick-prompt-en.txt`](prompts/quick-prompt-en.txt)
([中文](prompts/精简版提示词.txt)) at the start of a conversation, then send your draft.

## Use

- Chinese skill: `anti-defensive-writing`
- English skill: `anti-defensive-writing-en`

Both are user-invocable, so you can also type:

```text
/anti-defensive-writing
/anti-defensive-writing-en
```

then send the paragraph to revise, for example:

> Revise this introduction around its strongest supported contribution. Preserve facts and essential qualifications.

> 帮我重写这段摘要，围绕最强的证据组织贡献，保留准确的数字与研究范围。

> 帮我检查这段 rebuttal，直接回答审稿人的问题，并指出哪些表述缺少证据。

## Repository layout

```text
anti-defensive-writing/
├── package.json                     # dsh package manifest (dsh.bundle.patch / exports)
├── cordis.patch.yml                 # inserts the plugin into the profile loader tree
├── lib/index.js                     # skill provider: registers both SKILL.md files
├── skills/
│   ├── anti-defensive-writing/SKILL.md       # merged Chinese skill
│   └── anti-defensive-writing-en/SKILL.md    # merged English skill
├── prompts/
│   ├── 精简版提示词.txt
│   └── quick-prompt-en.txt
├── install.ps1 / install.sh         # copy skills into ~/.dsh/skills
├── README.md / README.en.md
├── PRIVACY.md
└── LICENSE
```

> **Maintenance note:** each skill’s catalog description lives in both
> [`lib/index.js`](lib/index.js) (read by the plugin route) and the matching
> `SKILL.md` frontmatter (read by the file route). Update both together, or the two
> install paths will show different descriptions.

## Before / after

| | Defensive writing | Anti-defensive writing |
| :-- | :-- | :-- |
| Weakness framing | Although our method improves accuracy on two in-domain datasets, we must acknowledge that cross-domain generalization has not been tested, so these results should be interpreted cautiously. | Our method improves accuracy on two in-domain datasets; cross-domain generalization has not been evaluated. |
| Structure | We first tried A, then B, and finally chose C | Problem X matters, existing methods lack Y, we propose Z, evidence follows |
| Experiments | An appendix-style pile of results | Every experiment carries one argumentative duty |
| Conclusion | Sudden self-negation in the final paragraph | Reinforces the takeaway only |
| Limits | “may,” “perhaps,” and “we do not claim” everywhere | Necessary limits written once, in methods and limitations |

## Use cases

- Writing or revising abstracts, introductions, conclusions, and contribution statements
- Cutting paper length (the decision rules say what to cut first)
- Organizing the experiments section
- Pre-rebuttal self-check and reviewer simulation
- Removing redundancy and admonitory tone from Chinese technical plans, SOPs, and reports

## Versioning

- Current version: **v1.0.0**.
- When the skill content or plugin behavior changes substantively, bump
  `package.json` `version` and tag the matching `vX.Y.Z`; README- or
  comment-only edits do not need a version bump.
- Hosts that support git specs can pin a tag, for example
  `github:rainwillchange/dsh-anti-defensive-writing#v1.0.0`.

## Acknowledgements

Every writing rule in this plugin comes from two excellent open-source projects.
Without them, this merged version would not exist:

- **[Kiterlin/anti-defensive-writing](https://github.com/Kiterlin/anti-defensive-writing)** by
  **Kiterlin** — the operating layer: the test for a necessary limitation, the
  sentence-level checklist, the five-step rewrite procedure, technical-plan and
  SOP rules, preferred and discouraged patterns, metrics and unfavorable-result
  handling, Chinese/English phrasing differences, and the boundary that examples
  supply phrasing but not facts.
- **[Adkid-Zephyr/anti-defensive-writing-Skill](https://github.com/Adkid-Zephyr/anti-defensive-writing-Skill)** by
  **Adkid-Zephyr** — the strategic layer: the press-conference narrative
  principle, “never set a contest you cannot win,” “never say you lost,” the
  argumentative duty of every experiment, abstract and conclusion structure,
  the seven-step priority for unfavorable material, and the “don’t hand the
  reviewer a knife” pre-submission checklist.

Thank you both for distilling this experience into reusable rules and releasing
them under MIT. If this merged plugin helps you, please give the original
repositories a star.

## License

MIT. The rules and documentation come from the two MIT projects above; the merged
packaging is this plugin’s. See [LICENSE](LICENSE) for the original copyright
notices and [PRIVACY.md](PRIVACY.md) for the privacy policy.
