CREATE TABLE [dbo].[dim_Combinations] (
    [CombinationID]          INT             NOT NULL,
    [CombinationDescription] NVARCHAR (1024) NULL
);


GO
CREATE CLUSTERED INDEX [ix_cl_Combinations_CombinationID]
    ON [dbo].[dim_Combinations]([CombinationID] ASC);

