#!/bin/bash


# get release version
RELEASE=$(cat /etc/redhat-release)
YUM_ARGS="--setopt=tsflags=nodocs"



# ensure latest versions
yum update $YUM_ARGS -y

# shared packages
# - build tools for building gems	+# add files
# - iproute needed for ip command to get ip addresses	+ADD run.sh fluentd.conf.template passwd.template fluentd-check.sh ${HOME}/
# - nss_wrapper used to support username identity	+ADD common-*.sh /tmp/
# - bc for calculations in run.conf
PACKAGES="cockpit cockpit-kubernetes cockpit-dashboard"

# enable repositories
subscription-manager repos --disable=*
subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-ose-3.9-rpms

# install all required packages
yum install -y $PACKAGES

# clean up yum to make sure image isn't larger because of installations/updates
yum clean all

rm -rf /var/cache/yum/*
rm -rf /var/lib/yum/*

iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 9090 -j ACCEPT
systemctl enable cockpit.service --now

# set home directory
mkdir -p ${HOME} && \

# install gems for target version of fluentd, eventually
# update to fluentd version that matches version deployed
# into openshift
gem install -N --conservative --minimal-deps --no-document \
  fluentd:${FLUENTD_VERSION} \
  'activesupport:<5' \
  'public_suffix:<3.0.0' \
  'fluent-plugin-record-modifier:<1.0.0' \
  'fluent-plugin-rewrite-tag-filter:<2.0.0' \
  fluent-plugin-kubernetes_metadata_filter \
  fluent-plugin-rewrite-tag-filter \
  fluent-plugin-secure-forward \
  'fluent-plugin-remote_syslog:<1.0.0' \
  fluent-plugin-splunk-ex

# set up directores so that group 0 can have access like specified in
# https://docs.openshift.com/container-platform/3.7/creating_images/guidelines.html
# https://docs.openshift.com/container-platform/3.7/creating_images/guidelines.html#openshift-specific-guidelines
chgrp -R 0 ${HOME}
chmod -R g+rwX ${HOME}
chgrp -R 0 /etc/pki
chmod -R g+rwX /etc/pki
mkdir /secrets
chgrp -R 0 /secrets
chmod -R g+rwX /secrets
chgrp -R 0 /var/log
chmod -R g+rwX /var/log
