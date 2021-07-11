# pylint-gitlab
pylint-gitlab for littleworld ci

This project provides pylint formatters for a nice integration with GitLab CI.

| Formatter | Description |
| --- | --- |
| `GitlabCodeClimateReporter` | Maps the linting result in [Code Climate format](https://docs.gitlab.com/ee/user/project/merge_requests/code_quality.html) |
| `GitlabPagesHtmlReporter` | Creates a table in an HTML page with linting results and links to source code. |

## Usage

Install package `pylint-gitlab`:

```sh
pip install pylint-gitlab
```

The `pylint` package is a dependency of `pylint-gitlab` so it will be installed automatically.

Now the formatters can be used by running `pylint` command and setting custom output formats with parameter `--output-format`.

```sh
pylint --exit-zero --output-format=pylint_gitlab.GitlabCodeClimateReporter . > codeclimate.json
pylint --exit-zero --output-format=pylint_gitlab.GitlabPagesHtmlReporter . > pylint.html
```

Alternatively, you can load the `pylint_gitlab` plugin and then use the shortened `--output-format` names:

```sh
pylint --exit-zero --load-plugins=pylint_gitlab --output-format=gitlab-codeclimate . > codeclimate.json
pylint --exit-zero --load-plugins=pylint_gitlab --output-format=gitlab-pages-html . > pylint.html
```

### GitLab CI integration

Here is a minimalistic version for a `.gitlab-ci.yml` file:
```yaml
pylint:
  stage: test
  image: python:3.7-slim
  before_script:
    - mkdir -p public/badges public/lint
    - echo undefined > public/badges/$CI_JOB_NAME.score
    - pip install pylint-gitlab
  script:
    - pylint --exit-zero --output-format=text $(find -type f -name "*.py" ! -path "**/.venv/**") | tee /tmp/pylint.txt
    - sed -n 's/^Your code has been rated at \([-0-9.]*\)\/.*/\1/p' /tmp/pylint.txt > public/badges/$CI_JOB_NAME.score
    - pylint --exit-zero --output-format=pylint_gitlab.GitlabCodeClimateReporter $(find -type f -name "*.py" ! -path "**/.venv/**") > codeclimate.json
    - pylint --exit-zero --output-format=pylint_gitlab.GitlabPagesHtmlReporter $(find -type f -name "*.py" ! -path "**/.venv/**") > public/lint/index.html
  after_script:
    - anybadge --overwrite --label $CI_JOB_NAME --value=$(cat public/badges/$CI_JOB_NAME.score) --file=public/badges/$CI_JOB_NAME.svg 4=red 6=orange 8=yellow 10=green
    - |
      echo "Your score is: $(cat public/badges/$CI_JOB_NAME.score)"
  artifacts:
    paths:
      - public
    reports:
      codequality: codeclimate.json
    when: always

pages:
  stage: deploy
  image: alpine:latest
  script:
    - echo
  artifacts:
    paths:
      - public
  only:
    refs:
      - master
```

You can then use the published badge for linting results.

[![pylint](https://smueller18.gitlab.io/pylint-gitlab/badges/pylint.svg)](https://smueller18.gitlab.io/pylint-gitlab/lint/)

```markdown
[![pylint](https://<USER/GROUP_NAME>.gitlab.io/<PROJECT_PATH>/badges/pylint.svg)](https://<USER/GROUP_NAME>.gitlab.io/<PROJECT_PATH>/lint/)
```

## badges GitLab CI for LittleWorld
image:
```
https://gitlab.com/%{project_path}/-/jobs/artifacts/%{default_branch}/raw/public/badges/pylint.svg?job=pylint
or
https://gitlab.com/littleworld1/littleworld/-/jobs/artifacts/main/raw/public/badges/pylint.svg?job=pylint
```
link:
```
https://gitlab.com/%{project_path}/-/jobs/artifacts/%{default_branch}/file/public/lint/index.html?job=pylint
or
https://gitlab.com/littleworld1/littleworld/-/jobs/artifacts/main/file/public/lint/index.html?job=pylint
```
