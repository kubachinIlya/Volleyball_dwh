CREATE PROCEDURE [oth].[fill_SupLog]
    @Name VARCHAR(255) = NULL,		
    @StateName VARCHAR(255) = NULL,	
    @RowCount INT = NULL,
    @TaskID INT = NULL,
    @SpID INT = NULL,
    @Description NVARCHAR(512) = NULL,
    @InputParameters NVARCHAR(512) = NULL
AS
BEGIN

    SET @RowCount = COALESCE(@RowCount, @@ROWCOUNT)

    DECLARE @MaxDateTime DATETIME = (
                                        SELECT
                                            MAX([DateTime]) AS [DateTime]
                                        FROM [oth].[SupLog] WITH(NOLOCK)
                                        WHERE [StateName] = 'start' 
                                            AND [Name] = @Name 
                                            AND [SpID] = @SpID
                                    ) 

    INSERT INTO [oth].[SupLog]
    (
        [DateTime],
        [Name],
        [SystemUser],
        [StateName],
        [RowCount],
        [ErrNumber],
        [ErrSeverity],
        [ErrState],
        [ErrObject],
        [ErrLine],
        [ErrMessage],
        [SpId],
        [Duration],
        [DurationOrd],
        [Description],
        [InputParameters]
    )
    SELECT 
        GETDATE(),
        @Name,
        SYSTEM_USER,
        @StateName,
        CASE 
            WHEN @StateName = 'finish' THEN @RowCount
            WHEN @StateName = 'error' THEN -1 
            ELSE NULL 
        END,
        ERROR_NUMBER(),
        ERROR_SEVERITY(),
        ERROR_STATE(),
        ERROR_PROCEDURE(),
        ERROR_LINE(),
        ERROR_MESSAGE(),
        @SpID,
        CASE 
            WHEN @StateName = 'start' THEN NULL
            ELSE 				 
                CAST(CAST((DATEDIFF(SECOND, @MaxDateTime, GETDATE())) / 3600 AS INT) AS VARCHAR(3)) 
                + ':' + RIGHT('0' + CAST(CAST(((DATEDIFF(SECOND, @MaxDateTime, GETDATE())) % 3600) / 60 AS INT) AS VARCHAR(2)), 2) 
                + ':' + RIGHT('0' + CAST(((DATEDIFF(SECOND, @MaxDateTime, GETDATE())) % 3600) % 60 AS VARCHAR(2)), 2) + ' (hh:mm:ss)'
        END,
        CASE 
            WHEN @StateName = 'start' THEN 0
            ELSE 				 
                DATEDIFF(SECOND, @MaxDateTime, GETDATE())
        END,
        @Description,
        @InputParameters

    WAITFOR DELAY '00:00:00.100'

END