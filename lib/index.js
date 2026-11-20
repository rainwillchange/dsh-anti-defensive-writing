/**
 * Anti-Defensive Writing — bundled skill provider for DeepSeek Harness (dsh).
 *
 * Registers two instruction-only skills on `ctx.skills`:
 *   - anti-defensive-writing     (Simplified Chinese)
 *   - anti-defensive-writing-en  (English)
 *
 * Both skill bodies live in `../skills/<name>/SKILL.md`. The provider reads the
 * body on every load, so editing a SKILL.md takes effect without a restart.
 *
 * This module intentionally imports only Node built-ins and hardcodes
 * `BUNDLED_SKILL_RANK` (600), so it stays loadable across dsh versions without
 * depending on `@deepseek-ai/dsh-skill` being resolvable from the profile.
 *
 * @module anti-defensive-writing
 */

import { readFile } from "node:fs/promises";
import { join, sep } from "node:path";
import { fileURLToPath } from "node:url";

/** Cordis plugin name. */
const name = "anti-defensive-writing";

/** Service required by the bundled provider. */
const inject = ["skills"];

/** Unique provider name registered on `ctx.skills`. */
const PROVIDER_NAME = "anti-defensive-writing";

/** Rank for packaged/bundled skill providers (matches @deepseek-ai/dsh-skill). */
const BUNDLED_SKILL_RANK = 600;

const SKILLS_ROOT = fileURLToPath(new URL("../skills/", import.meta.url));

/** Skill catalog: directory name, kebab-case skill name, and catalog description.
 *
 * Keep each description identical to the `description` field in the matching
 * `SKILL.md`. The plugin route reads this list, while the `dsh-skill-filesystem`
 * route reads the frontmatter, and both should show the same catalog entry.
 */
const SKILLS = [
  {
    name: "anti-defensive-writing",
    description:
      "论文写作、修改、压缩与实验组织的全流程反防御性写作指南：把论文视为学术发布会，围绕最强优势组织叙事，直接推进主张，删除不必要的免责声明、叠加保留、道歉式表述与自我贬低，同时保留为准确、伦理、法律、安全与方法透明所必需的限定。适用于论文摘要、引言、结论、贡献陈述、讨论、rebuttal、基金申请、技术方案、SOP 与报告。触发词：论文润色、论文修改、写摘要、写引言、写结论、压缩论文、rebuttal、回复审稿意见、组织实验、论文AI味、防御性写作、心虚、去免责声明。",
  },
  {
    name: "anti-defensive-writing-en",
    description:
      "Anti-defensive writing for papers, abstracts, rebuttals, grant proposals, SOPs, and reports: organize around the strongest supported advantage, advance claims directly, and cut unnecessary disclaimers, stacked hedges, and self-undermining phrasing while keeping the limits that accuracy and method require. Triggers: polish, revise, conclusion, shorten, reviewers, defensive writing, caveats.",
  },
];

/** Normalize a filesystem path to forward slashes for the model-facing resource hint. */
function toResourcePath(path) {
  return path.split(sep).join("/");
}

/** Strip required YAML frontmatter and return the body. */
function parseSkill(raw, path) {
  const frontmatter = /^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/u.exec(raw);
  if (frontmatter === null) {
    throw new Error(`anti-defensive-writing: ${path} has no YAML frontmatter`);
  }
  return raw.slice(frontmatter[0].length).trim();
}

function candidateFor(skill) {
  const directory = join(SKILLS_ROOT, skill.name);
  const locator = join(directory, "SKILL.md");
  return {
    name: skill.name,
    description: skill.description,
    invocation: { modelInvocable: true, userInvocable: true },
    provider: PROVIDER_NAME,
    source: "bundled",
    rank: BUNDLED_SKILL_RANK,
    resourceBase: { kind: "directory", path: toResourcePath(directory) },
    locator,
  };
}

const provider = {
  name: PROVIDER_NAME,
  list: () => Promise.resolve(SKILLS.map(candidateFor)),
  async get(candidate, options) {
    const { rank: _rank, locator, ...summary } = candidate;
    const raw = await readFile(locator, { encoding: "utf8", signal: options?.signal });
    return { ...summary, content: parseSkill(raw, locator) };
  },
};

/** Register the bundled Anti-Defensive Writing skills on `ctx.skills`. */
function apply(ctx) {
  ctx.skills.registerProvider(() => provider);
}

export { apply, inject, name };
