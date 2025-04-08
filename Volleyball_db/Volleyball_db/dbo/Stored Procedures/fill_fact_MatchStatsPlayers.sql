/*
--D:Процедура по заполнению факта информации об играх игроков
--E: EXEC [dbo].[fill_fact_MatchStatsPlayers] @DateFrom = 20240101 ,@DateTo = 20250101
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
			,@InputParameters NVARCHAR(512) = ''
	BEGIN TRY
		--=====================================================================
		--Запуск логирования:
		--=====================================================================
		EXEC [oth].[fill_SupLog] @Name = @Name,	@StateName = 'start', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
		--=====================================================================
		--Тело процедуры:
		--=====================================================================	
		DECLARE @DateFromD DATE = [dbo].[IntToDate](@DateFrom)
		DECLARE @DateToD DATE = [dbo].[IntToDate](@DateTo)

		IF EXISTS (SELECT [MatchDate] FROM [stg_excel].[MatchStatsPlayersGeneral] WHERE [MatchDate] >= @DateFromD AND [MatchDate] < @DateToD)
			BEGIN
				DELETE TOP (10000) F
				FROM [dbo].[fact_MatchStatsPlayers] AS F
				WHERE
					F.[MatchDateID] >= @DateFrom 
					AND F.[MatchDateID] < @DateTo
				WHILE @@ROWCOUNT > 0
				BEGIN 
					DELETE TOP (10000) F
					FROM [dbo].[fact_MatchStatsPlayers]  AS F
					WHERE
					F.[MatchDateID] >= @DateFrom 
					AND F.[MatchDateID] < @DateTo
				END

			INSERT INTO [dbo].[fact_MatchStatsPlayers]
				(
					 [MatchDateID]
					,[SeasonID]
					,[StageID]
					,[HostCityID]
					,[HostTeamID]
					,[GuestTeamID]
					,[TeamID]
					,[PlayerID]
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
				,SE.[SeasonID]
				,ST.[StageID]
				,HC.[CityID] AS [HostCityID]
				,IIF(T1.[CityID] = HC.[CityID], T1.[TeamID], T2.[TeamID]) AS [HostTeamID]
				,IIF(T1.[CityID] = HC.[CityID], T2.[TeamID], T1.[TeamID]) AS [GuestTeamID]
				,T.[TeamID]
				,COALESCE(P.[PlayerID], -1) AS [PlayerID]
				,F.[Set1]
				,F.[Set2]
				,F.[Set3]
				,F.[Set4]
				,F.[Set5]
				,F.[TotalPoints]
				,F.[BreakPoints]
				,F.[ScoredLostPoints]
				,F.[TotalServes]
				,F.[ServeErrors]
				,F.[ServePoints]
				,F.[TotalReceptions]
				,F.[ReceptionErrors]
				,F.[PerfectReceptionPercent]
				,F.[ExcellentReceptionPercent]
				,F.[TotalAttacks]
				,F.[AttackErrors]
				,F.[AttackBlocks]
				,F.[AttackPoints]
				,F.[AttackPointPercent]
				,F.[BlockPoints]
			FROM [stg_excel].[MatchStatsPlayersGeneral] F
			LEFT JOIN [dbo].[dim_Date] D
				ON F.[MatchDate] = D.[DateTime]
			LEFT JOIN [dbo].[dim_Players] P
				ON F.[PlayerName] = P.[PlayerName]
				AND F.[PlayerNumber] = P.[PlayerNumber]
			LEFT JOIN [dbo].[dim_Seasons] SE
				ON D.[DateID] > SE.[SeasonStartDateID]
				AND D.[DateID] < SE.[SeasonEndDateID]
			LEFT JOIN [dbo].[dim_Stages] ST
				ON REPLACE(F.[ParentFolderName], '_', ' ') = ST.[StagePartName]
				AND SUBSTRING(F.[FolderName], 0, CHARINDEX('_', F.[FolderName])) = REPLACE(ST.[StagePartTourName], ' ', '')
			LEFT JOIN [dbo].[dim_Cities] HC
				ON SUBSTRING(F.[FolderName], CHARINDEX('_', F.[FolderName]) + 1, CHARINDEX('#', F.[FolderName]) - CHARINDEX('_', F.[FolderName]) - 1) = HC.[CityName]
			LEFT JOIN [dbo].[dim_Teams] T1
				ON SUBSTRING(F.[FolderName], CHARINDEX('#', F.[FolderName]) + 1, CHARINDEX('&', F.[FolderName]) - CHARINDEX('#', F.[FolderName]) - 1) = T1.[TeamName]
			LEFT JOIN [dbo].[dim_Teams] T2
				ON SUBSTRING(F.[FolderName], CHARINDEX('&', F.[FolderName]) + 1, LEN(F.[FolderName]) - CHARINDEX('&', F.[FolderName])) = T2.[TeamName]
			LEFT JOIN [dbo].[dim_Teams] T
				ON T.[TeamName] = F.[TeamName]
			WHERE
				F.[PlayerName] != 'Всего'
				AND [MatchDate] >= @DateFromD 
				AND [MatchDate] < @DateToD
		
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
		EXEC [oth].[fill_SupLog] @Name = @Name, @StateName = 'error', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
	END CATCH
END