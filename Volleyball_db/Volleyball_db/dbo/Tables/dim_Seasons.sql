CREATE TABLE [dbo].[dim_Seasons] (
    [SeasonID]          INT           IDENTITY (1, 1) NOT NULL,
    [SeasonName]        NVARCHAR (64) NULL,
    [SeasonStartDateID] INT           NULL,
    [SeasonEndDateID]   INT           NULL,
    CONSTRAINT [PK_dim_Seasons] PRIMARY KEY CLUSTERED ([SeasonID] ASC)
);

