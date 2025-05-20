CREATE TABLE [dbo].[dim_Teams] (
    [TeamID]           INT            IDENTITY (1, 1) NOT NULL,
    [TeamName]         NVARCHAR (128) NULL,
    [CityID]           INT            NULL,
    [SecondCityID]     INT            NULL,
    [TeamOfficialName] NVARCHAR (256) NULL,
    [TeamFullName]     NVARCHAR (128) NULL,
    [Address]          NVARCHAR (256) NULL,
    [Phone]            NVARCHAR (32)  NULL,
    [Email]            NVARCHAR (128) NULL,
    [Website]          NVARCHAR (128) NULL,
    PRIMARY KEY CLUSTERED ([TeamID] ASC),
    CONSTRAINT [FK_dim_Teams_dim_Cities] FOREIGN KEY ([CityID]) REFERENCES [dbo].[dim_Cities] ([CityID])
);

