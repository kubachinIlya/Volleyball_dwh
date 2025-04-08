/*
--D:Процедура по заполнению справочника комбинаций
--E: EXEC [dbo].[fill_dim_Combinations]
*/


CREATE PROCEDURE [dbo].[fill_dim_Combinations]
AS
BEGIN
	--=====================================================================
	--Инициализация логирования:
	--=====================================================================	
	DECLARE  @Name NVARCHAR(MAX) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
			,@Description NVARCHAR(512) = 'Заполнение справочника комбинаций'
			,@InputParameters NVARCHAR(512) = ''
	BEGIN TRY
		--=====================================================================
		--Запуск логирования:
		--=====================================================================
		EXEC [oth].[fill_SupLog] @Name = @Name,	@StateName = 'start', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
		--=====================================================================
		--Тело процедуры:
		--=====================================================================	

		TRUNCATE TABLE [dbo].[dim_Combinations]

		INSERT INTO [dbo].[dim_Combinations]
		(
			 [CombinationID]
			,[CombinationDescription]
		)
		VALUES
			(1, 'Первый темп'),
			(2, 'Быстрые мячи'),
			(3, 'Высокие мячи'),
			(4, 'Комбинационные атаки'),
			(5, 'Другие варианты')
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