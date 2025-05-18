using System;
using System.Globalization;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Data.SqlClient;
using Dapper;
using OfficeOpenXml;


// Импортер для статистики игроков
public class PlayerStatsImporter : BaseImporterExcel
{
    protected override string ReportCode => "PLAYER";
    public PlayerStatsImporter(string connectionString, string rootFolder)
        : base(connectionString, rootFolder) { }

    public void ProcessAllPlayers()
    {
        foreach (var filePath in Directory.EnumerateFiles(_rootFolder, "Игроки_*.xlsx", SearchOption.AllDirectories))
        {
            ProcessFile(filePath, ImportData);
        }
    }

    private int ParsePlayerNumber(string value)
    {
        var numberPart = new string(value.TakeWhile(char.IsDigit).ToArray());
        return int.TryParse(numberPart, out int result) ? result : 0;
    }

    private void ImportData(string filePath)
    {
        var folderInfo = GetFolderInfo(filePath);
        var players = new List<MatchStatsPlayer>();
        var teamName = Path.GetFileNameWithoutExtension(filePath).Split('_').Last();
        Console.WriteLine($"Обработка файла: {filePath}");

        // Получаем название папки матча (например: "9_тур_Кемерово_26-10-2024_Кузбасс_против_Газпром-Югра")
        var matchFolderName = Path.GetFileName(Path.GetDirectoryName(filePath));

        // Извлекаем название команды соперника из названия папки
        string opponentTeamName = null;
        if (matchFolderName.Contains("_против_"))
        {
            var parts = matchFolderName.Split(new[] { "_против_" }, StringSplitOptions.None);
            if (parts.Length == 2)
            {
                // Определяем, какая команда является соперником
                var homeTeam = parts[0].Split('_').Last();
                opponentTeamName = parts[1].Split('_').First();

                // Если текущая команда совпадает с домашней, то соперник - гостевая команда
                // Иначе соперник - домашняя команда
                if (teamName != homeTeam)
                {
                    opponentTeamName = homeTeam;
                }
            }
        }

        using (var package = new ExcelPackage(new FileInfo(filePath)))
        {
            var worksheet = package.Workbook.Worksheets[0];
            for (int row = 3; row <= worksheet.Dimension.Rows; row++)
            {
                var playerNumberCell = worksheet.Cells[row, 1].Text;
                if (string.IsNullOrWhiteSpace(playerNumberCell)) continue;

                var player = new MatchStatsPlayer
                {
                    FileName = Path.GetFileName(filePath),
                    FolderName = folderInfo.FolderName,
                    MatchDate = folderInfo.MatchDate,
                    TeamName = teamName,
                    OpponentTeamName = opponentTeamName, // Заполняем поле соперника
                    PlayerNumber = ParsePlayerNumber(playerNumberCell),
                    PlayerName = worksheet.Cells[row, 2].Text.Trim(),
                    Set1 = ParseNullableInt(worksheet.Cells[row, 3].Text),
                    Set2 = ParseNullableInt(worksheet.Cells[row, 4].Text),
                    Set3 = ParseNullableInt(worksheet.Cells[row, 5].Text),
                    Set4 = ParseNullableInt(worksheet.Cells[row, 6].Text),
                    Set5 = ParseNullableInt(worksheet.Cells[row, 7].Text),
                    TotalPoints = ParseInt(worksheet.Cells[row, 8].Text),
                    BreakPoints = ParseInt(worksheet.Cells[row, 9].Text),
                    ScoredLostPoints = ParseInt(worksheet.Cells[row, 10].Text),
                    TotalServes = ParseInt(worksheet.Cells[row, 11].Text),
                    ServeErrors = ParseInt(worksheet.Cells[row, 12].Text),
                    ServePoints = ParseInt(worksheet.Cells[row, 13].Text),
                    TotalReceptions = ParseInt(worksheet.Cells[row, 14].Text),
                    ReceptionErrors = ParseInt(worksheet.Cells[row, 15].Text),
                    PerfectReceptionPercent = ParseDecimal(worksheet.Cells[row, 16].Text),
                    ExcellentReceptionPercent = ParseDecimal(worksheet.Cells[row, 17].Text),
                    TotalAttacks = ParseInt(worksheet.Cells[row, 18].Text),
                    AttackErrors = ParseInt(worksheet.Cells[row, 19].Text),
                    AttackBlocks = ParseInt(worksheet.Cells[row, 20].Text),
                    AttackPoints = ParseInt(worksheet.Cells[row, 21].Text),
                    AttackPointPercent = ParseDecimal(worksheet.Cells[row, 22].Text),
                    BlockPoints = ParseInt(worksheet.Cells[row, 23].Text),
                    ParentFolderName = Directory.GetParent(Path.GetDirectoryName(filePath)).Name
                };

                players.Add(player);
            }
        }

        SaveToDatabase(players, "[stg_excel].[MatchStatsPlayersGeneral]");
    }
}
 

 