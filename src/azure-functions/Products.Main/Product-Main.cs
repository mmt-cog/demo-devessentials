using System.IO;
using System.Threading.Tasks;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Azure.Messaging.ServiceBus;

namespace Company.Function;

public class Product_Main
{
    private readonly ILogger<Product_Main> _logger;
    private static readonly string _topicName = "product-samples";

    public Product_Main(ILogger<Product_Main> logger)
    {
        _logger = logger;
    }

    [Function(nameof(Product_Main))]
    public async Task Run([BlobTrigger("product-samples/{name}", Connection = "AZURE_STORAGE")] Stream stream, string name)
    {
        using var blobStreamReader = new StreamReader(stream);
        var content = await blobStreamReader.ReadToEndAsync();

        _logger.LogInformation("C# Blob trigger function Processed blob\n Name: {name} \n Data: {content}", name, content);

        bool flowControl = await SendMessageToServiceBus(content);
        if (!flowControl)
        {
            return;
        }
    }

    private async Task<bool> SendMessageToServiceBus(string content)
    {
        var serviceBusConnectionString = Environment.GetEnvironmentVariable("SERVICE_BUS");

        if (string.IsNullOrEmpty(serviceBusConnectionString))
        {
            _logger.LogError("Service Bus connection string is not set.");
            return false;
        }

        var serviceBusClient = new ServiceBusClient(serviceBusConnectionString);
        var sender = serviceBusClient.CreateSender(_topicName);

        var message = new ServiceBusMessage(content);
        await sender.SendMessageAsync(message);
        _logger.LogInformation("Message sent to topic: {name}", _topicName);
        await sender.DisposeAsync();
        await serviceBusClient.DisposeAsync();
        return true;
    }

}