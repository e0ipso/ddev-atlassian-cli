[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/e0ipso/ddev-atlassian-cli/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/e0ipso/ddev-atlassian-cli/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/e0ipso/ddev-atlassian-cli)](https://github.com/e0ipso/ddev-atlassian-cli/commits)
[![release](https://img.shields.io/github/v/release/e0ipso/ddev-atlassian-cli)](https://github.com/e0ipso/ddev-atlassian-cli/releases/latest)

# DDEV Atlassian CLI

## Overview

This add-on installs the [Atlassian CLI](https://developer.atlassian.com/cloud/acli/guides/introduction/) (`acli`) in the [DDEV](https://ddev.com/) web container and adds a `ddev acli` command to run it.

It also solves the OAuth login problem. `acli auth login` needs a browser, and the web container has none. The add-on ships an `xdg-open` shim that prints the login URL, so you can open it on your host and paste the resulting address back into the terminal.

## Installation

```bash
ddev add-on get e0ipso/ddev-atlassian-cli
ddev restart
```

After installation, make sure to commit the `.ddev` directory to version control.

## Usage

```bash
ddev acli auth login
ddev acli jira workitem view ENT-1234
```

`ddev acli` forwards all arguments to `acli`, so everything in the [Atlassian CLI documentation](https://developer.atlassian.com/cloud/acli/reference/commands/) works.

### Logging in

1. Run `ddev acli auth login`.
2. Open the URL it prints in a browser on your host and accept the permissions.
3. The browser then redirects to `http://127.0.0.1:<port>/callback?...` and fails to load, or shows a blank page. That is expected: the port belongs to `acli` inside the container.
4. Copy the full address from the browser's address bar and paste it into the prompt (the input is hidden), then press Enter. The shim replays it to `acli` from inside the container and the login finishes.

If the URL is not an Atlassian one, or no terminal is available, the shim only prints the URL.

## Name clash with the Acquia CLI

DDEV's web image already ships the Acquia CLI as `/usr/local/bin/acli`. This add-on does **not** remove it, so the two coexist:

| Command | Runs |
| ------- | ---- |
| `ddev acli ...` | Atlassian CLI (`/usr/bin/acli`) |
| `acli ...` inside `ddev ssh` or `ddev exec` | Acquia CLI (`/usr/local/bin/acli`) |
| `/usr/bin/acli ...` inside `ddev ssh` or `ddev exec` | Atlassian CLI |

Use `ddev acli` or the full path for Atlassian, and keep using bare `acli` for Acquia.

## What gets installed

| File | Purpose |
| ---- | ------- |
| `.ddev/web-build/Dockerfile.atlassian-cli` | Adds the Atlassian apt repository and installs `acli` in the web image |
| `.ddev/web-build/xdg-open.atlassian-cli` | Login shim, installed as `/usr/local/libexec/acli/xdg-open` |
| `.ddev/commands/web/acli` | The `ddev acli` command. Puts the shim on `PATH` for `acli` only |

The shim is kept off the default `PATH`, so other tools in the container still see no `xdg-open`.

The image is rebuilt on `ddev restart`. The `acli` package comes from the `stable` channel of the Atlassian apt repository, so it updates whenever the web image is rebuilt (`ddev debug rebuild`).

## Removal

```bash
ddev add-on remove atlassian-cli
ddev restart
```

## Contributing

Commits follow [Conventional Commits](https://www.conventionalcommits.org/), checked by [commitlint](https://commitlint.js.org/) in a husky `commit-msg` hook. Run `npm install` once to enable the hook.

Releases are automatic. After the `tests` workflow passes on `main`, [semantic-release](https://semantic-release.gitbook.io/) reads the commits since the last tag. A `feat:` commit makes a minor release, a `fix:` or `perf:` commit makes a patch release, and a `BREAKING CHANGE:` footer makes a major one. Other types do not release.

## Credits

**Contributed and maintained by [@e0ipso](https://github.com/e0ipso)**
