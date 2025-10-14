-- DATA CLEANINNG IN SQL PROJECT (WORLD LAYOFFS)

--I cleaned the layoffs dataset using SQL by removing duplicates, filtering incomplete rows, standardizing text fields,
--and validating numerical and date values to ensure data accuracy before analysis.


select *
from layoffs;

-- 1. Remove duplicate
-- 2. Standardize data
-- 3. Null values or blank values
-- 4. Remove Any columns

 CREATE TABLE layoffs_staging
 Like layoffs;
 
 select *
 from layoffs_staging;
 
 insert into layoffs_staging
 select *
 from layoffs;
 
 -- we make a second table because we are about to make alot of changes so if we make a mistake, we need to have the raw data.
 
 -- Removing duplicates
 
 -- use ROW_NUM to match against each row and see if there are any duplicates
 
 with duplicate_cte as
 (
 select *,
 row_number() over( 
 partition by company, location, industry, total_laid_off, `date`, stage, country,funds_raised_millions) as row_num
 from layoffs_staging
 )
 select *
 from duplicate_cte
 where row_num > 1; -- to look for duplicates
 
 select * 
 from layoffs_staging
 where company = 'yahoo';  --  to check the companies that showed up as duplicates
 
-- to delete the duplicates with creae another table with the rownum column and delete all the duplicates since we cannot update a CTE

CREATE TABLE `layoffs_staging2` (
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

select *
from layoffs_staging2;

insert into layoffs_staging2
select *,
 row_number() over( 
 partition by company, location, industry, total_laid_off, `date`, stage, country,funds_raised_millions) as row_num
 from layoffs_staging;

select *
from layoffs_staging2
where row_num > 1;

delete
from layoffs_staging2
where row_num > 1;

select *
from layoffs_staging2;

-- will need to remove redundant column later which is rownum

-- Standardizing data

select company, (trim(company))
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);  -- this removed the space in the left of the column

select distinct industry
from layoffs_staging2
order by 1;  

select distinct industry
from layoffs_staging2;

update layoffs_staging2
set industry = 'Crypto'
where industry like 'crypto';  -- updated crypto industry that was recorded differently (cryptocurrency) but was the same. 

select distinct location
from layoffs_staging2
order by 1;

select distinct country
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where country like 'united states%';

select distinct  country , trim(trailing '.' from country)
from layoffs_staging2
order by 1;  

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'united states%'; -- remoed fullsop at the end from united states

select `date`,
str_to_date(`date`, '%m/%d/%Y') -- changes date format
from layoffs_staging2;

update layoffs_staging2
set date = str_to_date(`date`, '%m/%d/%Y');

ALTER table layoffs_staging2
modify column `date` date;  -- change data type to date from text

select `date`
from layoffs_staging2;

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

update layoffs_staging2
set industry = null
where industry = '';

select *
from layoffs_staging2
where industry is null
or industry = '';

select *
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where t1.industry is null or t1.industry = ''
and t2.industry is not null;  -- t1.industry is null and if you scroll over t2.industry is not null, table is a self join

select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where t1.industry is null or t1.industry = ''
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;


select * 
from layoffs_staging2
where company like 'airbnb';

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging2;

alter table layoffs_staging2
drop column row_num;
