CREATE TABLE [dbo].[Versions](
    [id] [bigint] IDENTITY(1000,1) NOT NULL,
    [description] [varchar](2000) NULL,
    [version_code] [varchar](50) NOT NULL UNIQUE,
    CONSTRAINT [PK_Versions] PRIMARY KEY ([id])
);

