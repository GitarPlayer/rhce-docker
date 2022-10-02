# rhce-docker
This repo contains a lightweight docker-compose file in order to practice Ansible. 

## Why not vagrant
Too many dependencies (virtualization layer and vagrant).

## Why not use a public cloud setup
Most of the time you will need a credit card. Also you will need something like dynamic inventory or some templating functionality to get the IPs of the nodes or you hardcode them. Anyways the complexity is too big for a lab.


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
# Usage
The real problem is distributing the ssh pub key to the nodes dynamically. Because the ansible-controller container can only make use of the docker DNS once it is up. That's why this ugly ad-hoc command is being used. Things I considered:
1. Seed the ssh keys to make distribution easier (not possible with ssh-keygen)
2. Use a shared volume that contains the ssh keypair (the mount is only available when the service is up, so additional complexity and it stills need a docker-compose run cmd)
3. Configure the containers with the Dockerfile that an ansible ad-hoc authorized_key docker-compose run distributes the key
4. create ssh-keygen before docker-compose up and add the keys with the docker ADD instruction.

I tried 3 and it worked but it's ugly to run such a long docker-compose run cmd. 4 is the best compromise since most OS include ssh-keygen and you only need to run it the first time. Then you can just tear down your containers and recreate it withouth having to remember a complicated docker-compose run command.

```bash
ssh-keygen -f $PWD/id_rsa
# The <src> path must be inside the context of the build; you cannot ADD ../something /something, because the first step of a docker build is to send the context directory (and subdirectories) to the docker daemon. from https://docs.docker.com/engine/reference/builder/
mv id_rsa ansible-controller/
mv id_rsa.pub ansible-nodes/
docker-compose up -d
docker exec -it ansible bash
```

# Install ansible on the controller
## Install ansible via package manager
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

## install ansible via pip
```
yum install @python39 -y
python3.9 -m pip name=ansible
```

# Install missing collections
This will lack some collections that are present when you install ansible from the RedHat repo. But you always install them yourself like so
```bash
ansible-galaxy collection install ansible.posix -vv
ansible-galaxy collection list 
```

# Sane .vimrc
```
echo 'set ai et ts=2 sw=2' > ~/.vimrc # set autoindent expandtab tabshift=2 shiftwidth=2
```

# Create a inventory for bootstraping
```bash
cat > inventory << EOF
[nodes]
node1
node2
EOF
```

# Add host keys to known_hosts
Ok this is a bit a pain to automate. Until I have something better this will have to do:
```
echo yes | ansible node1 -i inventory -m 'user' -a 'name=ansible state=present'
echo yes | ansible node2 -i inventory -m 'user' -a 'name=ansible state=present'
```
# Create ansible user on nodes
We will use the ansible user and configure it with passwordless sudo
```bash
ansible nodes -i inventory -m 'user' -a 'name=ansible state=present' --ask-pass
ansible nodes -i inventory -m 'copy' -a 'dest=/etc/sudoers.d/ansible content="ALL = (ALL) NOPASSWD: ALL perm=0440"' --ask-pass
```
# Generate ssh key and distribute it

## ssh key generation
```
[root@2f7a3d98043f /]# ssh-keygen -f /home/ansible/.ssh/id_rsa 
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
```
## Distributing key with ssh-copy-d
```
[root@099c9cdbbd61 /]# ssh-copy-id node1
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
The authenticity of host 'node1 (172.18.0.3)' can't be established.
ECDSA key fingerprint is SHA256:5XauytFAzJYWT7R8LmU5zD2UAiaGSYBS+YBn0I+EE5o.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@node1's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'node1'"
and check to make sure that only the key(s) you wanted were added.

[root@099c9cdbbd61 /]# ssh-copy-id node2
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
The authenticity of host 'node2 (172.18.0.4)' can't be established.
ECDSA key fingerprint is SHA256:8/HJubq6ZXvYjV/9K6uEMpOUISjKPzYzGhkuZUCYhD0.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@node2's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'node2'"
and check to make sure that only the key(s) you wanted were added.
```
## Distributing ssh keys with ansible
You will need the posix.authorized_keys module from the ansible.posix collection
```bash
[root@099c9cdbbd61 ~]# ansible-galaxy collection install ansible.posix
Process install dependency map
Starting collection install process
Installing 'ansible.posix:1.4.0' to '/root/.ansible/collections/ansible_collections/ansible/posix'
ansible nodes -i inventory -m 'ansible.posix.authorized_keys' -a "user=devops state=present key=$(cat /home/devops/.ssh/id_rsa.pub)"

```



# ToDo
- Finish DOC
