IF EXISTS (SELECT 1 FROM sys.procedures WHERE [name] = 'StoreAndGetUsername')
	DROP PROCEDURE MediaWiki.StoreAndGetUsername
GO
CREATE PROCEDURE MediaWiki.StoreAndGetUsername 
(
    @MediWikiID INT,
	@IsBot BIT,
	@UserName NVARCHAR(64)
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @ERROR_MESSAGE NVARCHAR(256)
	DECLARE @UserID INT

	SET @UserID = (SELECT UserID FROM MediaWiki.Users WHERE UserName = @UserName)

	IF @UserID IS NOT NULL
		RETURN @UserID
	ELSE 
	BEGIN
		BEGIN TRANSACTION
			BEGIN TRY
				INSERT INTO MediaWiki.Users
					(MediaWikiID, IsBot, UserName)				
				VALUES
					(@MediWikiID, @IsBot, @UserName)
				SET @UserID = SCOPE_IDENTITY()
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
	RETURN @UserID
END
