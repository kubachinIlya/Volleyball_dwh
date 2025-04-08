/*
--D:Процедура по заполнению справочника справочника городов
--E: EXEC [dbo].[fill_dim_Cities]
*/

CREATE PROCEDURE [dbo].[fill_dim_Cities]
AS
BEGIN
	--=====================================================================
	--Инициализация логирования:
	--=====================================================================	
	DECLARE  @Name NVARCHAR(MAX) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
			,@Description NVARCHAR(512) = 'Заполнение справочника городов'
			,@InputParameters NVARCHAR(512) = ''
	BEGIN TRY
		--=====================================================================
		--Запуск логирования:
		--=====================================================================
		EXEC [oth].[fill_SupLog] @Name = @Name,	@StateName = 'start', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
		--=====================================================================
		--Тело процедуры:
		--=====================================================================	

		TRUNCATE TABLE [dbo].[dim_Cities]

		INSERT INTO [dbo].[dim_Cities] (
			[CityName]
		)
		VALUES 
			(N'Белгород'),
			(N'Сосновый Бор'),
			(N'Казань'),
			(N'Новокуйбышевск'),
			(N'Нижний Новгород'),
			(N'Сургут'),
			(N'Москва'),
			(N'Уфа'),
			(N'Красноярск'),
			(N'Санкт-Петербург'),
			(N'Кемерово'),
			(N'Новосибирск'),
			(N'Новый Уренгой'),
			(N'Оренбург'),
			(N'Москва'),
			(N'Тула');
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