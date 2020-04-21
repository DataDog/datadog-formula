# Contributing

First of all, thanks for contributing!

This document provides guidelines and instructions for contributing to this repository. To propose improvements, feel free to submit a PR.

## Submitting issues

* If you think you've found an issue, search the issue list to see if there's an existing issue.
* Then, if you find nothing, open a Github issue.

## Pull Requests

Have you fixed a bug or written a new feature and want to share it? Many thanks!

When submitting your PR, here are some items you can check or improve to facilitate the review process:

  * Have a proper commit history (we advise you to rebase if needed).
  * Write tests for the code you wrote.
  * Preferably, make sure that all unit tests pass locally and some relevant kitchen tests.
  * Summarize your PR with an explanatory title and a message describing your changes, cross-referencing any related bugs/PRs.
  * Open your PR against the `master` branch.

Your pull request must pass all CI tests before we merge it. If you see an error and don't think it's your fault, it may not be! [Join us on Slack][slack] or send us an email, and together we'll get it sorted out.

### Keep it small, focused

Avoid changing too many things at once. For instance if you're fixing a recipe and at the same time adding some code refactor, it makes reviewing harder and the _time-to-release_ longer.

### Commit messages

Please don't be this person: `git commit -m "Fixed stuff"`. Take a moment to write meaningful commit messages.

The commit message should describe the reason for the change and give extra details that allows someone later on to understand in 5 seconds the thing you've been working on for a day.

### Squash your commits

Rebase your changes on `master` and squash your commits whenever possible. This keeps history cleaner and easier to revert things. It also makes developers happier!

## Development

To ease the development of this formula, use Docker and Docker Compose with the compose file in `test/docker-compose.yaml`.

First, build and run a Docker container to create a masterless SaltStack minion. You have the option of choosing either
a Debian or Redhat-based minion. Then, get a shell running in the container.

```shell
    $ cd test/
    $ TEST_DIST=debian docker-compose run masterless /bin/bash
```

Once you've built the container and have a shell up and running, apply the SaltStack state on your minion:

```shell
    $ # On your SaltStack minion
    $ salt-call --local state.highstate -l debug
```

### Testing

A proper integration test suite is still a work in progress. In the meantime, use the Docker Compose file provided in the `test` directory to check out the formula in action.

#### Requirements

* Docker
* Docker Compose

#### Run the formula

```shell
    $ cd test/
    $ TEST_DIST=debian docker-compose up --build
```

Check the logs to see if all the states completed successfully.


[slack]: http://datadoghq.slack.com
