using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.IO;

public class PlayersListImporter : BaseImporterExcel
{
    public PlayersListImporter(string connectionString, string rootFolder)
        : base(connectionString, rootFolder)
    {
    }

    protected override string ReportCode => "PlayersList";

    public void ProcessAllPlayers()
    {
        var files = Directory.GetFiles(_rootFolder, "Команда*.xlsx", SearchOption.AllDirectories);
        foreach (var file in files)
        {
            if (Path.GetFileNameWithoutExtension(file).Contains("Команда"))
            {
                ProcessFile(file, ImportPlayers);
            }
        }
    }

    private void ImportPlayers(string filePath)
    {
        // Парсим информацию из имени файла
        var fileName = Path.GetFileNameWithoutExtension(filePath);
        var fileParts = fileName.Split('_');

        if (fileParts.Length < 3)
        {
            throw new FormatException($"Некорректный формат имени файла: {fileName}. Ожидается: Команда_НазваниеКоманды_Год");
        }

        var teamName = fileParts[1]; // Часть между первым и вторым подчеркиванием
        if (!int.TryParse(fileParts[2], out int year) || year < 1900 || year > 2100)
        {
            throw new FormatException($"Некорректный год в имени файла: {fileParts[2]}");
        }

        var matchDate = new DateTime(year, 1, 1); // Используем 1 января указанного года

        using var package = new ExcelPackage(new FileInfo(filePath));
        var worksheet = package.Workbook.Worksheets[0];

        var players = new List<PlayerInfo>();
        string currentPosition = null;

        for (int row = 1; row <= worksheet.Dimension.End.Row; row++)
        {
            // Проверяем, является ли строка заголовком позиции (начинается с #)
            var positionHeader = worksheet.Cells[row, 1].Text;
            if (positionHeader.StartsWith("#"))
            {
                currentPosition = positionHeader.TrimStart('#').Trim();
                continue;
            }

            // Пропускаем строки без номера игрока
            if (!int.TryParse(worksheet.Cells[row, 1].Text, out int playerNumber))
                continue;

            var player = new PlayerInfo
            {
                PlayerNumber = playerNumber,
                PlayerName = worksheet.Cells[row, 2].Text.Trim(),
                Position = currentPosition,
                Height = ParseInt(worksheet.Cells[row, 3].Text),
                BirthDate = ParseBirthDate(worksheet.Cells[row, 4].Text),
                Age = ParseNullableInt(worksheet.Cells[row, 5].Text),
                Citizenship = worksheet.Cells[row, 6].Text.Trim(),
                Team = teamName, // Берем название команды из имени файла
                SeasonDate = matchDate
            };

            players.Add(player);
        }

        SaveToDatabase(players, "[stg_excel].[PlayersList]");
    }

    private DateTime? ParseBirthDate(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
            return null;

        // Пробуем разные форматы даты
        if (int.TryParse(value, out int year) && year > 1900 && year < 2100)
        {
            return new DateTime(year, 1, 1);
        }

        if (DateTime.TryParse(value, out DateTime date))
        {
            return date;
        }

        return null;
    } 
}