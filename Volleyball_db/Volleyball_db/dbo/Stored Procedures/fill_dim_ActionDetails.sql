﻿/*
--D:Процедура по заполнению справочника справочника детализации действий
--E: EXEC [dbo].[fill_dim_ActionDetails]
*/


CREATE PROCEDURE [dbo].[fill_dim_ActionDetails]
AS
BEGIN
	--=====================================================================
	--Инициализация логирования:
	--=====================================================================	
	DECLARE  @Name NVARCHAR(MAX) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
			,@Description NVARCHAR(512) = 'Заполнение справочника детализации действий'
			,@InputParameters NVARCHAR(512) = ''
	BEGIN TRY
		--=====================================================================
		--Запуск логирования:
		--=====================================================================
		EXEC [oth].[fill_SupLog] @Name = @Name,	@StateName = 'start', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
		--=====================================================================
		--Тело процедуры:
		--=====================================================================	

		TRUNCATE TABLE [dbo].[dim_ActionDetails]

		INSERT INTO [dbo].[dim_ActionDetails]
		(
			 [ActionID]
			,[ActionDetailSign] 
			,[ActionDetailDescription]
		)
		VALUES
			(1, '=', 'Подача в сетку, аут'),
			(1, '/', 'Переходящий или приём без атаки'),
			(1, '-', 'Подача без затруднения'),
			(1, '!', 'Подача между + и -, когда приём на 3 метра'),
			(1, '+', 'Усложнённая подача, когда приём от 4 и далее метров'),
			(1, '#', 'Выигранная подача'),

			(2, '=', 'Мяч проигран'),
			(2, '/', 'Переходящий или приём без атаки'),
			(2, '-', 'Приём от 4 метров и далее'),
			(2, '!', 'Приём на 2,5 – 3,5 метра'),
			(2, '+', 'Приём на 1 – 2,5 метра'),
			(2, '#', 'Приём 0 – 1 метр (идеальная доводка), передача связки в прыжке с возможностью скидки'),

			(3, '=', 'Удар в сетку, аут'),
			(3, '/', 'Удар в блок (зачехлили)'),
			(3, '-', 'Удар с ответной атакой соперника'),
			(3, '+', 'Удар без ответной атаки соперника или с повторной своей атакой'),
			(3, '#', 'Мяч выигран'),

			(4, '=', 'Блок-аут'),
			(4, '/', 'Касание сетки'),
			(4, '-', 'Смягчён без своей атаки или с повторной атакой соперника'),
			(4, '+', 'Смягчён со своей атакой или без повторной атаки соперника'),
			(4, '#', 'Мяч выигран'),

			(5, '=', 'Мяч проигран'),
			(5, '-', 'Мяч поднят без своей атаки'),
			(5, '+', 'Мяч поднят со своей атакой')
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