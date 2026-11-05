FROM ://microsoft.com AS base
WORKDIR /app
EXPOSE 5000

FROM ://microsoft.com AS build
WORKDIR /src
COPY ["HA Plugin.csproj", "."]
RUN dotnet restore "./HA Plugin.csproj"
COPY . .
RUN dotnet build "HA Plugin.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "HA Plugin.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "HA Plugin.dll"]

