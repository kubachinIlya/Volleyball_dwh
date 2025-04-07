using Dapper;
using Data_Loader_c_sharp.Models;
using Microsoft.Data.SqlClient;

namespace Data_Loader_c_sharp.Repositories
{
    public class SqlServerStatsRepository : IStatsRepository
    {
        private readonly string _connectionString;

        public SqlServerStatsRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task SavePlayerStatsAsync(IEnumerable<Match_Stats_Players_General> stats)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.ExecuteAsync(
                "INSERT INTO PlayerStats (Name, MatchesPlayed, Kills) VALUES (@Name, @MatchesPlayed, @Kills)",
                stats);
        }
    }
}
