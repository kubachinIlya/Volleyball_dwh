/*
--D:Процедура по заполнению факта статистики по сетам
--E: EXEC [dbo].[fill_fact_MatchStatsSets] @DateFrom = 20240101 ,@DateTo = 20260101
*/

CREATE   PROCEDURE [dbo].[fill_fact_MatchStatsSets]
     @DateFrom INT
    ,@DateTo INT
AS
BEGIN
    --=====================================================================
    --Инициализация логирования:
    --=====================================================================    
    DECLARE  @Name NVARCHAR(MAX) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
            ,@Description NVARCHAR(512) = 'Заполнение факта статистики по сетам'
            ,@InputParameters NVARCHAR(512) = CONCAT('@DateFrom=', @DateFrom, ', @DateTo=', @DateTo)
    BEGIN TRY
        --=====================================================================
        --Запуск логирования:
        --=====================================================================
        EXEC [oth].[fill_SupLog] @Name = @Name, @StateName = 'start', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
        --=====================================================================
        --Тело процедуры:
        --=====================================================================    
        DECLARE @DateFromD DATE = [dbo].[IntToDate](@DateFrom)
        DECLARE @DateToD DATE = [dbo].[IntToDate](@DateTo)

        IF EXISTS (SELECT [MatchDate] FROM [stg_excel].[MatchStatsSets] WHERE [MatchDate] >= @DateFromD AND [MatchDate] < @DateToD)
        BEGIN
            -- Удаление данных пачками по 10000 записей
            DELETE TOP (10000) F
            FROM [dbo].[fact_MatchStatsSets] AS F
            WHERE F.[MatchDateID] >= @DateFrom AND F.[MatchDateID] < @DateTo
            
            WHILE @@ROWCOUNT > 0
            BEGIN 
                DELETE TOP (10000) F
                FROM [dbo].[fact_MatchStatsSets] AS F
                WHERE F.[MatchDateID] >= @DateFrom AND F.[MatchDateID] < @DateTo
            END

            -- Вставка данных
            INSERT INTO [dbo].[fact_MatchStatsSets]
            (
                [MatchDateID],
                [SeasonID],
                [StageID],
                [HostCityID],
                [HostTeamID],
                [GuestTeamID],
                [TeamID],
                [SetNumber],
                [PointsOnServe],
                [PointsOnAttack],
                [PointsOnBlock],
                [PointsOnOpponentErrors],
                [TotalPoints],
                [ServeErrors],
                [ServePoints],
                [TotalReceptions],
                [ReceptionErrors],
                [PerfectReceptionPercent],
                [ExcellentReceptionPercent],
                [TotalAttacks],
                [AttackErrors],
                [AttackBlocks],
                [AttackPoints],
                [AttackPointPercent],
                [BlockPoints]
            )
            SELECT 
                D.[DateID] AS [MatchDateID],
                COALESCE(SE.[SeasonID], -1) AS [SeasonID],
                COALESCE(ST.[StageID], -1) AS [StageID],
                COALESCE(HC.[CityID], -1) AS [HostCityID],
                COALESCE(HT.[TeamID], -1) AS [HostTeamID],
                COALESCE(GT.[TeamID], -1) AS [GuestTeamID],
                COALESCE(T.[TeamID], -1) AS [TeamID],
                F.[SetNumber],
                ISNULL(F.[PointsOnServe], 0) AS [PointsOnServe],
                ISNULL(F.[PointsOnAttack], 0) AS [PointsOnAttack],
                ISNULL(F.[PointsOnBlock], 0) AS [PointsOnBlock],
                ISNULL(F.[PointsOnOpponentErrors], 0) AS [PointsOnOpponentErrors],
                ISNULL(F.[TotalPoints], 0) AS [TotalPoints],
                ISNULL(F.[ServeErrors], 0) AS [ServeErrors],
                ISNULL(F.[ServePoints], 0) AS [ServePoints],
                ISNULL(F.[TotalReceptions], 0) AS [TotalReceptions],
                ISNULL(F.[ReceptionErrors], 0) AS [ReceptionErrors],
                ISNULL(F.[PerfectReceptionPercent], 0) AS [PerfectReceptionPercent],
                ISNULL(F.[ExcellentReceptionPercent], 0) AS [ExcellentReceptionPercent],
                ISNULL(F.[TotalAttacks], 0) AS [TotalAttacks],
                ISNULL(F.[AttackErrors], 0) AS [AttackErrors],
                ISNULL(F.[AttackBlocks], 0) AS [AttackBlocks],
                ISNULL(F.[AttackPoints], 0) AS [AttackPoints],
                ISNULL(F.[AttackPointPercent], 0) AS [AttackPointPercent],
                ISNULL(F.[BlockPoints], 0) AS [BlockPoints]
            FROM (
                SELECT DISTINCT
                    [FileName],
                    [FolderName],
                    [MatchDate],
                    [TeamName],
                    [SetNumber],
                    [PointsOnServe],
                    [PointsOnAttack],
                    [PointsOnBlock],
                    [PointsOnOpponentErrors],
                    [TotalPoints],
                    [ServeErrors],
                    [ServePoints],
                    [TotalReceptions],
                    [ReceptionErrors],
                    [PerfectReceptionPercent],
                    [ExcellentReceptionPercent],
                    [TotalAttacks],
                    [AttackErrors],
                    [AttackBlocks],
                    [AttackPoints],
                    [AttackPointPercent],
                    [BlockPoints],
                    NULL AS [ParentFolderName]
                FROM [stg_excel].[MatchStatsSets]
                WHERE [MatchDate] >= @DateFromD 
                AND [MatchDate] < @DateToD
            ) F
            INNER JOIN [dbo].[dim_Date] D
                ON F.[MatchDate] = D.[DateTime]
            LEFT JOIN [dbo].[dim_Seasons] SE
                ON D.[DateID] >= SE.[SeasonStartDateID]
                AND D.[DateID] <= SE.[SeasonEndDateID]
            LEFT JOIN [dbo].[dim_Stages] ST
                ON REPLACE(F.[ParentFolderName], '_', ' ') = ST.[StagePartName]
                AND SUBSTRING(F.[FolderName], 1, CHARINDEX('_', F.[FolderName]) - 1) = REPLACE(ST.[StagePartTourName], ' ', '') 
            
            -- Определение команд хозяев и гостей
            CROSS APPLY (
                SELECT 
                    CASE 
                        WHEN CHARINDEX('_против_', F.[FolderName]) > 0 
                        THEN SUBSTRING(F.[FolderName], 
                                    CHARINDEX('_', F.[FolderName], CHARINDEX('_', F.[FolderName]) + 1) + 1,
                                    CHARINDEX('_против_', F.[FolderName]) - CHARINDEX('_', F.[FolderName], CHARINDEX('_', F.[FolderName]) + 1) - 1)
                        ELSE NULL
                    END AS HostTeamName,
                    CASE 
                        WHEN CHARINDEX('_против_', F.[FolderName]) > 0 
                        THEN SUBSTRING(F.[FolderName], 
                                    CHARINDEX('_против_', F.[FolderName]) + 8,
                                    LEN(F.[FolderName]) - CHARINDEX('_против_', F.[FolderName]) - 7)
                        ELSE NULL
                    END AS GuestTeamName,
                    CASE 
                        WHEN CHARINDEX('_', F.[FolderName], CHARINDEX('_', F.[FolderName]) + 1) > 0 
                        THEN SUBSTRING(F.[FolderName], 
                                    CHARINDEX('_', F.[FolderName]) + 1,
                                    CHARINDEX('_', F.[FolderName], CHARINDEX('_', F.[FolderName]) + 1) - CHARINDEX('_', F.[FolderName]) - 1)
                        ELSE NULL
                    END AS HostCityName
            ) AS Parsed
            
            LEFT JOIN [dbo].[dim_Teams] HT
                ON Parsed.HostTeamName = HT.[TeamName]
            LEFT JOIN [dbo].[dim_Teams] GT
                ON Parsed.GuestTeamName = GT.[TeamName]
            LEFT JOIN [dbo].[dim_Cities] HC
                ON Parsed.HostCityName = HC.[CityName]
            LEFT JOIN [dbo].[dim_Teams] T
                ON T.[TeamName] = F.[TeamName]
        END

        --=====================================================================
        --Завершение логирования c успехом:
        --=====================================================================
        EXEC [oth].[fill_SupLog] @Name = @Name, @StateName = 'finish', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
    END TRY
    
    BEGIN CATCH
        --=====================================================================
        --Завершение логирования c ошибкой:
        --=====================================================================
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        SET @InputParameters = CONCAT(@InputParameters, ', Error: ', @ErrorMessage)
        EXEC [oth].[fill_SupLog] @Name = @Name, @StateName = 'error', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
        
        -- Проброс ошибки наверх
        THROW
    END CATCH
END