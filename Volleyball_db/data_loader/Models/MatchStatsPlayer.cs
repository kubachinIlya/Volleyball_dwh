using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

public class MatchStatsPlayer
{
    public string FileName { get; set; }
    public string FolderName { get; set; }
    public DateTime MatchDate { get; set; }
    public string TeamName { get; set; }
    public int PlayerNumber { get; set; }
    public string PlayerName { get; set; }
    public int? Set1 { get; set; }
    public int? Set2 { get; set; }
    public int? Set3 { get; set; }
    public int? Set4 { get; set; }
    public int? Set5 { get; set; }
    public int TotalPoints { get; set; }
    public int BreakPoints { get; set; }
    public int ScoredLostPoints { get; set; }
    public int TotalServes { get; set; }
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
    public string ParentFolderName { get; set; }
}
