FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y unzip \
        git \
        libssl1.0.0 \
        libudev-dev libusb-0.1-4 \
        curl libcurl4 libcurl4-gnutls-dev \
        libpython3.7-dev
        
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata 

RUN echo "Europe/Paris" | tee /etc/timezone && \
    rm -f /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

ARG APP_HASH
ARG BUILD_DATE

LABEL org.label-schema.vcs-ref=$APP_HASH \
      org.label-schema.vcs-url="https://github.com/domoticz/domoticz" \
      org.label-schema.url="https://domoticz.com/" \
      org.label-schema.name="Domoticz" \
      org.label-schema.license="GPLv3" \
      org.label-schema.build-date=$BUILD_DATE

RUN curl -s -O https://releases.domoticz.com/releases/release/domoticz_linux_x86_64.tgz && \
	mkdir /domoticz && \
	tar xfz domoticz_linux_x86_64.tgz --directory /domoticz && \
	cp -r /domoticz /opt/domoticz

WORKDIR /opt/domoticz

RUN chmod +x ./domoticz

WORKDIR /opt/domoticz/plugins

RUN git clone https://github.com/pipiche38/Domoticz-Zigate.git && \
	chmod +x Domoticz-Zigate/plugin.py

VOLUME /config
VOLUME /opt/domoticz/plugins

EXPOSE 8080 9440

ENTRYPOINT ["/opt/domoticz/domoticz", "-dbase", "/config/domoticz.db", "-log", "/config/domoticz.log"]
CMD ["-www", "8080"]