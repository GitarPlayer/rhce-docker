![e2e workflow](https://github.com/GitarPlayer/rhce-docker/actions/workflows/push.yml/badge.svg)
# rhce-docker
This repo contains a lightweight docker-compose file in order to practice Ansible. It contains:
- on ansible-controller with ansible 2.9 installed and a working inventory file.
- two ansible-nodes configured to be automated with ansible (id_rsa.pub in authorized_keys, passwordless sudo for ansible user) 

## Why not vagrant
Too many dependencies (virtualization layer and vagrant) and requires too much resources (three VMs each with their own OS)

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
```bash
ssh-keygen -f $PWD/id_rsa
# The <src> path must be inside the context of the build; you cannot ADD ../something /something, because the first step of a docker build is to send the context directory (and subdirectories) to the docker daemon. from https://docs.docker.com/engine/reference/builder/
# this is why we have to move them 
mv id_rsa ansible-controller/
mv id_rsa.pub ansible-nodes/
docker-compose up -d
docker exec -it ansible bash
```

# How to install ansible (quick summary)
## Install ansible via package manager (for all users)
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

## install ansible via pip (possibly for just one user)
```
# only install it for the ansible user and not globally
useradd ansible
yum install @python39 -y
python3.9 -m pip name=ansible --user ansible
```

# Install missing collections
This will lack some collections that are present when you install ansible from the RedHat repo. But you always install them yourself like so
```bash
ansible-galaxy collection install ansible.posix -vv
ansible-galaxy collection list 
```

# Good sources to learn ansible
1. Sander van https://www.sandervanvugt.com/course/red-hat-certified-engineer-rhce-ex294-video-course-red-hat-ansible-automation/  
Best course hands down. A really nice bloke explaining topics in an easy to understand way and his labs are harder than most I found. So you are really prepared for RHCE. You can try Oreilly's for ten days enough time to go trough the course or be convinced enough to buy it. His videos tend to be better than his books.
2. Official RHCE EX294 course from RedHat https://www.redhat.com/en/services/training/rh294-red-hat-linux-automation-with-ansible   
If your company is paying, go ahead. Otherwise I would not shell out the money and rather use the course above.
3. KodeKloud Ansible Certification Course https://kodekloud.com/courses/ansible-certification-preparation-course/  
Definitely good practice but not aligned at all with the RHCE objectives. I mainly tried it because I loved their CKA course.
