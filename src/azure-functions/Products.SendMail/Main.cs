using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Products.SendMail.Interfaces;
using System.Net.Sockets;
using Microsoft.Azure.Functions.Worker.Extensions.Sql;
namespace Products.SendMail;

public class Main(ILogger<Main> logger, IConfiguration config, ISendMailHelper sendMailHelper)
{
    private async Task ProcessMessageAsync(ServiceBusReceivedMessage message)
    {
        logger.LogInformation($"Processed message {message.Body}");

        var email = new EmailEntity("New Sample product received", message.Body.ToString(), "john@doe.com", "bogus@test.com");
        await SendEmail(email);
        await Task.CompletedTask;
    }

    [Function("send-mail")]
    [SqlOutput("[dbo].[Products]", "sql_connection")]
    public async Task<Product> Run(
        [ServiceBusTrigger("%EmailTopic%","subscription.1", Connection = "SERVICE_BUS")]
        ServiceBusReceivedMessage message,
        ServiceBusMessageActions messageActions)
    {
        await ProcessMessageAsync(message);
        await messageActions.CompleteMessageAsync(message);

        logger.LogInformation("Completing with database entity...");
        Product newProduct = new()
        {
            Message = message.Body.ToString(),
            Product_code = "Demo"
        };

        return newProduct;
    }


    private async Task SendEmail(EmailEntity email)
    {
        try
        {
            logger.LogInformation("Sending email...");

            if (string.IsNullOrEmpty(config["EmailHost"]) || !int.TryParse(config["EmailHostPort"], out int emailHostPort))
            {
                logger.LogWarning("Host and port are not set correctly");
                return;
            }

            logger.LogInformation(await sendMailHelper.ConnectToSmtpServer(emailHostPort));

            await sendMailHelper.SendMailWithSmtpClient(email, emailHostPort);

            logger.LogInformation("Email sent successfully");
        }
        catch (SocketException ex)
        {
            logger.LogError($"Failed socket to connect: {ex.Message}");
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error sending email: {Message}", ex.Message);
        }
    }
}

