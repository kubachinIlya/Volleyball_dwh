CREATE PARTITION SCHEME [ps_MatchStatsPlayersBySeason]
    AS PARTITION [pf_MatchStatsPlayersBySeason]
    TO ([PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY]);

