# MLB Average Pitcher Value

This project estimates the fair market salary for a league-average MLB starting pitcher who consistently throws five innings per start across 30 starts (≈150 innings) in a season.
Using data from 2021–2025, the analysis identifies pitchers matching this workload, filters out statistical outliers, and merges manually collected salary information to estimate current market value.

## Project Summary

- Goal: Determine how much a team should pay for a pitcher who delivers consistent, league-average performance (≈4.25 ERA, ≈1.5 WAR, 150 IP).
- Data Sources:
  - Baseball-Reference (standard pitching stats)
  - Manually collected salary data (2021–2025 seasons)
- Methods:
  - Filtered pitchers with ≥30 GS and ≥5 IP per start
  - Focused on those throwing between 150–171 IP per year
  - Removed extreme performers via interquartile range (IQR) on WAR and ERA
  - Merged salary data and summarized performance metrics
- Key Findings:
  - Mean WAR: 1.49
  - Mean ERA: 4.26
  - Mean Salary: $9.28 M
  - Median Salary: $6.45 M
  - Projected 2025 market value: $10–12 M

## Conclusion

A one-year contract worth $10–12 million represents a fair and data-supported estimate for a pitcher guaranteed to throw five innings per start across 30 starts with league-average talent.

## Technologies Used

- R
- Excel
- Google Drive

## Next Steps

- Incorporate additional seasons (pre-2021) for long-term salary trend analysis
- Adjust for inflation and collective bargaining agreement (CBA) effects
- Expand model to predict salary using regression (WAR, IP, age as predictors)

## Author

Steven Martinez

Data Scientist | Sports Analytics Enthusiast

[LinkedIn](https://www.linkedin.com/in/steven-martinez-colon) | [GitHub](https://github.com/Steven-Martinez-Colon) | [Portfolio](https://steven-martinez-colon.github.io)

