FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0-alpine3.19 AS build
ARG TARGETARCH
ENV VERSION=2.0.0
RUN apt-get update && apt-get install -y wget unzip
WORKDIR /build
RUN wget https://github.com/iPromKnight/zilean/archive/refs/tags/v${VERSION}.zip -O zilean.zip \
    && unzip zilean.zip -d . \
    && mv zilean-${VERSION}/* . \
    && mv zilean-${VERSION}/.[!.]* . || true \
    && rmdir zilean-${VERSION}
WORKDIR /build/src/Zilean.ApiService
RUN dotnet restore -a $TARGETARCH
RUN dotnet publish -c Release --no-restore -o /build/out -a $TARGETARCH
WORKDIR /build/src/Zilean.DmmScraper
RUN dotnet restore -a $TARGETARCH
RUN dotnet publish -c Release --no-restore -o /build/out -a $TARGETARCH

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine3.19

RUN apk add --update --no-cache  \
    python3=~3.11.9-r0 \
    py3-pip \
    curl \
    && ln -sf python3 /usr/bin/python

ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_gcServer=1
ENV DOTNET_GCDynamicAdaptationMode=1
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true
ENV PYTHONUNBUFFERED=1
ENV ZILEAN_PYTHON_PYLIB=/usr/lib/libpython3.11.so.1.0
ENV ASPNETCORE_URLS=http://+:8181

WORKDIR /app
VOLUME /app/data
COPY --from=build /build/out .
COPY --from=build /build/requirements.txt .
RUN rm -rf /app/python || true && \
    mkdir -p /app/python || true
RUN pip3 install -r /app/requirements.txt -t /app/python
ENTRYPOINT ["./zilean-api"]
