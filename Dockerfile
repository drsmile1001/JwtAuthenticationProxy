FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine AS build
WORKDIR /src
COPY *.csproj .
RUN dotnet restore

COPY . .
RUN dotnet build

FROM build AS publish
RUN dotnet publish -c Release -o /app/publish

FROM base AS final
RUN apk update
RUN apk add --no-cache icu-libs krb5-libs libgcc libintl libssl1.1 libstdc++ zlib
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT 0

WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "JwtAuthenticationProxy.dll"]
