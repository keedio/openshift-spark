FROM centos:latest


USER root
ARG DISTRO_NAME=spark-2.1.1-bin-keedio-spark-openshift

RUN yum install -y epel-release tar java && \
    yum clean all

RUN cd /opt && \
    curl -o spark-2.1.1-bin-keedio-spark-openshift.tgz 'https://dl.dropboxusercontent.com/content_link/UC9Z8AXMjynLdFamLJJ6iK7hQZoBku40hQddX7uCsrLxUkjtHrIfgqE8YyoLv7H0/file?dl=1' -H 'accept-encoding: gzip, deflate, sdch, br' -H 'accept-language: es-ES,es;q=0.8' -H 'upgrade-insecure-requests: 1' -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36' -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'authority: dl.dropboxusercontent.com' -H 'cookie: uc_session=Cw8ABqgPpVREQcWRpJ1WCjHRyP2OVZfFPFb7FDVItLsw1VBFTHU7qxQafwVZ93cT' --compressed &&\
        tar -xvzf spark-2.1.1-bin-keedio-spark-openshift.tgz && \
    ln -s $DISTRO_NAME spark

# when the containers are not run w/ uid 0, the uid may not map in
# /etc/passwd and it may not be possible to modify things like
# /etc/hosts. nss_wrapper provides an LD_PRELOAD way to modify passwd
# and hosts.
RUN yum install -y nss_wrapper numpy && yum clean all

ENV PATH=$PATH:/opt/spark/bin
ENV SPARK_HOME=/opt/spark

# Add scripts used to configure the image
COPY scripts /tmp/scripts


# Custom scripts
RUN [ "bash", "-x", "/tmp/scripts/spark/install" ]

# Cleanup the scripts directory
RUN rm -rf /tmp/scripts

# Switch to the user 185 for OpenShift usage
#USER 185

# Make the default PWD somewhere that the user can write. This is
# useful when connecting with 'oc run' and starting a 'spark-shell',
# which will likely try to create files and directories in PWD and
# error out if it cannot.
WORKDIR /tmp

ENTRYPOINT ["/entrypoint"]

# Start the main process
CMD ["/opt/spark/bin/launch.sh"]
