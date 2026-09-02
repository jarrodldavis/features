# Persistent Dev State (persistent-dev-state)

Persist user-scoped tool state in a named volume that survives rebuilds

## Example Usage

```json
"features": {
    "ghcr.io/jarrodldavis/features/persistent-dev-state:1": {
        "persistVsCodeExtensions": true,
        "additionalHomeDirs": ".npm,.cache/pip,.local/share/pnpm/store"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| persistVsCodeExtensions | Persist the remote user's ~/.vscode-server/extensions directory in the state volume. | boolean | true |
| additionalHomeDirs | Comma-separated list of additional remote-user home-relative directories to persist (for example: .npm,.cache/pip,.local/share/pnpm/store). | string |  |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jarrodldavis/features/blob/main/src/persistent-dev-state/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
