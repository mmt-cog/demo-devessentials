CREATE TABLE [dbo].[Products](
    [Id] [int] IDENTITY(1000,1) NOT NULL,
    [Message] [nvarchar](MAX) NULL,
    [Product_code] [nvarchar](50) NULL,
    CONSTRAINT [PK_Products] PRIMARY KEY ([id])
);

