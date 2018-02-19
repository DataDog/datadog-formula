FROM saltstack/ubuntu-14.04-minimal
LABEL maintainer="package@datadoghq.com"

# preparation
RUN apt-get update &&\
    apt-get install -y curl

# install salt
RUN curl -L https://bootstrap.saltstack.com | sh -s -- -d -X stable

# Add and set start script
ADD start.sh /start.sh
CMD ["bash", "start.sh"]
