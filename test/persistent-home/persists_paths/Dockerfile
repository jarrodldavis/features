FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN mkdir -p /home/vscode/.codex \
    && printf 'existing\n' > /home/vscode/.codex/existing \
    && chown -R vscode:vscode /home/vscode/.codex
