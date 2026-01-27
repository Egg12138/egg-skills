# Git Commit Message Best Practices

## The seven rules

1. **Separate subject from body with a blank line.** Makes the message parseable and readable.
2. **Limit the subject to 50-72 characters.** Forces clarity and keeps toolchains tidy.
3. **Capitalize the subject line.** Except when starting with a lowercase identifier or symbol.
4. **Do not end the subject with a period.** Trailing punctuation adds noise.
5. **Use the imperative mood.** "Add feature" not "Added feature".
6. **Wrap the body at 72 characters.** Git does not wrap for you.
7. **Explain what and why, not how.** Code shows how; the message explains value.

## Context guidance

- Mention issue/ticket references, related commits, and performance/security notes.
- Keep commits atomic: one logical change, one feature, one fix.
- Document testing performed (unit tests, manual steps, performance runs).
- Highlight breaking changes explicitly with `BREAKING CHANGE:` and describe the migration path.
- Honor team conventions for DST/AR or other metadata fields.
