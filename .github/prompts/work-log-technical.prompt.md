---
name: work-log-technical
description: 'Create or update an evidence-based reusable technical work report.'
argument-hint: '[topic] [authorized source paths]'
agent: agent
---

Create or update a reusable technical report for the topic identified by the user.

Before proceeding, read and follow the [work-log skill](../skills/work-log/SKILL.md), especially its storage, evidence, privacy, and safe-editing rules.

- Use only the current workspace and any source paths the user explicitly names for this request.
- Identify the stable topic slug; ask the user if the topic or slug is ambiguous.
- Read an existing report before editing. Add only supported, reusable technical information and preserve still-valid details.
- Distinguish measured results, documented expectations, examples, and unverified analysis. Include test dates, versions, methods, evidence, and limitations when available; do not claim tests were run unless evidence supports that.
- Write in the configured work-log root using the Textile format defined by the Skill. If the root is unclear, ask before writing.
- Do not execute tests, deploy, change source projects, commit, push, publish, or configure automation unless the user separately and explicitly requests that action.

Report the updated path, topic, evidence and validation status, and any important limitations.
