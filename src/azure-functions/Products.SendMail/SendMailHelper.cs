using Microsoft.Extensions.Configuration;
using Products.SendMail.Interfaces;
using System.Net;
using System.Net.Mail;
using System.Net.Sockets;

namespace Products.SendMail;

internal class SendMailHelper(IConfiguration config) : ISendMailHelper
{
    public async Task SendMailWithSmtpClient(EmailEntity email, int emailHostPort)
    {
        using var smtp = new SmtpClient(config["EmailHost"], emailHostPort);

        if (!string.IsNullOrEmpty(config["SendGridUsername"])
            && !string.IsNullOrEmpty(config["SendGridPassword"]))
        {
            smtp.Credentials = new NetworkCredential(config["SendGridUsername"],
                config["SendGridPassword"]);

            smtp.EnableSsl = true;
        }

        await smtp.SendMailAsync(new MailMessage(email.From, email.To, email.Subject, email.Body));
    }


    public async Task<string> ConnectToSmtpServer(int emailHostPort)
    {
        using TcpClient client = new();
        string host = config["EmailHost"]!;

        await client.ConnectAsync(host, emailHostPort);
        return $"Successfully connected to {host}:{emailHostPort}";
    }
}
