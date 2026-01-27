# Semantic Versioning Guidance

Semantic Versioning (SemVer) ties commit history to release numbering. A commit message that flags a feature, fix, or breaking change feeds release automation.

## Version bump triggers

- **Major**: Breaking change in behavior, API, configuration, or data layout. Prefix the footer with `BREAKING CHANGE:` and explain the migration.
- **Minor**: New feature or capability that remains backward compatible.
- **Patch**: Bug fix, documentation, tests, or other non-behavioral improvements.

## Workflow tips

- Tie commits to tickets or change requests (DST/AR references) so reviewers can assess impact.
- Use consistent type prefixes so CI can aggregate the highest severity change per release.
- When in doubt, mark a commit with a more conservative bump and revisit during triage.
