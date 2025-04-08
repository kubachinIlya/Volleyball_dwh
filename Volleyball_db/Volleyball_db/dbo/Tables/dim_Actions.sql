CREATE TABLE [dbo].[dim_Actions] (
    [ActionID]          INT            NOT NULL,
    [ActionDescription] NVARCHAR (128) NULL
);


GO
CREATE CLUSTERED INDEX [ix_cl_Actions_ActionID]
    ON [dbo].[dim_Actions]([ActionID] ASC);

