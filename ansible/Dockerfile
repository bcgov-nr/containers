FROM python:3.8.12
LABEL maintainer="OneTeam" 

# Install envconsul
RUN curl -sSL https://releases.hashicorp.com/envconsul/0.11.0/envconsul_0.11.0_linux_amd64.tgz -o /tmp/envconsul_0.11.0_linux_amd64.tgz \
    && tar -zxvf /tmp/envconsul_0.11.0_linux_amd64.tgz -C /usr/local/bin \
    && rm /tmp/envconsul_0.11.0_linux_amd64.tgz

# Non-root user
RUN useradd -ms /bin/bash runner
USER runner
WORKDIR /home/runner

# Update pip and install ansible
ENV PATH $PATH:/home/runner/.local/bin
RUN python -m pip install --upgrade pip && \
  python -m pip install ansible
