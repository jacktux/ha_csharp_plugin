FROM ://microsoft.com AS base
WORKDIR /app
EXPOSE 5000

FROM ://microsoft.com AS build
WORKDIR /src
COPY ["HaCustomPluginApp.csproj", "."]
RUN dotnet restore "./HaCustomPluginApp.csproj"
COPY . .
RUN dotnet build "HaCustomPluginApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "HaCustomPluginApp.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "HaCustomPluginApp.dll"]
