FROM almalinux:8

# install sensible packages and ansible
RUN dnf -y install passwd centos-release-ansible-29 openssh-clients sudo tmux less iputils iproute \
    net-tools NetworkManager man-pages man-db man \@python39 && \
    dnf clean all && mandb && dnf -y install ansible 

# make root password redhat
RUN echo 'redhat' | passwd --stdin root && \
    echo 'ansible ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/ansible 

# setup ansible user and ansible.cfg to disable host key checking
RUN useradd ansible 
USER ansible
WORKDIR /home/ansible
RUN mkdir -pv .ssh && \
    echo '[defaults]' > ansible.cfg && \
    echo 'host_key_checking = false' >> ansible.cfg

ADD  --chown=ansible:ansible id_rsa .ssh/
RUN chmod 0600 .ssh/id_rsa
# install useful ansible collections and setup .vimrc for yaml
RUN ansible-galaxy collection install ansible.posix && \
    echo 'set number et ai ts=2 sw=2' > .vimrc

# create inventory 
RUN echo '[nodes]' > inventory && echo node1 >> inventory && \
    echo node2 >> inventory

# distribute id_rsa.pub to nodes
CMD [ "/sbin/init" ]