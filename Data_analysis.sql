
SELECT *
FROM layoffs_stagging2;

-- Top 5 industry per year with the most laid offs

SELECT industry, YEAR(`date`) AS years, 
SUM(total_laid_off) AS total_laid_off
FROM layoffs_stagging2
GROUP BY industry, years
ORDER BY years, total_laid_off DESC
;

WITH Industry_per_year AS
(SELECT industry, YEAR(`date`) AS years, 
SUM(total_laid_off) AS total_laid_off
FROM layoffs_stagging2
GROUP BY industry, years
ORDER BY years, total_laid_off DESC
), Ranking AS
(SELECT industry, total_laid_off, years,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Industry_per_year
WHERE years IS NOT NULL
)

SELECT *
FROM Ranking
WHERE ranking <= 5
;

-- Year nad month with most funds raised

WITH Date_of_raising_founds AS
(SELECT SUBSTRING(`date`, 1, 7) AS `year_month`, SUM(funds_raised_millions) AS funds_raised_mln
FROM layoffs_stagging2
GROUP BY `year_month` 
ORDER BY `year_month`
)
SELECT *
FROM Date_of_raising_founds
WHERE `year_month` IS NOT NULL
ORDER BY funds_raised_mln DESC
;

-- Company, year with funds raised and laid offs

SELECT company, YEAR(`date`) AS `year`, SUM(funds_raised_millions) AS cash
FROM layoffs_stagging2
GROUP BY company, `year`
ORDER BY cash DESC;

WITH table_cash AS
(SELECT company, YEAR(`date`) AS `year`, SUM(funds_raised_millions) AS cash_in_millions
FROM layoffs_stagging2
GROUP BY company, `year`
ORDER BY cash_in_millions DESC
), company_laid_off AS
(SELECT company, YEAR(`date`) AS years, 
SUM(total_laid_off) AS total_laid_off
FROM layoffs_stagging2
GROUP BY company, years
ORDER BY years, total_laid_off DESC
), combi AS
(SELECT tc.company, tc.`year`, clo.total_laid_off, tc.cash_in_millions
FROM table_cash tc
JOIN company_laid_off clo
	ON tc.company = clo.company
WHERE tc.`year` IS NOT NULL 
AND tc.cash_in_millions IS NOT NULL
AND clo.total_laid_off IS NOT NULL
ORDER BY tc.cash_in_millions DESC
)
SELECT company, `year`, cash_in_millions, SUM(total_laid_off) AS laid_offs
FROM combi
GROUP BY company, `year`, cash_in_millions
ORDER BY cash_in_millions DESC
;

-- Shorter version with null laid_offs

SELECT company, YEAR(`date`) AS `year`,
SUM(funds_raised_millions) AS cash,
SUM(total_laid_off) AS laid_offs
FROM layoffs_stagging2
GROUP BY company, `year`
HAVING `year` IS NOT NULL
AND cash IS NOT NULL
ORDER BY cash DESC;

--

