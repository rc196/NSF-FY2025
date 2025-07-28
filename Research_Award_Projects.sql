--This query calculates the project category share of research awards for a unique year/location/fed-nonfed combination.

SELECT
a.location,
a.federal_sponsorship,
a.project_category,
(1.000000000 * A.project_type_sum/B.campus_sum) AS project_category_share
FROM
	(
        SELECT 
        CASE 
                WHEN LOCATION_NAME='Agriculture And Natural Resources' then 'Office of the President' 
                WHEN LOCATION_NAME='Office Of The President' then 'Office of the President' 
                else LOCATION_NAME END
                AS location,
        CASE
                WHEN SPONSOR_CATEGORY_GROUP_NAME = 'FEDERAL' THEN 'Y'
                ELSE ''
        END AS federal_sponsorship,
        CASE PROJECT_TYPE_CODE
                WHEN '1' THEN 'BASIC'
                WHEN '2' THEN 'APPLIED'
                ELSE 'DEVELOPMENT'
        END AS project_category,
        sum(QUARTERLY_AWARD_AMOUNT) as project_type_sum
        FROM IRAP_BI.AWARD_DM
        WHERE
        UC_FISCAL_YEAR = 2024
        AND PROJECT_TYPE_CODE IN ('1','2','3','4','A')
        GROUP BY 
                CASE 
                WHEN LOCATION_NAME='Agriculture And Natural Resources' then 'Office of the President' 
                WHEN LOCATION_NAME='Office Of The President' then 'Office of the President' 
                else LOCATION_NAME END,
        CASE
                WHEN SPONSOR_CATEGORY_GROUP_NAME = 'FEDERAL' THEN 'Y'
                ELSE ''
        END,
        CASE PROJECT_TYPE_CODE
                WHEN '1' THEN 'BASIC'
                WHEN '2' THEN 'APPLIED'
                ELSE 'DEVELOPMENT'
        END
) A,
(
        SELECT 
        CASE 
                WHEN LOCATION_NAME='Agriculture And Natural Resources' then 'Office of the President' 
                WHEN LOCATION_NAME='Office Of The President' then 'Office of the President' 
                else LOCATION_NAME END
                AS location,
        CASE
                WHEN SPONSOR_CATEGORY_GROUP_NAME = 'FEDERAL' THEN 'Y'
                ELSE ''
        END AS federal_sponsorship,
        sum(QUARTERLY_AWARD_AMOUNT) as campus_sum
        FROM IRAP_BI.AWARD_DM

        WHERE
        UC_FISCAL_YEAR = 2024
        AND PROJECT_TYPE_CODE IN ('1','2','3','4','A')
                GROUP BY 
                CASE 
                WHEN LOCATION_NAME='Agriculture And Natural Resources' then 'Office of the President' 
                WHEN LOCATION_NAME='Office Of The President' then 'Office of the President' 
                else LOCATION_NAME END,
        CASE
                WHEN SPONSOR_CATEGORY_GROUP_NAME = 'FEDERAL' THEN 'Y'
                ELSE ''
        END
)  B
WHERE
A.location = B.location
AND A.federal_sponsorship = B.federal_sponsorship