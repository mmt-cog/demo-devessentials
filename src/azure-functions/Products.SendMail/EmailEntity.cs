namespace Products.SendMail;

public record EmailEntity(string Subject, string Body, string From, string To);
