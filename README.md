# vbz-pi-setup

Replicates my Pi coding-agent setup on a new Windows machine: config, all 18 extensions, AGENTS.md, and my 22 skills. No API keys included.

## Run on Windows

1. Install [Node.js LTS](https://nodejs.org) and Git.
2. Install Pi:
   ```powershell
   npm install -g @earendil-works/pi-coding-agent
   ```
3. Clone this repo and run:
   ```powershell
   git clone <this-repo-url>
   cd vbz-pi-setup
   powershell -ExecutionPolicy Bypass -File .\install-pi-extensions.ps1
   ```
   Takes about 5 minutes on a decent connection.

## What it does

1. Writes `%USERPROFILE%\.pi\agent\settings.json` (theme, ollama-cloud default model, powerline, compaction off, `-builtin:mcp`) — skipped if the file already exists, so re-runs are safe.
2. Runs `pi install` for every package listed on the Mac (`settings.json > packages`). Failures don't stop the run; a summary prints at the end.
3. Copies the bundled `AGENTS.md` to `%USERPROFILE%\.pi\agent\AGENTS.md` and `skills\*` to `%USERPROFILE%\.agents\skills`.

## Not included (manual)

- **API key** — lives in `~/.pi/agent/auth.json` on the Mac (`ollama-cloud`, `kiro`, `opencode-go`). Add via pi's login flow or copy just the provider entry you need. The default model won't work until then.
- **pi-provider-kiro** — local folder on the Mac, not on npm. Copy the folder over, then `pi install <path-to-folder>`.
- **sureforge-pi** (`http://vvbzbox:3030/...`) — only resolvable from the LAN where that box lives.
