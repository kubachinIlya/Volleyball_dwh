/*
--D:Процедура по заполнению справочника действий
--E: EXEC [dbo].[fill_dim_Players]
*/


CREATE PROCEDURE [dbo].[fill_dim_Players]
AS
BEGIN
	--=====================================================================
	--Инициализация логирования:
	--=====================================================================	
	DECLARE  @Name NVARCHAR(MAX) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
			,@Description NVARCHAR(512) = 'Заполнение справочника действий'
			,@InputParameters NVARCHAR(512) = ''
	BEGIN TRY
		--=====================================================================
		--Запуск логирования:
		--=====================================================================
		EXEC [oth].[fill_SupLog] @Name = @Name,	@StateName = 'start', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
		--=====================================================================
		--Тело процедуры:
		--=====================================================================	

		MERGE INTO [dbo].[dim_Players] AS pdbo
		USING (
			SELECT
				 [PlayerName]
				,[PlayerNumber]
				,[Height] AS [PlayerHeight]
				,CAST(FORMAT([BirthDate], 'yyyyMMdd') AS [int]) AS [PlayerBirthdayDateID]
				,[Citizenship] AS [PlayerCitizenship]
			FROM [stg_excel].[PlayersList]
		) AS pstg
		ON 
			pdbo.[PlayerName] = pstg.[PlayerName]
			AND pdbo.[PlayerNumber] = pstg.[PlayerNumber]
		WHEN NOT MATCHED BY TARGET
		THEN INSERT
			(
				 [PlayerName]
				,[PlayerNumber]
				,[PlayerHeight]
				,[PlayerBirthdayDateID]
				,[PlayerCitizenship]
			)
		VALUES
			(
				 ISNULL(pstg.[PlayerName], 'Н/Д')
				,ISNULL(pstg.[PlayerNumber], -1)
				,ISNULL(pstg.[PlayerHeight], 0)
				,ISNULL(pstg.[PlayerBirthdayDateID], 19000101)
				,ISNULL(pstg.[PlayerCitizenship], 'Н/Д')
			)
		WHEN MATCHED AND
			(
				   pdbo.[PlayerHeight] != ISNULL(pstg.[PlayerHeight], 0)
				OR pdbo.[PlayerBirthdayDateID] != ISNULL(pstg.[PlayerBirthdayDateID], 19000101)
				OR pdbo.[PlayerCitizenship] != ISNULL(pstg.[PlayerCitizenship], 'Н/Д')
			)
		THEN UPDATE SET
				   pdbo.[PlayerHeight] = ISNULL(pstg.[PlayerHeight], 0)
				,  pdbo.[PlayerBirthdayDateID] = ISNULL(pstg.[PlayerBirthdayDateID], 19000101)
				,  pdbo.[PlayerCitizenship] = ISNULL(pstg.[PlayerCitizenship], 'Н/Д');

			--=====================================================================
		--Завершение логирования c успехом:
		--=====================================================================
	EXEC [oth].[fill_SupLog] @Name = @Name, @StateName = 'finish', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
	END TRY
	
	BEGIN CATCH
		--=====================================================================
		--Завершение логирования c ошибкой:
		--=====================================================================
		EXEC [oth].[fill_SupLog]@Name = @Name, @StateName = 'error', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
	END CATCH
END