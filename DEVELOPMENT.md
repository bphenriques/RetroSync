# Quick Installation

To quickly iterate, it is far easier:
- Have the SSH connection setup with passkey.
- Copying the files over to the file directly.

Having that said, two steps:

## Setup SSH Connection 

To quickly install on the device without having to introduce your key everytime, setup pubkey SSH authentication. Once
you have generated a key, you can copy the authorized key to: `ssh-copy-id ark@192.168.68.61`

### Troubleshooting

Use `-v` to see any errors. One the issues I found is bad permissions on the server home directory and incorrect settings.
- Check if the server has the following set under `/etc/ssh/sshd_config`:
```shell
RSAAuthentication yes
PubkeyAcceptedKeyTypes *
PubKeyAuthentication yes
AuthorizedKeysFile      .ssh/authorized_keys
```
- Review permissions ([url](https://chemicloud.com/kb/article/ssh-authentication-refused-bad-ownership-or-modes-for-directory/)):
```shell
$ chmod go-w /home/ark
$ chmod 700 /home/ark/.ssh
$ chmod 600 /home/ark/.ssh/authorized_keys
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

```shell
$ find test -type f -name '*.sh' | xargs /opt/homebrew/bin/bash  
```

# QA

## My script has broken and now my input does not work

SSH to the machine and run the following to reset the input:
```shell
$ pgrep -f oga_controls | sudo xargs kill -9
```
