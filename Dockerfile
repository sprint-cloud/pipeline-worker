FROM alpine:3.18

ARG tekton_version=0.30.0
ARG knative_version=1.9.2
ARG argocd_version=2.6.7
ARG coder_version=0.24.0

WORKDIR /tmp/build
RUN apk update && apk add curl coreutils

RUN adduser -D worker

# Install Kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum -c && chmod +x kubectl && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# Install Tekton client
RUN curl -LO https://github.com/tektoncd/cli/releases/download/v${tekton_version}/tkn_${tekton_version}_Linux_x86_64.tar.gz\
    && curl -L https://github.com/tektoncd/cli/releases/download/v${tekton_version}/checksums.txt -o tkn.sha256
RUN sha256sum --ignore-missing -c tkn.sha256 && tar xvzf tkn_${tekton_version}_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn
# Install Argocd client
RUN curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v${argocd_version}/argocd-linux-amd64\
    && curl -LO https://github.com/argoproj/argo-cd/releases/download/v${argocd_version}/argocd-${argocd_version}-checksums.txt
RUN sha256sum --ignore-missing -c argocd-${argocd_version}-checksums.txt && install -o root -g root -m 0755 argocd-linux-amd64 /usr/local/bin/argocd

# Install coder
RUN curl -LO https://github.com/coder/coder/releases/download/v${coder_version}/coder_${coder_version}_linux_amd64.tar.gz\
    && curl -LO https://github.com/coder/coder/releases/download/v0.24.0/coder_${coder_version}_checksums.txt
RUN sha256sum --ignore-missing -c coder_${coder_version}_checksums.txt && tar xzf coder_${coder_version}_linux_amd64.tar.gz\
    && install -o root -g root -m 0755 coder /usr/local/bin/

# Install vcluster client
RUN curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64"\
    && install -c -m 0755 vcluster /usr/local/bin && rm -f vcluster

RUN rm -rf /tmp/build

USER worker
WORKDIR /home/worker
