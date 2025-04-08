CREATE TABLE [oth].[SupChangeObjectsLog] (
    [LogId]        INT           IDENTITY (1, 1) NOT NULL,
    [DatabaseName] VARCHAR (256) NOT NULL,
    [EventType]    VARCHAR (64)  NOT NULL,
    [ObjectName]   VARCHAR (256) NOT NULL,
    [ObjectType]   VARCHAR (25)  NOT NULL,
    [SqlCommand]   VARCHAR (MAX) NOT NULL,
    [EventDate]    DATETIME      NOT NULL,
    [LoginName]    VARCHAR (256) NOT NULL
);

