FROM almalinux/8-init

ADD id_rsa.pub /tmp/id_rsa.pub
# install sensible packages and start sshd for ansible
RUN dnf -y install openssh-server sudo less iputils iproute net-tools man-pages man-db man; dnf clean all; mandb; systemctl enable sshd
# make root password redhat
RUN echo 'redhat' | passwd --stdin root
# add ansible user and enable passwordless sudo
RUN  useradd ansible && echo 'ansible ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/ansible && \
    mkdir -pv /home/ansible/.ssh && \
    cat /tmp/id_rsa.pub >> /home/ansible/.ssh/authorized_keys

# make root password redhat
RUN echo 'redhat' | passwd --stdin root

CMD [ "/sbin/init" ]