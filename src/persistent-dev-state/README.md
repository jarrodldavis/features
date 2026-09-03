# Persistent Dev State (persistent-dev-state)

Persist configured filesystem paths in a named volume that survives rebuilds

## Example Usage

```json
"features": {
    "ghcr.io/jarrodldavis/features/persistent-dev-state:1": {
        "paths": "~/.codex;~/.npm;/usr/local/share/my-tool"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| paths | Semicolon-separated list of paths to persist. Each entry must be an absolute path or begin with ~ (for home expansion). | string |  |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jarrodldavis/features/blob/main/src/persistent-dev-state/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
