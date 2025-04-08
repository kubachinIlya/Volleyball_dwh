/*
--D:Процедура по заполнению справочника сезонов
--E: EXEC [dbo].[fill_dim_Seasons] @SeasonName = 'Сезон 2023-2024', @SeasonStartDateID = 20241001 ,@SeasonEndDateID = 20250501
*/


CREATE PROCEDURE [dbo].[fill_dim_Seasons]
	 @SeasonName NVARCHAR(64)
	,@SeasonStartDateID INT
	,@SeasonEndDateID INT
AS
BEGIN
	--=====================================================================
	--Инициализация логирования:
	--=====================================================================	
	DECLARE  @Name NVARCHAR(MAX) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
			,@Description NVARCHAR(512) = 'Заполнение справочника сезонов'
			,@InputParameters NVARCHAR(512) = '@SeasonName = ''' + @SeasonName + ''', @SeasonStartDateID = ' + CAST(@SeasonStartDateID AS NVARCHAR(8)) + ' ,@SeasonEndDateID = ' + CAST(@SeasonEndDateID AS NVARCHAR(8))
	BEGIN TRY
		--=====================================================================
		--Запуск логирования:
		--=====================================================================
		EXEC [oth].[fill_SupLog] @Name = @Name,	@StateName = 'start', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
		--=====================================================================
		--Тело процедуры:
		--=====================================================================	
		
		MERGE INTO [dbo].[dim_Seasons] AS sdbo
		USING (
			SELECT
				 @SeasonName AS [SeasonName]
				,@SeasonStartDateID AS [SeasonStartDateID]
				,@SeasonEndDateID AS [SeasonEndDateID]
		) AS sstg
		ON 
			sdbo.[SeasonName] = sstg.[SeasonName]
		WHEN NOT MATCHED BY TARGET
		THEN INSERT
			(
				 [SeasonName]
				,[SeasonStartDateID]
				,[SeasonEndDateID]
			)
		VALUES
			(
				 sstg.[SeasonName]
				,sstg.[SeasonStartDateID]
				,sstg.[SeasonEndDateID]
			)
		WHEN MATCHED AND
			(
			     sdbo.[SeasonStartDateID] != sstg.[SeasonStartDateID]
			  OR sdbo.[SeasonEndDateID] != sstg.[SeasonEndDateID]
			)
		THEN UPDATE SET
			     sdbo.[SeasonStartDateID] = sstg.[SeasonStartDateID]
			 ,   sdbo.[SeasonEndDateID] = sstg.[SeasonEndDateID];

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