-- Run this ONCE in SSMS (or Server Explorer in Visual Studio) against your AidcademyDB
-- Adds the GoogleID column needed for Google Sign-In

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Users') AND name = 'GoogleID'
)
BEGIN
    ALTER TABLE dbo.Users ADD GoogleID nvarchar(128) NULL;
    PRINT 'GoogleID column added successfully.';
END
ELSE
BEGIN
    PRINT 'GoogleID column already exists — no action taken.';
END
