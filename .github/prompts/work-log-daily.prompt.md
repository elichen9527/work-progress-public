---
name: work-log-daily
description: 'Create or update an evidence-based daily engineering work log.'
argument-hint: '[date] [authorized source paths]'
agent: agent
---

Create or update a daily work log for the requested date. If no date is provided, use today's date in the user's configured time zone.

Before proceeding, read and follow the [work-log skill](../skills/work-log/SKILL.md), especially its storage, evidence, privacy, and safe-editing rules.

- Use only the current workspace and any source paths the user explicitly names for this request.
- Use evidence that can be attributed to the requested date. Do not infer completion or test success from plans, timestamps, uncommitted changes, or summaries alone.
- Read the existing report first, merge same-topic updates, and preserve unrelated valid entries.
- Write the report to the configured work-log root using the Textile format defined by the Skill. If the root or date boundary is unclear, ask before writing.
- Do not perform historical backfill unless requested. Do not commit, push, publish, or configure automation.

Report the updated path, evidence sources used, and any important validation or coverage limitations.
