FROM registry.access.redhat.com/rhel7

ENV HOME=/opt/app-root/src \
  PATH=/opt/rh/rh-ruby22/root/usr/bin:/opt/app-root/src/bin:/opt/app-root/bin${PATH:+:${PATH}} \

# add files
ADD common-*.sh /tmp/
#ADD redhat.repo /etc/yum.repos.d/
# set permissions on files
RUN chmod +x /tmp/common-*.sh
# execute files and remove when done
RUN /tmp/common-install.sh && \
    rm -f /tmp/common-*.sh
# set working dir
WORKDIR ${HOME}
# external port
EXPOSE 9090
