FROM almalinux/8-init

# install sensible packages and start sshd for ansible
RUN dnf -y install openssh-server openssh-clients tmux less iputils iproute net-tools NetworkManager man-pages man-db man; dnf clean all; mandb; systemctl enable sshd
# make root password redhat
RUN echo 'redhat' | passwd --stdin root

CMD [ "/sbin/init" ]