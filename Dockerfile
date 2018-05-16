FROM registry.access.redhat.com/rhel7

ENV HOME=/opt/app-root/src \
  PATH=/opt/rh/rh-ruby22/root/usr/bin:/opt/app-root/src/bin:/opt/app-root/bin${PATH:+:${PATH}} \

LABEL io.k8s.description="COCKPIT OPENSHIFT" \
  io.k8s.display-name="Cockpit Openshift" \
  io.openshift.expose-services="9090:tcp \
  io.openshift.tags="cockpit" \
  name="cockpit" \
  architecture=x86_64
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
