CREATE TRIGGER [BackupObjects]
ON DATABASE
FOR CREATE_PROCEDURE, 
    ALTER_PROCEDURE, 
    DROP_PROCEDURE,
    CREATE_TABLE, 
    ALTER_TABLE, 
    DROP_TABLE,
    CREATE_FUNCTION, 
    ALTER_FUNCTION, 
    DROP_FUNCTION,
    CREATE_VIEW,
    ALTER_VIEW,
    DROP_VIEW
AS
 
SET NOCOUNT ON
 
DECLARE @Data XML
SET @Data = EVENTDATA()
 
INSERT INTO [oth].[SupChangeObjectsLog]
	 ([DatabaseName]
      ,[EventType]
      ,[ObjectName]
      ,[ObjectType]
      ,[SqlCommand]
      ,[EventDate]
      ,[LoginName]
	  )
VALUES(
@Data.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'varchar(256)'),
@Data.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(64)'), 
'['+@Data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'varchar(256)') + '].[' +  @Data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(256)') + ']', 
@Data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(25)'), 
@Data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'varchar(max)'), 
getdate(),
@Data.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(256)')
)