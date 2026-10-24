# SPDX-FileCopyrightText: 2026 Wladmis
# SPDX-License-Identifier: MIT

FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        software-properties-common \
    && add-apt-repository -y ppa:lemonade-team/stable \
    && apt-get update \
    && curl -fsSL --retry 3 \
        https://api.github.com/repos/ROCm/FastFlowLM/releases/latest \
        -o /tmp/fastflowlm-release.json \
    && asset_url="$(jq -er '[.assets[] | select(.name | endswith("_ubuntu24.04_amd64.deb"))] | if length == 1 then .[0].browser_download_url else error("expected one Ubuntu 24.04 amd64 package") end' /tmp/fastflowlm-release.json)" \
    && asset_sha="$(jq -er '[.assets[] | select(.name | endswith("_ubuntu24.04_amd64.deb"))] | if length == 1 then .[0].digest | sub("^sha256:"; "") else error("expected one Ubuntu 24.04 amd64 package") end' /tmp/fastflowlm-release.json)" \
    && curl -fsSL --retry 3 "$asset_url" -o /tmp/fastflowlm.deb \
    && printf '%s  %s\n' "$asset_sha" /tmp/fastflowlm.deb | sha256sum -c - \
    && apt-get install -y --no-install-recommends \
        libxrt-npu2 \
        /tmp/fastflowlm.deb \
    && apt-get purge -y curl jq software-properties-common \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/fastflowlm-release.json /tmp/fastflowlm.deb

WORKDIR /root
