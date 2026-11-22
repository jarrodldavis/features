# Dev Container Features

This collection of [Dev Container Features](https://containers.dev/implementors/features/) is published to GitHub Container Registry.

| Feature | Description |
| --- | --- |
| [IPv4 Localhost](src/ipv4-localhost/README.md) | Prefers IPv4 loopback addresses in glibc-based containers. |
| [Match Host Time Zone](src/match-host-time-zone/README.md) | Matches the container time zone to the host using `/etc/localtime`. |
| [Uninstall Oh My Zsh](src/uninstall-oh-my-zsh/README.md) | Removes Oh My Zsh from the container if it is installed. |

Add the features you want to the `features` object in your `devcontainer.json`.

```json
{
  "features": {
    "ghcr.io/jarrodldavis/features/ipv4-localhost:1": {},
    "ghcr.io/jarrodldavis/features/match-host-time-zone:1": {},
    "ghcr.io/jarrodldavis/features/uninstall-oh-my-zsh:1": {}
  }
}
```
