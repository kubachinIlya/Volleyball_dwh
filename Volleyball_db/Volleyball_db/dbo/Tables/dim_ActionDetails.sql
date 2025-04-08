CREATE TABLE [dbo].[dim_ActionDetails] (
    [ActionDetailID]              INT             IDENTITY (1, 1) NOT NULL,
    [ActionID]                    INT             NULL,
    [ActionDetailSign]            NVARCHAR (16)   NULL,
    [ActionDetailDescription]     NVARCHAR (1024) NULL,
    [ActionDetailAlternativeSign] NVARCHAR (16)   NULL
);


GO
CREATE CLUSTERED INDEX [ix_cl_ActionDetails_ActionDetailID]
    ON [dbo].[dim_ActionDetails]([ActionDetailID] ASC);

