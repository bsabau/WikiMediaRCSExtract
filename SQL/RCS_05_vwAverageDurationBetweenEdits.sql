IF OBJECT_ID('MediaWiki.vwAverageDurationBetweenEdits') IS NOT NULL		
	DROP VIEW MediaWiki.vwAverageDurationBetweenEdits					
GO
CREATE VIEW MediaWiki.vwAverageDurationBetweenEdits	
AS
SELECT
	u.UserName, IsBot, COUNT(1) AS [Number of changes], (MAX(edittimestamp) -  MIN(edittimestamp)) / COUNT(1) AS [AVG duration between changes(s)] 
FROM MediaWiki.Users u WITH (NOLOCK)
	INNER JOIN MediaWiki.PageEdits pe WITH (NOLOCK)
		ON pe.UserID = u.UserID
GROUP BY u.UserName, IsBot
