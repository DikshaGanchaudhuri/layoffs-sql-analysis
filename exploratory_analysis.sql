SELECT MAX(total_laid_off) FROM layoffs_staging;

SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM layoffs_staging
WHERE  percentage_laid_off IS NOT NULL;

SELECT *
FROM layoffs_staging
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

SELECT MIN(date), MAX(date) FROM layoffs_staging;

SELECT company, SUM(total_laid_off), EXTRACT(YEAR FROM date) AS year
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL AND EXTRACT(YEAR FROM date) = 2021
GROUP BY company, year
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
GROUP BY country
ORDER BY 2 DESC;

SELECT EXTRACT(YEAR FROM date) AS year, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY 2 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY stage
ORDER BY 2 DESC;

WITH date_cte AS (
    SELECT 
        DATE_TRUNC('month', date) AS month,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging
    GROUP BY month
)
SELECT 
    TO_CHAR(month, 'YYYY-MM') AS month, total_laid_off,
    SUM(total_laid_off) OVER (ORDER BY month) AS rolling_total_layoffs
FROM date_cte
ORDER BY month;

SELECT *
FROM (
    SELECT 
        company,
        EXTRACT(YEAR FROM date) AS year,
        SUM(total_laid_off) AS total_laid_off,
        DENSE_RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM date)
            ORDER BY SUM(total_laid_off) DESC
        ) AS ranking
    FROM layoffs_staging
    WHERE total_laid_off IS NOT NULL
    GROUP BY company, EXTRACT(YEAR FROM date)
) sub
WHERE ranking <= 3
ORDER BY year ASC, total_laid_off DESC;