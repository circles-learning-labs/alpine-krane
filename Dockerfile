FROM alpine:3.18

# The default repo is choking for some reason, but the AU one is fine. 2023-05-18
RUN echo http://mirror.aarnet.edu.au/pub/alpine/v3.18/main > /etc/apk/repositories
RUN echo http://mirror.aarnet.edu.au/pub/alpine/v3.18/community >> /etc/apk/repositories
RUN apk update
RUN apk add --no-cache ruby ruby-bigdecimal ruby-etc ruby-json make aws-cli jq git bash curl
RUN apk add --no-cache -t build g++ ruby-dev
RUN gem install krane
# This can be used as the version once aws cli is fixed for kubectl 1.24:
# $(curl -L -s https://dl.k8s.io/release/stable.txt)
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl"
RUN chmod ugo+x kubectl
RUN mv kubectl /usr/bin
RUN apk del build
RUN mkdir /root/.kube
ENV KUBECONFIG /root/.kube/config

RUN mkdir -p /github/workspace
VOLUME /github/workspace
WORKDIR /github/workspace
ADD entrypoint.sh /usr/bin/entrypoint.sh
ADD build_kube_config.sh /usr/bin/build_kube_config.sh
RUN chmod ugo+x /usr/bin/entrypoint.sh /usr/bin/build_kube_config.sh

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
