﻿/*
--D:Процедура по заполнению справочника справочника кодов действий
--E: EXEC [dbo].[fill_dim_ActionCodes]
*/


CREATE PROCEDURE [dbo].[fill_dim_ActionCodes]
AS
BEGIN
	--=====================================================================
	--Инициализация логирования:
	--=====================================================================	
	DECLARE  @Name NVARCHAR(MAX) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
			,@Description NVARCHAR(512) = 'Заполнение справочника кодов действий'
			,@InputParameters NVARCHAR(512) = ''
	BEGIN TRY
		--=====================================================================
		--Запуск логирования:
		--=====================================================================
		EXEC [oth].[fill_SupLog] @Name = @Name,	@StateName = 'start', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
		--=====================================================================
		--Тело процедуры:
		--=====================================================================	

		TRUNCATE TABLE [dbo].[dim_ActionCodes]

		INSERT INTO [dbo].[dim_ActionCodes]
		(
			 [ActionID]
			,[ActionCodeSign] 
			,[ActionCodeDescription]
		)
		VALUES
			(1, 'SQ', 'Силовая в прыжке'),
			(1, 'SM', 'Планер в прыжке'),
			(1, 'ST', 'Планер от линии'),
			(1, 'SH', 'Планер издалека'),

			(2, 'RQ', 'Силовая в прыжке'),
			(2, 'RM', 'Планер в прыжке'),
			(2, 'RT', 'Планер от линии'),
			(2, 'RH', 'Планер издалека'),

			(3, 'AQ', 'Первый темп'),
			(3, 'AT', 'Быстрая передача в 4 и 2 (задняя линия)'),
			(3, 'AH', 'Высокая передача'),
			(3, 'AM', 'Комбинация (волна, крест, пайп)'),
			(3, 'AO', 'Скидка пасующего, переходящий'),

			(4, 'BQ', 'Блокирование первого темпа'),
			(4, 'BT', 'Блокирование быстрой передачи в 4 и 2 (задняя линия)'),
			(4, 'BH', 'Блокирование высокой передачи'),
			(4, 'BM', 'Блокирование комбинации'),
			(4, 'BO', 'Блок скидки пасующего или переходящего'),

			(5, 'DQ', 'От первого темпа'),
			(5, 'DT', 'От быстрой в край'),
			(5, 'DH', 'От высокой'),
			(5, 'DM', 'От комбинации'),
			(5, 'DO', 'От скидки')
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