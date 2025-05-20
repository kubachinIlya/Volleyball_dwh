/*
--D:Процедура по заполнению факта информации об играх игроков
--E: EXEC [dbo].[fill_fact_MatchStatsPlayers] @DateFrom = 20240101 ,@DateTo = 20260101
*/

CREATE PROCEDURE [dbo].[fill_fact_MatchStatsPlayers]
     @DateFrom INT
    ,@DateTo INT
AS
BEGIN
    --=====================================================================
    --Инициализация логирования:
    --=====================================================================    
    DECLARE  @Name NVARCHAR(MAX) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
            ,@Description NVARCHAR(512) = 'Заполнение факта информации об играх игроков'
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

        IF EXISTS (SELECT [MatchDate] FROM [stg_excel].[MatchStatsPlayersGeneral] WHERE [MatchDate] >= @DateFromD AND [MatchDate] < @DateToD)
        BEGIN
            -- Удаление данных пачками по 10000 записей
            DELETE TOP (10000) F
            FROM [dbo].[fact_MatchStatsPlayers] AS F
            WHERE F.[MatchDateID] >= @DateFrom AND F.[MatchDateID] < @DateTo
            
            WHILE @@ROWCOUNT > 0
            BEGIN 
                DELETE TOP (10000) F
                FROM [dbo].[fact_MatchStatsPlayers] AS F
                WHERE F.[MatchDateID] >= @DateFrom AND F.[MatchDateID] < @DateTo
            END

            -- Вставка данных с корректным маппингом полей
            INSERT INTO [dbo].[fact_MatchStatsPlayers]
                (
                     [MatchDateID]
					,[FolderName]
                    ,[SeasonID]
                    ,[StageID]
                    ,[HostCityID]
                    ,[HostTeamID]
                    ,[GuestTeamID]
                    ,[OpponentTeamName]
                    ,[TeamID]
                    ,[PlayerTeamName]
                    ,[PlayerID]
                    ,[PlayerName]
                    ,[PlayerNumber]
                    ,[Set1]
                    ,[Set2]
                    ,[Set3]
                    ,[Set4]
                    ,[Set5]
                    ,[TotalPoints]
                    ,[BreakPoints]
                    ,[ScoredLostPoints]
                    ,[TotalServes]
                    ,[ServeErrors]
                    ,[ServePoints]
                    ,[TotalReceptions]
                    ,[ReceptionErrors]
                    ,[PerfectReceptionPercent]
                    ,[ExcellentReceptionPercent]
                    ,[TotalAttacks]
                    ,[AttackErrors]
                    ,[AttackBlocks]
                    ,[AttackPoints]
                    ,[AttackPointPercent]
                    ,[BlockPoints]
                )
            SELECT 
                 D.[DateID] AS [MatchDateID]
				,[FolderName] AS [FolderName]
                ,COALESCE(SE.[SeasonID], -1) AS [SeasonID]
                ,COALESCE(ST.[StageID], -1) AS [StageID]
                ,COALESCE(HC.[CityID], -1) AS [HostCityID]
                ,COALESCE(HT.[TeamID], -1) AS [HostTeamID]
                ,COALESCE(GT.[TeamID], -1) AS [GuestTeamID]
                ,F.[OpponentTeamName] AS [OpponentTeamName]
                ,COALESCE(T.[TeamID], -1) AS [TeamID]
                ,F.[TeamName] AS [PlayerTeamName]
                ,COALESCE(P.[PlayerID], -1) AS [PlayerID]
                ,F.[PlayerName]
                ,F.[PlayerNumber]
                ,ISNULL(F.[Set1], 0) AS [Set1]
                ,ISNULL(F.[Set2], 0) AS [Set2]
                ,ISNULL(F.[Set3], 0) AS [Set3]
                ,ISNULL(F.[Set4], 0) AS [Set4]
                ,ISNULL(F.[Set5], 0) AS [Set5]
                ,ISNULL(F.[TotalPoints], 0) AS [TotalPoints]
                ,ISNULL(F.[BreakPoints], 0) AS [BreakPoints]
                ,ISNULL(F.[ScoredLostPoints], 0) AS [ScoredLostPoints]
                ,ISNULL(F.[TotalServes], 0) AS [TotalServes]
                ,ISNULL(F.[ServeErrors], 0) AS [ServeErrors]
                ,ISNULL(F.[ServePoints], 0) AS [ServePoints]
                ,ISNULL(F.[TotalReceptions], 0) AS [TotalReceptions]
                ,ISNULL(F.[ReceptionErrors], 0) AS [ReceptionErrors]
                ,ISNULL(F.[PerfectReceptionPercent], 0) AS [PerfectReceptionPercent]
                ,ISNULL(F.[ExcellentReceptionPercent], 0) AS [ExcellentReceptionPercent]
                ,ISNULL(F.[TotalAttacks], 0) AS [TotalAttacks]
                ,ISNULL(F.[AttackErrors], 0) AS [AttackErrors]
                ,ISNULL(F.[AttackBlocks], 0) AS [AttackBlocks]
                ,ISNULL(F.[AttackPoints], 0) AS [AttackPoints]
                ,ISNULL(F.[AttackPointPercent], 0) AS [AttackPointPercent]
                ,ISNULL(F.[BlockPoints], 0) AS [BlockPoints]
            FROM (
                SELECT DISTINCT
                    [FileName],
                    [FolderName],
                    [MatchDate],
                    [OpponentTeamName],
                    [TeamName],
                    [PlayerNumber],
                    [PlayerName],
                    [Set1],
                    [Set2],
                    [Set3],
                    [Set4],
                    [Set5],
                    [TotalPoints],
                    [BreakPoints],
                    [ScoredLostPoints],
                    [TotalServes],
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
                    [ParentFolderName]
                FROM [stg_excel].[MatchStatsPlayersGeneral]
                WHERE [PlayerName] != 'Всего'
                AND [MatchDate] >= @DateFromD 
                AND [MatchDate] < @DateToD
            ) F
            INNER JOIN [dbo].[dim_Date] D
                ON F.[MatchDate] = D.[DateTime]
LEFT JOIN [dbo].[dim_Players] P
    ON REPLACE(F.[PlayerName], 'ё', 'е') = REPLACE(P.[PlayerName], 'ё', 'е')
    AND F.[PlayerNumber] = P.[PlayerNumber]
            LEFT JOIN [dbo].[dim_Seasons] SE
                ON D.[DateID] >= SE.[SeasonStartDateID]
                AND D.[DateID] <= SE.[SeasonEndDateID]
            LEFT JOIN [dbo].[dim_Stages] ST
                ON REPLACE(F.[ParentFolderName], '_', ' ') = ST.[StagePartName]
                AND SUBSTRING(F.[FolderName], 1, CHARINDEX('_', F.[FolderName]) - 1) = REPLACE(ST.[StagePartTourName], ' ', '') 
            
            -- Определяем команды хозяев и гостей из справочника
            CROSS APPLY (
                SELECT 
                    CASE 
                        WHEN T1.[TeamName] = F.[TeamName] THEN T2.[TeamID]
                        ELSE T1.[TeamID]
                    END AS HostTeamID,
                    CASE 
                        WHEN T1.[TeamName] = F.[TeamName] THEN T1.[TeamID]
                        ELSE T2.[TeamID]
                    END AS GuestTeamID,
                    CASE 
                        WHEN T1.[TeamName] = F.[TeamName] THEN T2.[TeamName]
                        ELSE T1.[TeamName]
                    END AS OpponentTeamName,
                    CASE 
                        WHEN T1.[TeamName] = F.[TeamName] THEN T1.[CityID]
                        ELSE T2.[CityID]
                    END AS HostCityID
                FROM [dbo].[dim_Teams] T1
                JOIN [dbo].[dim_Teams] T2 ON T2.[TeamName] = F.[OpponentTeamName]
                WHERE T1.[TeamName] = F.[TeamName] OR T2.[TeamName] = F.[TeamName]
            ) AS TeamsMapping
            
            LEFT JOIN [dbo].[dim_Teams] HT
                ON TeamsMapping.HostTeamID = HT.[TeamID]
            
            LEFT JOIN [dbo].[dim_Teams] GT
                ON TeamsMapping.GuestTeamID = GT.[TeamID]
            
            LEFT JOIN [dbo].[dim_Cities] HC
                ON TeamsMapping.HostCityID = HC.[CityID]
            
            -- Команда игрока (из поля TeamName)
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