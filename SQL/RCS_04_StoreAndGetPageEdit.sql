IF EXISTS (SELECT 1 FROM sys.procedures WHERE [name] = 'StoreAndGetPageEdit')
	DROP PROCEDURE MediaWiki.StoreAndGetPageEdit
GO
CREATE PROCEDURE MediaWiki.StoreAndGetPageEdit 
(
    @UserID INT,
	@PageID BIGINT,
	@EventTypeID SMALLINT,
	@EditTimestamp BIGINT,
	@ParseDocument NVARCHAR(4000)
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @ERROR_MESSAGE NVARCHAR(256)
	BEGIN TRANSACTION
		BEGIN TRY
			INSERT INTO MediaWiki.PageEdits
				(UserID, PageID, EventTypeID, EditTimestamp, ParseDocument)
			VALUES
				(@UserID, @PageID, @EventTypeID, @EditTimestamp, @ParseDocument)
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
