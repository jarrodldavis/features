The `paths` option is a colon-separated list of directories relative to the remote user's home directory. For example:

```json
"features": {
    "ghcr.io/jarrodldavis/features/persistent-home:1": {
        "paths": ".codex:.local/share/example"
    }
}
```

Each configured directory is moved into a named volume and replaced with a symlink. The volume name includes `${devcontainerId}`, so it is unique to the dev container and stable across rebuilds.

Existing directory contents are migrated when the Feature is first installed. On subsequent rebuilds, the existing volume contents take precedence over any corresponding directories from the rebuilt image. Removing a path from the option does not delete its existing data from the volume.

Paths must be canonical relative directory paths. Absolute paths, `~`, `.` or `..` components, trailing slashes, overlapping paths, and symlinked parent directories are rejected. File paths are not supported.

For a non-root `remoteUser`, passwordless `sudo` is required when the Feature needs to correct ownership of the volume after the container is created and any remote-user UID/GID update has been applied. The recursive ownership update is skipped when the volume already belongs to the remote user.
