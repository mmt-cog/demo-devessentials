CREATE PROCEDURE [dbo].[DemoWithCommon]
    @product_code varchar(50),
    @version_code varchar(50)
AS  
BEGIN
    SET NOCOUNT ON;

    DECLARE @product_id bigint;
    DECLARE @version_id bigint;

    -- Insert into Products table
    INSERT INTO [dbo].[Products] (message, product_code)
    VALUES ('Demo message', @product_code);

    -- Get the inserted product ID
    SET @product_id = SCOPE_IDENTITY();

    -- Insert into Versions table
    INSERT INTO [$(Common)].[dbo].[Versions] (description, version_code)
    VALUES ('Demo version', @version_code);

    -- Get the inserted version ID
    SET @version_id = SCOPE_IDENTITY();

    -- Return the IDs
    SELECT @product_id AS ProductID, @version_id AS VersionID;
END;