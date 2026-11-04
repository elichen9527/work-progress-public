---
name: work-log
description: 'Create or update evidence-based daily, weekly, and technical work logs. Use when asked to summarize engineering work, backfill a date, or maintain a reusable technical report.'
user-invocable: true
disable-model-invocation: true
---

# Work Log

Help the user create concise, accurate engineering work records from information they explicitly provide or sources available in the current workspace.

## Storage and scope

- Before writing, resolve the work-log root from the `WORK_LOG_DIR` environment variable. If it is unset, empty, inaccessible, or ambiguous, ask the user where records should be stored; do not choose a path silently.
- Store records under `daily/`, `weekly/`, and `technical/` beneath that root. Create only the required directory when the user requests a write.
- Treat the current workspace as the default evidence source. Read other projects or directories only when the user explicitly identifies them and access is available.
- Do not scan a home directory, unrelated repositories, chats, agent sessions, logs, or external services. Use such sources only when explicitly requested and the relevant tools/data are available.
- A report is an editable work record, not authorization to commit, push, publish, or configure automation. Ask for explicit authorization before any such action.

## Commands

Recognize these request forms:

- `/work-log` or `/work-log daily`: today's daily report.
- `/work-log daily YYYY-MM-DD`: a specific date.
- `/work-log backfill YYYY-MM-DD [YYYY-MM-DD]`: one date or an inclusive date range, with a maximum of seven calendar days per request.
- `/work-log weekly`: the seven complete calendar days before today.
- `/work-log weekly YYYY-MM-DD`: a report for the seven complete calendar days before the specified viewing date.
- `/work-log weekly YYYY-MM-DD YYYY-MM-DD`: an inclusive, completed seven-day range.
- `/work-log technical "topic"`: create or update a reusable technical report.
- `/work-log technical update topic-slug`: update an existing technical report.

If the dates, time zone, topic, or source scope are ambiguous, clarify before writing. Do not accept future dates or incomplete weekly ranges. Use the user's configured time zone when available; otherwise ask when the date boundary could affect the result.

## Evidence and accuracy

- Use only evidence that is available and relevant to the requested reporting period. A file's modification time, an uncommitted diff, a session title, or a later summary alone does not prove when work happened or that it succeeded.
- Distinguish completed work from plans, attempts, examples, and unverified claims. Preserve failures, blockers, partial results, and validation limits accurately.
- Never infer work from a missing report or missing evidence. Do not invent progress to fill a day or date range.
- For a weekly report, use existing daily reports in the requested period as the primary source. Missing days are simply omitted; do not silently widen or shorten the range.
- For technical reports, include reusable design, configuration, test method and result, troubleshooting, or research details only when supported by evidence. Keep historical results clearly dated and distinguish them from current validation.
- Do not copy long passages from external sources. Attribute relevant sources with a link or version when available.

## Daily reports

1. Read the existing report for the target date, if any, before editing.
2. Combine new evidence with existing valid entries. Update the same item when newer evidence changes its status; preserve unrelated entries and avoid duplicates.
3. Use Textile with the first line `h1. YYYY/MM/DD`. Each main entry should be a single `* ` bullet that states the work, actual result, and status. Add `** ` details only when they clarify evidence or limitations.
4. Keep the report concise and human-readable. Do not turn routine synchronization, repeated retries without progress, or agent activity into work achievements.

## Weekly reports

1. Use seven complete calendar days, inclusive, ending before the viewing date. For a custom range, verify that both endpoints are in the past and the range is exactly seven days.
2. Read only existing daily reports within that range, plus an existing weekly report if needed to preserve established headings. Do not treat older weekly reports as evidence for the current period.
3. Group related results under meaningful project or work-objective headings. Keep child tools and sub-projects under their parent objective unless they have an independent deliverable. Merge repeated progress across days.
4. Use Textile with `h2. YYYY/MM/DD - YYYY/MM/DD` for the date range and `h3.` for major work objectives. Each `* ` bullet should lead with the result and status; use `** ` for necessary evidence and limitations.
5. Do not add empty categories, invented work, or a future action list. Keep the summary proportional to the evidence available.

## Technical reports

1. Use `technical/<topic-slug>.textile`, where the slug contains lowercase letters, digits, and single hyphens. Ask the user to choose a slug if it is unclear.
2. Read an existing report before editing. Add or revise only supported information, retain still-valid details, and keep distinct test runs, versions, dates, and validation states distinguishable.
3. Organize with Textile headings such as `h1.`, `h2.`, and `h3.`. Include the environment, method, result, evidence source, and unverified scope when relevant.
4. Clearly label whether information is measured, documented expectation, user-provided example, unverified, or analysis. Never present an example as a current test result.

## Privacy and safe editing

- Before writing, remove or mask passwords, access tokens, private keys, credentials, personal data, customer information, and internal network or host details unless the user explicitly confirms that a specific detail is safe and necessary to include.
- Do not copy raw credentials, complete sensitive logs, or proprietary source code into a report. Prefer a brief summary and a safe placeholder.
- Re-read the target report's relevant section and inspect the proposed change for unintended disclosure before writing.
- Preserve unrelated content. Do not overwrite an entire report merely to change its format. If the file contains unreviewed changes, a conflict, or content whose safe handling is unclear, stop and ask.
- After writing, report the files changed, the evidence used, and any important limitations. Do not claim a report was published unless an explicitly authorized publish operation succeeded.
