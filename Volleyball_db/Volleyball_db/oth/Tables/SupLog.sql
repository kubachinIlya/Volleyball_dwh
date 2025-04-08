CREATE TABLE [oth].[SupLog] (
    [DateTime]        DATETIME       NULL,
    [Name]            NVARCHAR (255) NULL,
    [SystemUser]      NVARCHAR (255) NULL,
    [StateName]       NVARCHAR (255) NULL,
    [RowCount]        INT            NULL,
    [ErrNumber]       INT            NULL,
    [ErrSeverity]     INT            NULL,
    [ErrState]        INT            NULL,
    [ErrObject]       NVARCHAR (MAX) NULL,
    [ErrLine]         INT            NULL,
    [ErrMessage]      NVARCHAR (MAX) NULL,
    [SpID]            INT            NULL,
    [Duration]        NVARCHAR (64)  NULL,
    [DurationOrd]     INT            NULL,
    [Description]     NVARCHAR (512) NULL,
    [InputParameters] NVARCHAR (512) NULL
);


GO
CREATE CLUSTERED INDEX [ix_cl_SupLog_DateTime]
    ON [oth].[SupLog]([DateTime] DESC);

