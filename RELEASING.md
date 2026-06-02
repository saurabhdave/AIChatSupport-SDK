# Releasing

AIChatSupport is distributed via Swift Package Manager, so **the git tag is the version**.
There is no version field in `Package.swift` to bump — SPM resolves releases from semver tags.

## Versioning

This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html):

- **MAJOR** — source-breaking public API changes.
- **MINOR** — backwards-compatible additions.
- **PATCH** — backwards-compatible bug fixes.

The public API surface is everything marked `public` in `Sources/AIChatSupport` (providers,
`AIChatConfiguration`, `AppContext`, `AIChatTheme`, `HostAppTheme`, the view modifiers, and
`AIChatDelegate`).

## Cutting a release

1. **Land all changes** for the release on `main` and make sure the test suite passes:
   ```sh
   xcodebuild test -scheme AIChatSupport -destination 'platform=iOS Simulator,name=iPhone 17'
   ```
2. **Update `CHANGELOG.md`:** rename the `## [Unreleased]` section to the new version with
   today's date (`## [X.Y.Z] - YYYY-MM-DD`), add a fresh empty `## [Unreleased]` above it, and
   update the compare/tag links at the bottom of the file.
3. **Commit** the changelog: `docs: release X.Y.Z`.
4. **Tag and push:**
   ```sh
   git tag X.Y.Z
   git push origin main X.Y.Z
   ```
5. **Publish the GitHub Release** from the tag, using that version's changelog section as the
   notes:
   ```sh
   gh release create X.Y.Z --title "X.Y.Z" --notes-file <(sed -n '/## \[X.Y.Z\]/,/## \[/p' CHANGELOG.md | sed '$d')
   ```

Consumers pin the SDK with `.upToNextMajor(from: "X.Y.Z")`, so avoid source-breaking changes
outside a major bump.
