using Azure.Identity;
using Products.SendMail;
using Products.SendMail.Interfaces;
using Microsoft.Azure.Functions.Worker.Builder;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = FunctionsApplication.CreateBuilder(args);

builder.ConfigureFunctionsWebApplication();

if (!string.IsNullOrEmpty(builder.Configuration["KeyVaultUri"]))
{
    var keyVaultEndpoint = new Uri(builder.Configuration["KeyVaultUri"]!);
    builder.Configuration.AddAzureKeyVault(keyVaultEndpoint, new DefaultAzureCredential());
}

builder.Services.AddScoped<ISendMailHelper, SendMailHelper>();

builder.Build().Run();
