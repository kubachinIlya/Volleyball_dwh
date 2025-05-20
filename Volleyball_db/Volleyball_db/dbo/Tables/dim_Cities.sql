CREATE TABLE [dbo].[dim_Cities] (
    [CityID]   INT           IDENTITY (1, 1) NOT NULL,
    [CityName] NVARCHAR (64) NULL,
    CONSTRAINT [PK_dim_Cities] PRIMARY KEY CLUSTERED ([CityID] ASC)
);

