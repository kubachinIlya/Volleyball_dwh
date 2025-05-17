using data_loader.Models;
using Microsoft.Data.SqlClient;
using OfficeOpenXml;
using System.Globalization;
using Dapper;
using System.Text.RegularExpressions;
// Импортер для статистики матчей
public class MatchStatsImporter : BaseImporter
{
    public MatchStatsImporter(string connectionString, string rootFolder)
        : base(connectionString, rootFolder) { }

    public void ProcessAllMatches()
    {
        foreach (var filePath in Directory.EnumerateFiles(_rootFolder, "Партии_*.xlsx", SearchOption.AllDirectories))
        {
            try
            {
                var folderInfo = GetFolderInfo(filePath);
                ImportData(filePath, folderInfo);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка в файле {filePath}: {ex.Message}");
            }
        }
    }

    private void ImportData(string filePath, (DateTime MatchDate, string HomeTeam, string AwayTeam, string FolderName) folderInfo)
    {
        var stats = new List<MatchStatsSet>();
        var teamName = Path.GetFileNameWithoutExtension(filePath).Split('_').Last();

        using (var package = new ExcelPackage(new FileInfo(filePath)))
        {
            var worksheet = package.Workbook.Worksheets[0];
            for (int row = 2; row <= worksheet.Dimension.Rows; row++)
            {
                // ... (логика обработки данных матчей)
            }
        }

        SaveToDatabase(stats, "[stg_excel].[MatchStatsSets]", matchStatsColumns);
    }
} 
public class MatchStatSetLoader
{
    private readonly string _connectionString;
    private readonly string _rootFolder;

    public MatchStatSetLoader(string connectionString, string rootFolder)
    {
        ExcelPackage.License.SetNonCommercialOrganization("My Noncommercial organization ITMO diploma");
        _connectionString = connectionString;
        _rootFolder = rootFolder;
    }

    public void ProcessAllMatches()
    {
        var excelFiles = Directory.EnumerateFiles(_rootFolder, "Партии_*.xlsx", SearchOption.AllDirectories);

        foreach (var filePath in excelFiles)
        {
            var folderInfo = GetFolderInfo(filePath);
            var teamName = Path.GetFileNameWithoutExtension(filePath).Split('_').Last();

            ImportExcelData(filePath, folderInfo);
        }
    }

    private (DateTime MatchDate, string HomeTeam, string AwayTeam, string FolderName) GetFolderInfo(string filePath)
    {
        var directory = new DirectoryInfo(Path.GetDirectoryName(filePath));
        var folderName = directory.Name;

        // парсинг даты
        var dateMatch = Regex.Match(folderName, @"(\d{2}[_-]\d{2}[_-]\d{4})");
        if (!dateMatch.Success)
        {
            throw new FormatException($"Не удалось найти дату в названии папки: {folderName}");
        }

        var datePart = dateMatch.Value.Replace('_', '-');
        if (!DateTime.TryParseExact(datePart,
            new[] { "dd-MM-yyyy", "d-MM-yyyy", "dd-M-yyyy", "d-M-yyyy" },
            CultureInfo.InvariantCulture,
            DateTimeStyles.None,
            out var matchDate))
        {
            throw new FormatException($"Некорректный формат даты: {datePart}");
        }

        //   парсинг названий команд
        var противIndex = folderName.IndexOf("_против_", StringComparison.Ordinal);
        if (противIndex == -1)
        {
            throw new FormatException($"Не найден разделитель команд '_против_' в названии папки: {folderName}");
        }

        var homeTeamPart = folderName.Substring(0, противIndex);
        var awayTeamPart = folderName.Substring(противIndex + "_против_".Length);

        var homeTeam = homeTeamPart.Split('_').Last();
        var awayTeam = awayTeamPart.Split('_').First();

        return (
            MatchDate: matchDate,
            HomeTeam: homeTeam,
            AwayTeam: awayTeam,
            FolderName: folderName
        );
    }

    private void ImportExcelData(string filePath, (DateTime MatchDate, string HomeTeam, string AwayTeam, string FolderName) folderInfo)
    {
        var stats = new List<MatchStatsSet>();

        using (var package = new ExcelPackage(new FileInfo(filePath)))
        {
            var worksheet = package.Workbook.Worksheets[0];
            int rowCount = worksheet.Dimension.Rows;

            for (int row = 2; row <= rowCount; row++)
            {
                var setNumber = ParseSetNumber(worksheet.Cells[row, 1].Text);
                if (setNumber == -1) continue;

                stats.Add(new MatchStatsSet
                {
                    FileName = Path.GetFileName(filePath),
                    FolderName = folderInfo.FolderName,
                    MatchDate = folderInfo.MatchDate,
                    TeamName = folderInfo.HomeTeam, // или другая логика выбора команды
                    SetNumber = setNumber,
                    PointsOnServe = ParseInt(worksheet.Cells[row, 2].Text),
                    PointsOnAttack = ParseInt(worksheet.Cells[row, 3].Text),
                    PointsOnBlock = ParseInt(worksheet.Cells[row, 4].Text),
                    PointsOnOpponentErrors = ParseInt(worksheet.Cells[row, 5].Text),
                    TotalPoints = ParseInt(worksheet.Cells[row, 6].Text),
                    ServeErrors = ParseInt(worksheet.Cells[row, 7].Text),
                    ServePoints = ParseInt(worksheet.Cells[row, 8].Text),
                    TotalReceptions = ParseInt(worksheet.Cells[row, 9].Text),
                    ReceptionErrors = ParseInt(worksheet.Cells[row, 10].Text),
                    PerfectReceptionPercent = ParseDecimal(worksheet.Cells[row, 11].Text),
                    ExcellentReceptionPercent = ParseDecimal(worksheet.Cells[row, 12].Text),
                    TotalAttacks = ParseInt(worksheet.Cells[row, 13].Text),
                    AttackErrors = ParseInt(worksheet.Cells[row, 14].Text),
                    AttackBlocks = ParseInt(worksheet.Cells[row, 15].Text),
                    AttackPoints = ParseInt(worksheet.Cells[row, 16].Text),
                    AttackPointPercent = ParseDecimal(worksheet.Cells[row, 17].Text),
                    BlockPoints = ParseInt(worksheet.Cells[row, 18].Text)
                });
            }
        }

        SaveToDatabase(stats);
    }
    private int ParseSetNumber(string cellValue)
    {
        if (string.IsNullOrWhiteSpace(cellValue)) return -1;
        return int.TryParse(cellValue.Replace("Партия", "").Trim(), out int result) ? result : -1;
    }

    private int ParseInt(string value) =>
    int.TryParse(value, NumberStyles.Any, CultureInfo.InvariantCulture, out int result) ? result : 0;

    private decimal ParseDecimal(string value) =>
        decimal.TryParse(value, NumberStyles.Any, CultureInfo.InvariantCulture, out decimal result) ? result : 0m;

    private void SaveToDatabase(IEnumerable<MatchStatsSet> stats)
    {
        using var connection = new SqlConnection(_connectionString);

        const string query = @"INSERT INTO [Volleyball_dwh].[stg_excel].[MatchStatsSets] (
            [FileName], [FolderName], [MatchDate], [TeamName], [SetNumber],
            [PointsOnServe], [PointsOnAttack], [PointsOnBlock], [PointsOnOpponentErrors],
            [TotalPoints], [ServeErrors], [ServePoints], [TotalReceptions],
            [ReceptionErrors], [PerfectReceptionPercent], [ExcellentReceptionPercent],
            [TotalAttacks], [AttackErrors], [AttackBlocks], [AttackPoints],
            [AttackPointPercent], [BlockPoints]
        ) VALUES (
            @FileName, @FolderName, @MatchDate, @TeamName, @SetNumber,
            @PointsOnServe, @PointsOnAttack, @PointsOnBlock, @PointsOnOpponentErrors,
            @TotalPoints, @ServeErrors, @ServePoints, @TotalReceptions,
            @ReceptionErrors, @PerfectReceptionPercent, @ExcellentReceptionPercent,
            @TotalAttacks, @AttackErrors, @AttackBlocks, @AttackPoints,
            @AttackPointPercent, @BlockPoints
        )";

        connection.Execute(query, stats);
    }
}
 