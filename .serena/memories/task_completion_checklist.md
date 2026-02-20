# Task Completion Checklist

## Before Claiming Done
- [ ] All tests pass (`flutter test`)
- [ ] No analysis errors (`flutter analyze`)
- [ ] Code is formatted (`dart format .`)
- [ ] No unused imports
- [ ] No hardcoded secrets/credentials

## For Feature Implementation
- [ ] Follows 3-layer architecture
- [ ] Domain layer has interfaces/entities only
- [ ] Data layer implements domain interfaces
- [ ] Presentation uses domain interfaces (not data)
- [ ] Error handling via AppException hierarchy

## For Bug Fixes
- [ ] Root cause identified
- [ ] Fix addresses root cause (not symptoms)
- [ ] Tests added/updated to prevent regression
- [ ] Edge cases considered

## For Code Changes
- [ ] No breaking changes to existing APIs
- [ ] Updated related documentation if needed
- [ ] Added dartdocs for public APIs

## Pre-commit
- [ ] Run `flutter analyze`
- [ ] Run `flutter test`
- [ ] Check git status
- [ ] Commit with conventional message

## Post-commit (if needed)
- [ ] Push to remote
- [ ] Create PR if applicable
- [ ] Update project management tool
