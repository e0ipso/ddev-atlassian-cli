[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/e0ipso/ddev-atlassian-cli/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/e0ipso/ddev-atlassian-cli/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/e0ipso/ddev-atlassian-cli)](https://github.com/e0ipso/ddev-atlassian-cli/commits)
[![release](https://img.shields.io/github/v/release/e0ipso/ddev-atlassian-cli)](https://github.com/e0ipso/ddev-atlassian-cli/releases/latest)

# DDEV Atlassian Cli

## Overview

This add-on integrates Atlassian Cli into your [DDEV](https://ddev.com/) project.

## Installation

```bash
ddev add-on get e0ipso/ddev-atlassian-cli
ddev restart
```

After installation, make sure to commit the `.ddev` directory to version control.

## Usage

| Command | Description |
| ------- | ----------- |
| `ddev describe` | View service status and used ports for Atlassian Cli |
| `ddev logs -s atlassian-cli` | Check Atlassian Cli logs |

## Advanced Customization

To change the Docker image:

```bash
ddev dotenv set .ddev/.env.atlassian-cli --atlassian-cli-docker-image="ddev/ddev-utilities:latest"
ddev add-on get e0ipso/ddev-atlassian-cli
ddev restart
```

Make sure to commit the `.ddev/.env.atlassian-cli` file to version control.

All customization options (use with caution):

| Variable | Flag | Default |
| -------- | ---- | ------- |
| `ATLASSIAN_CLI_DOCKER_IMAGE` | `--atlassian-cli-docker-image` | `ddev/ddev-utilities:latest` |

## Credits

**Contributed and maintained by [@e0ipso](https://github.com/e0ipso)**
