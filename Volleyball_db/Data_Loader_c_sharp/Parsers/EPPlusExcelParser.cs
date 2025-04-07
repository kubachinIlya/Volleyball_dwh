using Data_Loader_c_sharp.Models;
using OfficeOpenXml;

namespace Data_Loader_c_sharp.Parsers
{
    public class EPPlusExcelParser : IExcelParser
    {
        public async Task<IEnumerable<Match_Stats_Players_General>> ParsePlayerStats(string filePath)
        {
            var stats = new List<Match_Stats_Players_General>();

            using var package = new ExcelPackage(new FileInfo(filePath));
            var worksheet = package.Workbook.Worksheets[0];

            for (int row = 2; row <= worksheet.Dimension.End.Row; row++)
            {
                stats.Add(new Match_Stats_Players_General
                {
                    Name = worksheet.Cells[row, 1].GetValue<string>(),
                    MatchesPlayed = worksheet.Cells[row, 2].GetValue<int>(),
                    Kills = worksheet.Cells[row, 3].GetValue<int>()
                });
            }

            return stats;
        }
    }
}
