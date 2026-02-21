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