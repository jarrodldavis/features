
# Persistent Home Directories (persistent-home)

Persists selected files and directories in the remote user's home across dev container rebuilds

## Example Usage

```json
"features": {
    "ghcr.io/jarrodldavis/features/persistent-home:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| paths | Colon-separated file or directory paths relative to the remote user's home. | string | - |
| codex | Persist Codex configuration and sessions (~/.codex). | boolean | false |
| githubCopilot | Persist GitHub Copilot agent sessions and session databases without persisting all VS Code server state. | boolean | false |

The `paths` option remains a colon-separated list of arbitrary paths relative
to the remote user's home directory. Existing files and directories are
supported; missing custom paths default to directories.

Enable the named presets without persisting all VS Code server state:

```json
"features": {
  "ghcr.io/jarrodldavis/features/persistent-home:1": {
    "codex": true,
    "githubCopilot": true,
    "paths": ".local/share/example"
  }
}
```

- `codex` persists `~/.codex`.
- `githubCopilot` persists Agent Host sessions and metadata, and the
  `github.copilot-chat` global storage directory. It does not preserve all of
  `~/.vscode-server/data` and therefore allows normal VS Code server
  initialization and extension installation.

Each selected path is moved into a named volume and replaced with a symlink.
The volume name includes `${devcontainerId}` and stays stable across rebuilds.
An existing populated volume wins over newly built image contents; removing a
configured path does not delete its data.

Paths must be canonical relative paths. Absolute paths, `~`, `.`, `..`,
trailing slashes, overlapping paths and symlinked parents are rejected.
Avoid persisting a broader path like `.vscode-server/data` alongside the
Copilot preset.

**Migration:** Existing deployments that previously persisted
`.vscode-server/data` must migrate the necessary saved session files into the
new volume targets and remove the old parent symlink before rebuilding. The
Feature intentionally rejects symlinked parent directories instead of
silently risking data loss.

For non-root `remoteUser`, passwordless sudo is required when the Feature
needs to correct named-volume ownership after UID/GID updates.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jarrodldavis/features/blob/main/src/persistent-home/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
