CREATE TABLE [dbo].[dim_Stages] (
    [StageID]           INT           IDENTITY (1, 1) NOT NULL,
    [StagePartName]     NVARCHAR (32) NULL,
    [StagePartTourName] NVARCHAR (32) NULL,
    CONSTRAINT [PK_dim_Stages] PRIMARY KEY CLUSTERED ([StageID] ASC)
);

