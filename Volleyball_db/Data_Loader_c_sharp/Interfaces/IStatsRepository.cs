using Data_Loader_c_sharp.Models;

namespace Data_Loader_c_sharp
{
    public interface IStatsRepository
    {
        Task SavePlayerStatsAsync(IEnumerable<Match_Stats_Players_General> stats);
        // Добавьте другие методы для команд, турниров и т.д.
    }
}
