# Testing

Ensure that the Bash version is at least version 4, on MacOS you can install the latest version using Homebrew and
ensure that it takes precedence:
```shell
$ export PATH="/opt/homebrew/bin/:${PATH}"
```

```shell
$ find test -type f -name '*.sh' | xargs /opt/homebrew/bin/bash  
```
