IF EXISTS (SELECT 1 FROM sys.procedures WHERE [name] = 'StoreAndGetPage')
	DROP PROCEDURE MediaWiki.StoreAndGetPage
GO
CREATE PROCEDURE MediaWiki.StoreAndGetPage 
(
    @PageURI NVARCHAR(2000),
	@PageTitle NVARCHAR(2000),
	@Wiki NVARCHAR(256)
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @ERROR_MESSAGE NVARCHAR(256)
	DECLARE @PageID INT

	SET @PageID = (SELECT PageID FROM MediaWiki.Pages WHERE PageTitle = @PageTitle)

	IF @PageID IS NOT NULL
		RETURN @PageID
	ELSE 
	BEGIN
		BEGIN TRANSACTION
			BEGIN TRY
				INSERT INTO MediaWiki.Pages
					(PageURI, PageTitle, Wiki)				
				VALUES
					(@PageURI, @PageTitle, @Wiki)
				SET @PageID = SCOPE_IDENTITY()
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					BEGIN
						ROLLBACK TRANSACTION
						SET @ERROR_MESSAGE = ERROR_MESSAGE()
						RAISERROR (@ERROR_MESSAGE, 16, 1)
					END
			END CATCH
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION		 
	END
	RETURN @PageID
END