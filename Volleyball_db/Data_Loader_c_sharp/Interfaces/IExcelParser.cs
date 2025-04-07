using Data_Loader_c_sharp.Models;

namespace Data_Loader_c_sharp
{
    public interface IExcelParser
    {
        Task<IEnumerable<Match_Stats_Players_General>> ParsePlayerStats(string filePath);
    }
}
