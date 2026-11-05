FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5000

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["HA Plugin.csproj", "."]
RUN dotnet restore "./HA_Plugin.csproj"
COPY . .
RUN dotnet build "HA_Plugin.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "HA_Plugin.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "HA_Plugin.dll"]
