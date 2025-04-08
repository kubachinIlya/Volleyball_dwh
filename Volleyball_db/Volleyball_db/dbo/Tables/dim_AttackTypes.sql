CREATE TABLE [dbo].[dim_AttackTypes] (
    [AttackTypeID]          INT             IDENTITY (1, 1) NOT NULL,
    [CombinationID]         INT             NULL,
    [AttackTypeSign]        NVARCHAR (2)    NULL,
    [AttackTypeDescription] NVARCHAR (1024) NULL
);


GO
CREATE CLUSTERED INDEX [ix_cl_AttackTypes_AttackTypeID]
    ON [dbo].[dim_AttackTypes]([AttackTypeID] ASC);

