CREATE TABLE [dbo].[dim_ActionCodes] (
    [ActionCodeID]          INT             IDENTITY (1, 1) NOT NULL,
    [ActionID]              INT             NULL,
    [ActionCodeSign]        NVARCHAR (2)    NULL,
    [ActionCodeDescription] NVARCHAR (1024) NULL
);


GO
CREATE CLUSTERED INDEX [ix_cl_ActionCodes_ActionCodeID]
    ON [dbo].[dim_ActionCodes]([ActionCodeID] ASC);

