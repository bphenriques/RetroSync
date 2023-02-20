# Quick Installation

## Setup SSH Connection 

To quickly install on the device without having to introduce your key everytime, setup pubkey SSH authentication. Once
you have generated a key: `ssh-copy-id <host>`.

Ensure that the following is set under `/etc/ssh/sshd_config`:
```shell
StrictMode no
RSAAuthentication yes
PubkeyAcceptedKeyTypes *
PubKeyAuthentication yes
AuthorizedKeysFile      .ssh/authorized_keys
```

Note that, `StrictMode` is not advised as it verifies the [correct permissions](https://chemicloud.com/kb/article/ssh-authentication-refused-bad-ownership-or-modes-for-directory/). However, I found it useful to avoid
messing too much with ArkOS.

The, suggest setting `~/.ssh.config`:
```shell
Host rg353m
HostName <ip>
IdentityFile ~/.ssh/id_rsa
User ark
```

## Installing onto the device

```shell
$ ./bin/dev-install.sh rg353m arkos "/opt/system/Tools"
```

# Testing

Ensure that the Bash version is at least version 4, on MacOS you can install the latest version using Homebrew and
ensure that it takes precedence:
```shell
$ export PATH="/opt/homebrew/bin/:${PATH}"
```
