FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG TARGETARCH
ENV VERSION=1.2.8
RUN apt-get update && apt-get install -y wget unzip
WORKDIR /build
RUN wget https://github.com/iPromKnight/zilean/archive/refs/tags/v${VERSION}.zip -O zilean.zip \
    && unzip zilean.zip -d . \
    && mv zilean-${VERSION}/* . \
    && mv zilean-${VERSION}/.[!.]* . || true \
    && rmdir zilean-${VERSION}
WORKDIR /build/src/Zilean.ApiService
RUN dotnet restore -a $TARGETARCH
RUN dotnet publish -c Release --no-restore -o /build/out -a $TARGETARCH /p:AssemblyName=zilean

FROM mcr.microsoft.com/dotnet/aspnet:8.0

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_gcServer=1
ENV DOTNET_GCDynamicAdaptationMode=1
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8181
VOLUME /app/data
COPY --from=build /build/out .
ENTRYPOINT ["./zilean"]
