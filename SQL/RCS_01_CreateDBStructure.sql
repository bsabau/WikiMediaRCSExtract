-- create tables in RecentChangesStream database (Azure SQL)
SET NOCOUNT ON

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE [name] = 'MediaWiki')
	EXEC ('CREATE SCHEMA MediaWiki')
ELSE
	PRINT 'MediaWiki schema already created'

IF NOT EXISTS (SELECT 1 FROM sys.tables where [name] = 'Users' AND SCHEMA_NAME([schema_id]) = 'MediaWiki')
	CREATE TABLE MediaWiki.Users
		(
			UserID INT IDENTITY (1, 1) NOT NULL,
			MediaWikiID INT NULL,
			IsBot BIT CONSTRAINT DF_Users_IsBot DEFAULT (0) NOT NULL,
			UserName NVARCHAR (64) NOT NULL
			CONSTRAINT PK_UserID PRIMARY KEY CLUSTERED (UserID)
		)	
ELSE
	PRINT 'Table MediaWiki.Users already exists'
	
IF NOT EXISTS (SELECT 1 FROM sys.tables where [name] = 'EventTypes' AND SCHEMA_NAME([schema_id]) = 'MediaWiki')
	CREATE TABLE MediaWiki.EventTypes
		(
			EventTypeID SMALLINT NOT NULL,			
			EventName VARCHAR (16) NOT NULL
			CONSTRAINT PK_EventTypes_EventTypeID PRIMARY KEY (EventTypeID)
		)
ELSE
	PRINT 'Table MediaWiki.EventTypes already exists'
	
MERGE INTO MediaWiki.EventTypes AS ET
	USING
		(
			SELECT 1, 'edit' UNION 
			SELECT 2, 'external' UNION
			SELECT 3, 'new' UNION
			SELECT 4, 'log' UNION
			SELECT 5, 'categorize' UNION
			SELECT 6, 'unknown'
		) AS ev (EventTypeID, EventName)
		ON (ET.EventTypeID = ev.EventTypeID)
		WHEN NOT MATCHED THEN
			INSERT (EventTypeID, EventName)
			VALUES (ev.EventTypeID, ev.EventName);

IF NOT EXISTS (SELECT 1 FROM sys.tables where [name] = 'Pages' AND SCHEMA_NAME([schema_id]) = 'MediaWiki')
	CREATE TABLE MediaWiki.Pages
		(
			PageID BIGINT IDENTITY (1, 1) NOT NULL,
			PageURI NVARCHAR(2000),
			PageTitle NVARCHAR (256),
			Wiki NVARCHAR(256),
			CONSTRAINT PK_Pages_PageID PRIMARY KEY (PageID)
		)	
ELSE
	PRINT 'Table MediaWiki.Pages already exists'
	
IF NOT EXISTS (SELECT 1 FROM sys.tables where [name] = 'PageEdits' AND SCHEMA_NAME([schema_id]) = 'MediaWiki')
	CREATE TABLE MediaWiki.PageEdits
		(
			PageEditID BIGINT IDENTITY(1,1) NOT NULL,
			UserID INT NOT NULL,
			PageID BIGINT NOT NULL,
			EventTypeID SMALLINT NOT NULL,
			EditTimestamp BIGINT NOT NULL,
			ParseDocument NVARCHAR (4000),			
			CONSTRAINT FK_PageEdits_UserID FOREIGN KEY (UserID) REFERENCES MediaWiki.Users (UserID),
			CONSTRAINT FK_PageEdits_PageID FOREIGN KEY (PageID) REFERENCES MediaWiki.Pages (PageID),
			CONSTRAINT FK_PageEdits_EventTypeID FOREIGN KEY (EventTypeID) REFERENCES MediaWiki.EventTypes (EventTypeID),
			CONSTRAINT PK_PageEdits_UserID_PageID PRIMARY KEY (PageEditID)
		)	
ELSE
	PRINT 'Table MediaWiki.PageEdits already exists'
-- create indexes

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'IX_Users_UserName_Covered')
	CREATE NONCLUSTERED INDEX IX_Users_UserName_Covered ON MediaWiki.Users (UserName) INCLUDE (UserID, IsBot)
ELSE
	PRINT 'Index IX_Users_UserName already created'

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'IX_Pages_PageId_Covered')
	CREATE NONCLUSTERED INDEX IX_Pages_PageId_Covered ON MediaWiki.Pages (PageTitle) INCLUDE (PageID, PageUri, Wiki)
ELSE
	PRINT 'Index IX_Pages_PageId_Covered already created'
	
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'IX_PagesEdits_UserID_Covered')
	CREATE NONCLUSTERED INDEX IX_PagesEdits_UserID_Covered ON MediaWiki.PageEdits (UserID) INCLUDE (Edittimestamp)
ELSE
	PRINT 'Index IX_PagesEdits_UserID_Covered already created'
	

