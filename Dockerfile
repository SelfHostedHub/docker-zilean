FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG TARGETARCH
ENV VERSION=1.1.1
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

ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_TieredPGO=1
ENV DOTNET_ReadyToRun=0
ENV DOTNET_gcServer=1
ENV DOTNET_gcAllowVeryLargeObjects=1
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true

WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8181
VOLUME /app/data
COPY --from=build /build/out .
ENTRYPOINT ["./zilean"]
