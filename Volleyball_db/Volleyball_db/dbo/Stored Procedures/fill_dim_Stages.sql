/*
--D:Процедура по заполнению справочника справочника этапов
--E: EXEC [dbo].[fill_dim_Stages]
*/

CREATE PROCEDURE [dbo].[fill_dim_Stages]
AS
BEGIN
	--=====================================================================
	--Инициализация логирования:
	--=====================================================================	
	DECLARE  @Name NVARCHAR(MAX) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
			,@Description NVARCHAR(512) = 'Заполнение справочника этапов'
			,@InputParameters NVARCHAR(512) = ''
	BEGIN TRY
		--=====================================================================
		--Запуск логирования:
		--=====================================================================
		EXEC [oth].[fill_SupLog] @Name = @Name,	@StateName = 'start', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
		--=====================================================================
		--Тело процедуры:
		--=====================================================================	

		TRUNCATE TABLE [dbo].[dim_Stages]

		-- Вставка предварительных этапов
		DECLARE @i INT = 1;
		WHILE @i <= 50
		BEGIN
			INSERT INTO [dbo].[dim_Stages] ([StagePartName], [StagePartTourName])
			VALUES ('Предварительный этап', CAST(@i AS NVARCHAR(2)) + ' тур');
			SET @i = @i + 1;
		END

		-- Вставка четвертьфинала
		INSERT INTO [dbo].[dim_Stages] ([StagePartName], [StagePartTourName])
		VALUES ('Четвертьфинал', NULL);

		-- Вставка полуфинала
		INSERT INTO [dbo].[dim_Stages] ([StagePartName], [StagePartTourName])
		VALUES ('Полуфинал', NULL);

		-- Вставка третьего места
		INSERT INTO [dbo].[dim_Stages] ([StagePartName], [StagePartTourName])
		VALUES ('Третье место', NULL);

		-- Вставка финала
		SET @i = 1;
		WHILE @i <= 5
		BEGIN
			INSERT INTO [dbo].[dim_Stages] ([StagePartName], [StagePartTourName])
			VALUES ('Финал', CAST(@i AS NVARCHAR(2)) + ' матч');
			SET @i = @i + 1;
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