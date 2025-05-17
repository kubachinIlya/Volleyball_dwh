
namespace data_loader.Models
{
    public class MatchStatsSet
    {
        public string FileName { get; set; }
        public string FolderName { get; set; }
        public DateTime MatchDate { get; set; }
        public string TeamName { get; set; }
        public int SetNumber { get; set; }
        public int PointsOnServe { get; set; }
        public int PointsOnAttack { get; set; }
        public int PointsOnBlock { get; set; }
        public int PointsOnOpponentErrors { get; set; }
        public int TotalPoints { get; set; }
        public int ServeErrors { get; set; }
        public int ServePoints { get; set; }
        public int TotalReceptions { get; set; }
        public int ReceptionErrors { get; set; }
        public decimal PerfectReceptionPercent { get; set; }
        public decimal ExcellentReceptionPercent { get; set; }
        public int TotalAttacks { get; set; }
        public int AttackErrors { get; set; }
        public int AttackBlocks { get; set; }
        public int AttackPoints { get; set; }
        public decimal AttackPointPercent { get; set; }
        public int BlockPoints { get; set; }
    }

}
