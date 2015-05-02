# References used:
# https://github.com/phusion/baseimage-docker
# http://seasonofcode.com/posts/custom-domain-e-mails-with-postfix-and-gmail-the-missing-tutorial.html
# http://seasonofcode.com/posts/setting-up-dkim-and-srs-in-postfix.html

# Key config files:
# /etc/postfix/main.cf (644)
# /etc/postfix/virtual (644)
# /etc/postfix/sasl/smtpd.conf
# /etc/sasldb2 (400:postfix)
# /etc/postfix/example.pem (400:postfix)
# /etc/postfix/master.cf
FROM phusion/baseimage:0.9.16
MAINTAINER nakanaa

# Set correct environment variables
ENV REFRESHED_AT 2.5.2015
ENV HOME /root
WORKDIR $HOME

RUN \
  # Install required packages
  apt-get -q -y update && DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
    # Postfix itself
    postfix \
    # Cyrus SASL
    sasl2-bin libsasl2-modules && \
    # DKIM
    # opendkim opendkim-tools && \
    # To build OpenSRSd
    # unzip cmake && \
  # Forward logs to Docker log collector
  ln -sf /dev/stdout /var/log/mail.log && \
  # Clean up APT when done.
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY conf/smtpd.conf /etc/postfix/sasl/

RUN \
    # Fix for: http://www.emailquestions.com/postfix/5539-postfix-smtp-fatal-unknown-service-smtp-tcp.html
    cp /etc/services /var/spool/postfix/etc/services && \
    # Fix for: http://www.linuxquestions.org/questions/linux-server-73/postfix-not-sending-mail-host-mx-records-not-found-673177/
    cp /etc/resolv.conf /var/spool/postfix/etc/resolv.conf
  
# Setup runit
RUN mkdir /etc/service/postfix
ADD runit/postfix /etc/service/postfix/run

RUN curl -L https://raw.githubusercontent.com/nakanaa/conf-fetcher/master/conf-fetcher.sh -o /etc/my_init.d/01_conf-fetcher.sh && chmod +x /etc/my_init.d/01_conf-fetcher.sh

# Expose ports
EXPOSE 25
EXPOSE 587

# Use baseimage-docker's init system
ENTRYPOINT ["/sbin/my_init", "--"]

# Define default command
# CMD ["/usr/sbin/postfix", "start"]
