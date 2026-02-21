CREATE TABLE layoffs_staging (LIKE layoffs INCLUDING ALL);

INSERT INTO layoffs_staging
SELECT * FROM layoffs;

ALTER TABLE layoffs_staging
ADD COLUMN row_num INTEGER;

UPDATE layoffs_staging t
SET row_num = sub.row_num
FROM (
    SELECT 
        ctid,
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off,
                         percentage_laid_off, date, stage, country, funds_raised_millions
            ORDER BY date
        ) AS row_num
    FROM layoffs_staging
) sub
WHERE t.ctid = sub.ctid;