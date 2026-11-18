FROM eclipse-temurin:17-jre-jammy

ARG NETLOGO_VERSION=7.0.4
ARG NETLOGO_ARCH=64
ARG NETLOGO_SHA256=75636b8469ea4995ec051cfbc91e525f171be84b8f959b86bc080fbff702dfbc

ENV NETLOGO_HOME=/opt/netlogo
ENV PATH="${NETLOGO_HOME}:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl --fail --location --silent --show-error \
        "https://github.com/NetLogo/NetLogo/releases/download/v${NETLOGO_VERSION}/NetLogo-${NETLOGO_VERSION}-${NETLOGO_ARCH}.tgz" \
        --output /tmp/netlogo.tgz \
    && echo "${NETLOGO_SHA256}  /tmp/netlogo.tgz" | sha256sum --check - \
    && mkdir -p "${NETLOGO_HOME}" \
    && tar -xzf /tmp/netlogo.tgz \
        --strip-components=1 \
        --directory "${NETLOGO_HOME}" \
    && rm /tmp/netlogo.tgz \
    && test -x "${NETLOGO_HOME}/netlogo-headless.sh"

WORKDIR /workspace

COPY . /workspace

CMD ["bash"]