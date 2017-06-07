FROM centos:latest


USER root
#ARG DISTRO_LOC=https://archive.apache.org/dist/spark/spark-2.1.0/spark-2.1.0-bin-hadoop2.7.tgz
ARG DISTRO_LOC=https://doc-0s-1g-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/5797s4qviib01ripcm1kagfrsh0ajh7q/1496822400000/16544746259682377476/*/0B3Ktk66X20qlTzFESzMtTXplVVk?e=download
#ARG DISTRO_NAME=spark-2.1.0-bin-hadoop2.7
ARG DISTRO_NAME=spark-2.1.1-bin-keedio-spark-openshift

RUN yum install -y epel-release tar java && \
    yum clean all

RUN cd /opt && \
    curl -o spark-2.1.1-bin-keedio-spark-openshift.tgz $DISTRO_LOC | \
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
