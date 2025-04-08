CREATE TABLE [dbo].[dim_Date] (
    [DateID]             INT            NOT NULL,
    [DateTime]           DATETIME       NULL,
    [DateName]           NVARCHAR (16)  NULL,
    [DayTypeID]          INT            NULL,
    [DayTypeName]        NVARCHAR (256) NULL,
    [WeekdayNumber]      INT            NULL,
    [WeekdayName]        NVARCHAR (256) NULL,
    [WeekID]             INT            NULL,
    [WeekName]           NVARCHAR (16)  NULL,
    [WeekFullName]       NVARCHAR (16)  NULL,
    [WeekNumber]         INT            NULL,
    [MonthID]            INT            NULL,
    [MonthName]          NVARCHAR (256) NULL,
    [MonthFullName]      NVARCHAR (256) NULL,
    [MonthNumber]        INT            NULL,
    [QuarterID]          INT            NULL,
    [QuarterName]        NVARCHAR (16)  NULL,
    [QuarterFullName]    NVARCHAR (16)  NULL,
    [YearID]             INT            NULL,
    [YearName]           NVARCHAR (4)   NULL,
    [MonthFullMonthName] NVARCHAR (16)  NULL,
    [DayID]              INT            NULL
);


GO
CREATE CLUSTERED INDEX [ix_cl_dim_Date_DateID]
    ON [dbo].[dim_Date]([DateID] ASC);

