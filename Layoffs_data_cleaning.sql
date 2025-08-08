
SELECT *
FROM layoffs;

-- Cleaning and organizing date

CREATE TABLE layoffs_stagging
LIKE layoffs;

INSERT layoffs_stagging
SELECT *
FROM layoffs;

-- Finding duplicats

WITH duplicat_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_stagging
)
SELECT *
FROM duplicat_cte
WHERE row_num > 1
;

SELECT *
FROM layoffs_stagging
WHERE company = 'Cazoo';

-- Creating a table for cleaning with marked duplicats

CREATE TABLE `layoffs_stagging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_stagging2
WHERE row_num > 1;

INSERT INTO layoffs_stagging2
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_stagging);

-- Deleting duplicats

DELETE
FROM layoffs_stagging2
WHERE row_num > 1;

-- Trim 

UPDATE layoffs_stagging2
SET company = TRIM(company);

-- Changing misspelling

SELECT *
FROM layoffs_stagging2
WHERE industry LIKE 'Crypto%';


UPDATE layoffs_stagging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_stagging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country like 'United States%';

SELECT DISTINCT country
FROM layoffs_stagging2
ORDER BY 1;

-- Modifying type of data 

UPDATE layoffs_stagging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_stagging2;

ALTER TABLE layoffs_stagging2
MODIFY COLUMN `date` DATE;

-- Filling null place

SELECT *
FROM layoffs_stagging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_stagging2
WHERE company = 'Juul';

UPDATE layoffs_stagging2
SET industry = NULL
WHERE industry = '';

SELECT t1.company, t1.industry, t2.company, t2.industry
FROM layoffs_stagging2 t1
JOIN layoffs_stagging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_stagging2 t1
JOIN layoffs_stagging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry iS NOT NULL;

SELECT *
FROM layoffs_stagging2
;

-- Removing unhelpful and unessecery rows and column

DELETE
FROM layoffs_stagging2
WHERE industry IS NULL;

DELETE
FROM layoffs_stagging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_stagging2
DROP COLUMN `row_num`;


