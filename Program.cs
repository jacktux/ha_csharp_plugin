using HADotNet.Core;
using HADotNet.Core.Clients;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

// 1. Read Home Assistant internal Supervisor variables
var haUrl = Environment.GetEnvironmentVariable("SUPERVISOR_URL") ?? "http://supervisor";
var haToken = Environment.GetEnvironmentVariable("SUPERVISOR_TOKEN") ?? "";

// 2. Initialize the Home Assistant client factory at startup
if (!string.IsNullOrEmpty(haToken))
{
    var uri = new Uri(haUrl.EndsWith("/") ? haUrl : haUrl + "/");
    ClientFactory.Initialize(uri, haToken);
}

builder.WebHost.UseUrls("http://0.0.0");

var app = builder.Build();

app.MapGet("/", () => "Hello from your Custom C# Home Assistant Plugin!");

// Sample endpoint: Triggers a device turn-on command via your C# API
app.MapPost("/api/turn-on", async ([FromQuery] string entityId) =>
{
    try
    {
        // 3. Request a fresh ServiceClient instance from the initialized factory
        var serviceClient = ClientFactory.GetClient<ServiceClient>();

        // Extract domain (e.g., "light") and service name ("turn_on")
        var parts = entityId.Split('.');
        var domain = parts[0];

        await serviceClient.CallService(domain, "turn_on", new { entity_id = entityId });
        return Results.Ok(new { message = $"Successfully triggered {entityId}" });
    }
    catch (Exception ex)
    {
        return Results.Problem(ex.Message);
    }
});

app.Run();
