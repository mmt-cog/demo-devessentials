namespace Products.SendMail.Interfaces;

public interface ISendMailHelper
{
    Task SendMailWithSmtpClient(EmailEntity email, int emailHostPort);
    Task<string> ConnectToSmtpServer(int emailHostPort);
}
