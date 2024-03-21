FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt -y update && \
    apt -y install \
    python3-pip \
    python3-dev \
    libapache2-mod-wsgi-py3 \
    git \
    apache2 \
    memcached \
    libffi-dev \
    python3-cffi \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Clone Horizon
ENV APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOGLEVEL=warn \
    VERSION=train \
    HORIZON_BASEDIR=/etc/horizon \
    TZ=Etc/UTC

RUN git clone --branch stable/${VERSION} --depth 1 https://opendev.org/openstack/horizon ${HORIZON_BASEDIR}

WORKDIR ${HORIZON_BASEDIR}

# Install python packages
COPY upper-constraints.txt ${HORIZON_BASEDIR}

RUN \
    pip install --upgrade pip && \
    # can use below line for after openstack train instead of upper-constraints.txt file
    # pip install -c https://opendev.org/openstack/requirements/raw/branch/stable/${VERSION}/upper-constraints.txt . && \
    pip install -c upper-constraints.txt . && \
    pip install python-memcached

RUN ln -fs /usr/bin/python3 /usr/bin/python

# Copy horizon files
COPY themes ${HORIZON_BASEDIR}/openstack_dashboard/themes
COPY startup.sh ${HORIZON_BASEDIR}/startup.sh

# Clean up
RUN apt remove -y python3-dev git && \
    apt autoremove -y

# Start service
RUN a2enmod ssl

EXPOSE 443

ENTRYPOINT [ "./startup.sh" ]
