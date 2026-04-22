FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl unzip && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L --fail -o /tmp/plink2.zip https://s3.amazonaws.com/plink2-assets/plink2_linux_x86_64_latest.zip && \
    unzip -o /tmp/plink2.zip -d /opt/plink2 && \
    chmod +x /opt/plink2/plink2 && \
    ln -s /opt/plink2/plink2 /usr/local/bin/plink2 && \
    rm -f /tmp/plink2.zip

WORKDIR /work

ENTRYPOINT ["plink2"]
