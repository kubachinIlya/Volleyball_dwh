using data_loader.Models;
using Microsoft.Data.SqlClient;
using OfficeOpenXml;
using System.Globalization;
using Dapper;
using System.Text.RegularExpressions;
// Импортер для статистики матчей
public class MatchStatsImporter : BaseImporterExcel
{
    protected override string ReportCode => "MATCH";

    public MatchStatsImporter(string connectionString, string rootFolder)
        : base(connectionString, rootFolder) { }

    public void ProcessAllMatches()
    {
        foreach (var filePath in Directory.EnumerateFiles(_rootFolder, "Партии_*.xlsx", SearchOption.AllDirectories))
        {
            ProcessFile(filePath, ImportData);
        }
    }
    private int ParseSetNumber(string cellValue)
    {
        if (string.IsNullOrWhiteSpace(cellValue)) return -1;
        return int.TryParse(cellValue.Replace("Партия", "").Trim(), out int result) ? result : -1;
    }
    private string ExtractTeamName(string filePath)
    {
        return Path.GetFileNameWithoutExtension(filePath).Substring("Партии_".Length);
    }
    private void ImportData(string filePath)
    {
        var folderInfo = GetFolderInfo(filePath);
        var stats = new List<MatchStatsSet>();
        var teamName = ExtractTeamName(filePath);

        using (var package = new ExcelPackage(new FileInfo(filePath)))
        {
            var worksheet = package.Workbook.Worksheets[0];
            for (int row = 2; row <= worksheet.Dimension.Rows; row++)
            {
                var setNumber = ParseSetNumber(worksheet.Cells[row, 1].Text);
                if (setNumber == -1) continue;

                stats.Add(new MatchStatsSet
                {
                    FileName = Path.GetFileName(filePath),
                    FolderName = folderInfo.FolderName,
                    MatchDate = folderInfo.MatchDate,
                    TeamName = teamName,
                    SetNumber = setNumber,
                    PointsOnServe = ParseInt(worksheet.Cells[row, 3].Text),
                    PointsOnAttack = ParseInt(worksheet.Cells[row, 5].Text),
                    PointsOnBlock = ParseInt(worksheet.Cells[row, 7].Text),
                    PointsOnOpponentErrors = ParseInt(worksheet.Cells[row, 9].Text),
                    TotalPoints = ParseInt(worksheet.Cells[row, 11].Text),
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
                    BlockPoints = ParseInt(worksheet.Cells[row, 23].Text)
                });
            }
        }

        SaveToDatabase(stats, "[stg_excel].[MatchStatsSets]");
    }
} 
 