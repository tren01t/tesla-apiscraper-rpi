FROM resin/rpi-raspbian
MAINTAINER markusdd

ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.name="tesla-apiscraper-rpi" \
      org.label-schema.url="https://github.com/markusdd/tesla-apiscraper-rpi" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/markusdd/tesla-apiscraper-rpi.git" \
      org.label-schema.vcs-type="Git"

RUN [ "cross-build-start" ]

## BASICS
RUN apt update

RUN apt install \
    apt-transport-https \
    gnupg2 \
    curl \
    wget \
    libfontconfig1

## INFLUXDB and GRAFANA
RUN curl -sL https://repos.influxdata.com/influxdb.key | apt-key add -

RUN echo "deb https://repos.influxdata.com/debian stretch stable" | tee /etc/apt/sources.list.d/influxdb.list

RUN apt update

RUN apt install --yes --force-yes \
    python \
    python3 \
    git \
    influxdb \
    python-pip

RUN wget https://dl.grafana.com/oss/release/grafana_5.4.3_armhf.deb

RUN sudo dpkg -i grafana_5.4.3_armhf.deb

RUN cd /var/lib/grafana/plugins

RUN git clone https://github.com/pR0Ps/grafana-trackmap-panel

RUN cd grafana-trackmap-panel

RUN git checkout releases

RUN grafana-cli plugins install natel-discrete-panel

##TESLA APISCRAPER

RUN cd /opt

RUN git clone https://github.com/lephisto/tesla-apiscraper

RUN pip install influxdb

RUN [ "cross-build-end" ]

ADD entrypoint.sh /root/entrypoint.sh
ADD tesla.yaml /usr/share/grafana/conf/provisioning/dashboards/tesla.yaml

VOLUME ["/var/lib/grafana"]
VOLUME ["/var/lib/influxdb"]
VOLUME ["/opt/tesla-apiscraper/config.py"]

EXPOSE 3000

ENTRYPOINT ["/root/entrypoint.sh"]
