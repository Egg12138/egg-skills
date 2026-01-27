# Conventional Commits Specification

Version: 1.0.0

## Summary

Conventional Commits is a lightweight convention that adds structure to commit messages, enabling tooling such as changelog generation and semantic versioning.

## Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that do not affect code meaning
- **refactor**: Code changes that neither fix bugs nor add features
- **perf**: Code that improves performance
- **test**: Adding or correcting tests
- **chore**: Changes to build/process tooling

### Description rules

- Use imperative, present tense ("change", not "changed" or "changes").
- Do not capitalize the first word unless it is a proper noun or identifier.
- Do not end the subject with a period.

### Body guidance

- Explain _what_ and _why_, not _how_.
- Wrap lines around 72 characters.
- Add motivation, alternatives considered, performance or security notes.

### Footers

- `BREAKING CHANGE:` for breaking changes
- `Fixes #123`, `Refs #123` for ticket references

## Benefits

- Easier changelog automation
- Predictable semantic version bumps
- Clear communication with teammates

## References
- https://www.conventionalcommits.org/
