CREATE TABLE [dbo].[dim_Players] (
    [PlayerID]             INT            IDENTITY (1, 1) NOT NULL,
    [PlayerName]           NVARCHAR (256) NULL,
    [PlayerNumber]         INT            NULL,
    [PlayerHeight]         INT            NULL,
    [PlayerBirthdayDateID] INT            NULL,
    [PlayerCitizenship]    NVARCHAR (128) NULL
);

