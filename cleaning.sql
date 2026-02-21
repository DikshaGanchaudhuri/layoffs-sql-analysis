SELECT COUNT(*) FROM layoffs;

SELECT * FROM layoffs;

SELECT * FROM layoffs_staging;

INSERT INTO layoffs_staging
SELECT * FROM layoffs;

SELECT *
FROM (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,date, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_staging
) duplicates
WHERE 
	row_num > 1;

SELECT * FROM layoffs_staging
WHERE row_num > 1;

DELETE FROM layoffs_staging
WHERE row_num > 1;

SELECT COUNT(DISTINCT company), COUNT(DISTINCT TRIM(company)) FROM layoffs_staging;

UPDATE layoffs_staging
SET company = TRIM(company);

SELECT DISTINCT industry FROM layoffs_staging ORDER BY industry;

UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT location FROM layoffs_staging ORDER BY location;

UPDATE layoffs_staging
SET location = CASE 
WHEN location = 'Dusseldorf' THEN 'Düsseldorf'
WHEN location = 'Malmo' THEN 'Malmö'
END
WHERE location IN ('Dusseldorf', 'Malmo');

SELECT DISTINCT country FROM layoffs_staging ORDER BY country;

UPDATE layoffs_staging
SET country = 'United States'
WHERE country LIKE 'United States%';

SELECT date FROM layoffs_staging;

UPDATE layoffs_staging
SET date = to_date(date, 'MM/DD/YYYY');

ALTER TABLE layoffs_staging
ALTER COLUMN date TYPE DATE USING date::DATE;

SELECT pg_typeof(date) FROM layoffs_staging;

SELECT * FROM layoffs_staging
WHERE industry IS NULL OR industry = '';

SELECT * FROM layoffs_staging
WHERE company IN ('Airbnb','Bally''s Interactive','Carvana','Juul');

SELECT LS1.company, LS1.industry, LS2.industry
FROM layoffs_staging LS1 JOIN layoffs_staging LS2
ON LS1.company = LS2.company AND LS1.location = LS2.location
WHERE LS1.industry = '' AND LS2.industry IS NOT NULL;

UPDATE layoffs_staging
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging ls1
SET industry = ls2.industry
FROM layoffs_staging ls2
WHERE ls1.company = ls2.company
  AND ls1.industry IS NULL
  AND ls2.industry IS NOT NULL;

SELECT * FROM layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL
ORDER BY country, location;

DELETE FROM layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging
DROP COLUMN row_num;