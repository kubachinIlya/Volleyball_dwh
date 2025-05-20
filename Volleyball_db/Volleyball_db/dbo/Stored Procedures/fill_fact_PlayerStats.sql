/*
--D:Процедура по заполнению факта статистики игроков с веб-источника
--E: EXEC [dbo].[fill_fact_PlayerStats] @DateFrom = 20240101 ,@DateTo = 20270101
*/

CREATE   PROCEDURE [dbo].[fill_fact_PlayerStats]
     @DateFrom INT
    ,@DateTo INT
AS
BEGIN
    --=====================================================================
    --Инициализация логирования:
    --=====================================================================    
    DECLARE  @Name NVARCHAR(MAX) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
            ,@Description NVARCHAR(512) = 'Заполнение факта статистики игроков с веб-источника'
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

        IF EXISTS (SELECT [LoadDate] FROM [stg_web].[PlayerStats] WHERE [LoadDate] >= @DateFromD AND [LoadDate] < @DateToD)
        BEGIN
            -- Удаление данных пачками по 10000 записей
            DELETE TOP (10000) F
            FROM [dbo].[fact_PlayerStats] AS F
            INNER JOIN [dbo].[dim_Date] D ON F.[LoadDateID] = D.[DateID]
            WHERE D.[DateID] >= @DateFrom AND D.[DateID] < @DateTo
            
            WHILE @@ROWCOUNT > 0
            BEGIN 
                DELETE TOP (10000) F
                FROM [dbo].[fact_PlayerStats] AS F
                INNER JOIN [dbo].[dim_Date] D ON F.[LoadDateID] = D.[DateID]
                WHERE D.[DateID] >= @DateFrom AND D.[DateID] < @DateTo
            END

            -- Вставка данных
            INSERT INTO [dbo].[fact_PlayerStats]
            (
                [LoadDateID],
                [PlayerID],
                [PositionID],
                [Games],
                [Points],
                [AveragePoints],
                [PointsDifference],
                [SourceTotal],
                [SourcePoints],
                [SourceEfficiency],
                [ReceiveTotal],
                [ReceiveGood],
                [ReceiveEfficiency],
                [AttackTotal],
                [AttackPoints],
                [AttackEfficiency],
                [BlockPoints],
                [BlockAverage],
                [ErrorServe],
                [ErrorReceive],
                [ErrorAttack],
                [ErrorTotal]
            )
            SELECT 
                D.[DateID] AS [LoadDateID],
                COALESCE(P.[PlayerID], -1) AS [PlayerID],
               -- COALESCE(POS.[PositionID], -1)
				NULL AS [PositionID],
                ISNULL(F.[Games], 0) AS [Games],
                ISNULL(F.[Points], 0) AS [Points],
                ISNULL(F.[AveragePoints], 0) AS [AveragePoints],
                ISNULL(F.[PointsDifference], 0) AS [PointsDifference],
                ISNULL(F.[SourceTotal], 0) AS [SourceTotal],
                ISNULL(F.[SourcePoints], 0) AS [SourcePoints],
                ISNULL(F.[SourceEfficiency], 0) AS [SourceEfficiency],
                ISNULL(F.[ReceiveTotal], 0) AS [ReceiveTotal],
                ISNULL(F.[ReceiveGood], 0) AS [ReceiveGood],
                ISNULL(F.[ReceiveEfficiency], 0) AS [ReceiveEfficiency],
                ISNULL(F.[AttackTotal], 0) AS [AttackTotal],
                ISNULL(F.[AttackPoints], 0) AS [AttackPoints],
                ISNULL(F.[AttackEfficiency], 0) AS [AttackEfficiency],
                ISNULL(F.[BlockPoints], 0) AS [BlockPoints],
                ISNULL(F.[BlockAverage], 0) AS [BlockAverage],
                ISNULL(F.[ErrorServe], 0) AS [ErrorServe],
                ISNULL(F.[ErrorReceive], 0) AS [ErrorReceive],
                ISNULL(F.[ErrorAttack], 0) AS [ErrorAttack],
                ISNULL(F.[ErrorTotal], 0) AS [ErrorTotal]
            FROM (
                SELECT DISTINCT
                    [LoadDate],
                    [Name],
                    NULL AS [Position],
                    [Games],
                    [Points],
                    [AveragePoints],
                    [PointsDifference],
                    [SourceTotal],
                    [SourcePoints],
                    [SourceEfficiency],
                    [ReceiveTotal],
                    [ReceiveGood],
                    [ReceiveEfficiency],
                    [AttackTotal],
                    [AttackPoints],
                    [AttackEfficiency],
                    [BlockPoints],
                    [BlockAverage],
                    [ErrorServe],
                    [ErrorReceive],
                    [ErrorAttack],
                    [ErrorTotal]
                FROM [stg_web].[PlayerStats]
                WHERE [LoadDate] >= @DateFromD 
                AND [LoadDate] < @DateToD
            ) F
            LEFT JOIN [dbo].[dim_Date] D
                ON F.[LoadDate] = D.[DateTime]
            LEFT JOIN [dbo].[dim_Players] P
                ON REPLACE(F.[Name], 'ё', 'е') = REPLACE(P.[PlayerName], 'ё', 'е')
            --LEFT JOIN [dbo].[dim_Positions] POS
            --    ON F.[Position] = POS.[PositionName]
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