# rhce-docker
This repo contains a lightweight docker-compose file in order to practice Ansible. 

## Why not vagrant
Too many dependencies (virtualization layer and vagrant).

## Why not use a public cloud setup
Most of the time you will need a credit card. 

## Why I let you install Ansible yourself
Your mum also can't do your laundry forever. No seriously, you will have to be able to setup ansible for yourself at the RHCE (and the .vimrc is helpfull as well).

## Requirements
You will need docker and docker-compose. 

Tested with:
```bash
tux@tux-supercomputer:~/Documents/rhce-docker$ docker version
Client: Docker Engine - Community
 Version:           20.10.17
 API version:       1.41
 Go version:        go1.17.11
 Git commit:        100c701
 Built:             Mon Jun  6 23:02:57 2022
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true

Server: Docker Engine - Community
 Engine:
  Version:          20.10.17
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.17.11
  Git commit:       a89b842
  Built:            Mon Jun  6 23:01:03 2022
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.6.8
  GitCommit:        9cd3357b7fd7218e4aec3eae239db1f68a5a6ec6
 runc:
  Version:          1.1.4
  GitCommit:        v1.1.4-0-g5fd4c4d
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0

tux@tux-supercomputer:~/Documents/rhce-docker$ docker-compose --version
docker-compose version 1.25.0, build unknown
```

# Install ansible on the controller
We will install ansible 2.9 (as of Wed Sep 28 21:55:28 UTC 2022 RHCE EX294 tests against this version )
```
tux@tux-supercomputer:~/Documents/rhce-docker$ docker exec -it ansible bash
[root@2f7a3d98043f /]# yum install -y centos-release-ansible-29
[root@2f7a3d98043f /]# yum install -y ansible
[root@2f7a3d98043f /]# ansible --version
ansible 2.9.27
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.6/site-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.6.8 (default, Apr 29 2022, 13:46:02) [GCC 8.5.0 20210514 (Red Hat 8.5.0-10)]
```

# Sane .vimrc
```
echo 'set ai et ts=2 sw=2' > ~/.vimrc # set autoindent expandtab tabshift=2 shiftwidth=2
```

# Generate ssh key and distribute it
```
[root@2f7a3d98043f /]# ssh-keygen -f /root/.ssh/id_rsa 
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:DnesUJyq4FAJvngwKB9O94fCeTqvMKD7KIPCOzeANRM root@2f7a3d98043f
The key's randomart image is:
+---[RSA 3072]----+
|.                |
|o.E.   . .       |
|=.=..   +        |
|oB=+ o + .       |
|=o=o+ B S o      |
|o* . = * o       |
|+ = +   o        |
|== = o           |
|=+= o..          |
+----[SHA256]-----+
[root@2f7a3d98043f /]# ssh-copy-id root@node1
```

# ToDo
- Finish DOC
