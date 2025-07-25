with a as
(
(select
effective_gl_date, 
amount, 
entity_level_a_code, 
entity_level_a_description, 
entity_level_b_code, 
entity_level_b_description, 
entity_level_c_code, 
entity_level_c_description, 
account_level_a_code, 
account_level_a_description, 
account_level_b_code, 
account_level_b_description, 
account_level_c_code, 
account_level_c_description, 
account_level_d_code, 
account_level_d_description, 
account_level_e_code, 
account_level_e_description, 
fund_level_a_code, 
fund_level_a_description, 
fund_level_b_code, 
fund_level_b_description, 
fund_level_c_code, 
fund_level_c_description, 
fund_level_d_code, 
fund_level_d_description, 
budgeted_flag, 
budgeted_type, 
department_level_a_code, 
department_level_a_description, 
department_level_b_code, 
department_level_b_description, 
department_level_c_code, 
department_level_c_description, 
department_level_d_code, 
department_level_d_description, 
department_level_e_code, 
department_level_e_description, 
department_type, 
department_type_description, 
function_id, 
function_description, 
program_level_a_code, 
program_level_a_description, 
program_level_b_code, 
program_level_b_description, 
project_id, 
project_description, 
sub_account, 
activity, 
financial_statement_acct_category, 
fiscal_year,
fund_id, 
--UCI and UCD sponsor codes are reversed between prime and direct. Check in FY2025 if this has been fixed.
trim(case 
      when entity_level_a_description in ('Santa Barbara','Irvine') and (prime_sponsor_id=direct_sponsor_id or prime_sponsor_id='') then c.orig_sponsor_code 
      when entity_level_a_description in ('Irvine') and sponsor_category_d!='14' then direct_sponsor_id 
      when entity_level_a_description in ('Davis') then direct_sponsor_id 
      else prime_sponsor_id 
      end) as prime_sponsor_id, 
CASE 
  when entity_level_a_description in ('Irvine') and sponsor_category_d!='14' then prime_sponsor_id
  when entity_level_a_description in ('Davis') then prime_sponsor_id
  else direct_sponsor_id
end as direct_sponsor_id, 
project_type, 
federal_flow_through_code, 
indirect_cost_base, 
indirect_cost_rate, 
on_campus_flag, 
research_and_development_flag, 
project_begin_date, 
project_end_date, 
a.award_id, 
award_description, 
award_type, 
award_active_flag, 
award_federal_arra_flag, 
nsf_id, 
nsf_description, 
spx_project_id, 
--UCI and UCD sponsor codes are reversed between prime and direct. Check in FY2025 if this has been fixed.
CASE 
  when entity_level_a_description in ('Irvine') and sponsor_category_d!='14' then sponsor_id_p
  when entity_level_a_description in ('Davis') then sponsor_id_p
  else sponsor_id_d
END as sponsor_id_d, 
CASE 
  when entity_level_a_description in ('Irvine') and sponsor_category_d!='14' then sponsor_description_p
  when entity_level_a_description in ('Davis') then sponsor_description_p
  else sponsor_description_d
END as sponsor_description_d,
CASE 
  when entity_level_a_description in ('Irvine') and sponsor_category_d!='14' then sponsor_category_p
  when entity_level_a_description in ('Davis') then sponsor_category_p
  else sponsor_category_d
  end as sponsor_category_d,
case 
  when
    (case
      when entity_level_a_description in ('Irvine') and sponsor_category_d!='14' then foreign_domestic_flag_p 
      when entity_level_a_description in ('Davis') then foreign_domestic_flag_p 
      else sponsor_foreign_domestic_flag_d
    end) in ('Y','F') then 'Y'
    else '' END
as sponsor_foreign_domestic_flag_d, 
--UCI sponsor codes are reversed between prime and direct. Check in FY2025 if this has been fixed.
trim(case 
      when entity_level_a_description in ('Santa Barbara','Irvine') and  (prime_sponsor_id=direct_sponsor_id or prime_sponsor_id='') then orig_sponsor_code
      when entity_level_a_description in ('Irvine') and sponsor_category_d!='14' then sponsor_id_d 
      when entity_level_a_description in ('Davis') then sponsor_id_d       
      else sponsor_id_p 
      end) as sponsor_id_p,
trim(case 
        when entity_level_a_description in ('Santa Barbara','Irvine') and (prime_sponsor_id=direct_sponsor_id or prime_sponsor_id='') then orig_sponsor_desc 
        when entity_level_a_description in ('Irvine') and sponsor_category_d!='14' then sponsor_description_d
        when entity_level_a_description in ('Davis') then sponsor_description_d
        else sponsor_description_p end) as sponsor_description_p, 
case 
  when entity_level_a_description in ('Santa Barbara','Irvine') and (prime_sponsor_id=direct_sponsor_id or prime_sponsor_id='') then orig_sponsor_cat_code 
  when entity_level_a_description in ('Irvine') and sponsor_category_d!='14' then sponsor_category_d
  when entity_level_a_description in ('Davis') then sponsor_category_d  
  else sponsor_category_p end as sponsor_category_p,
case 
  when 
  (case 
    when entity_level_a_description in ('Santa Barbara','Irvine') and (prime_sponsor_id=direct_sponsor_id or prime_sponsor_id='') then orig_sponsor_foreign 
    when entity_level_a_description in ('Irvine') and sponsor_category_d!='14' then sponsor_foreign_domestic_flag_d 
    when entity_level_a_description in ('Davis') then sponsor_foreign_domestic_flag_d 
    else foreign_domestic_flag_p 
    end) in ('Y','F')
  then 'Y'
  else ''
  end as foreign_domestic_flag_p,
accounting_period,
'All' as source,
'' as exclude_mtdc
from fdw_prod_warehouse.gl_balances_ex a 
left join
	ucop_irap.ucsb_prime c
	on a.award_id=c.award_id
	and a.entity_level_a_description=c.location
where accounting_period='2024YE')
UNION
(select
effective_gl_date, 
b.amount,
entity_level_a_code, 
entity_level_a_description, 
entity_level_b_code, 
entity_level_b_description, 
entity_level_c_code, 
entity_level_c_description, 
account_level_a_code, 
account_level_a_description, 
account_level_b_code, 
account_level_b_description, 
account_level_c_code, 
account_level_c_description, 
account_level_d_code, 
account_level_d_description, 
account_level_e_code, 
account_level_e_description, 
fund_level_a_code, 
fund_level_a_description, 
fund_level_b_code, 
fund_level_b_description, 
fund_level_c_code, 
fund_level_c_description, 
fund_level_d_code, 
fund_level_d_description, 
budgeted_flag, 
budgeted_type, 
department_level_a_code, 
department_level_a_description, 
department_level_b_code, 
department_level_b_description, 
department_level_c_code, 
department_level_c_description, 
department_level_d_code, 
department_level_d_description, 
department_level_e_code, 
department_level_e_description, 
department_type, 
department_type_description, 
b.function_id, 
function_description, 
program_level_a_code, 
program_level_a_description, 
program_level_b_code, 
program_level_b_description, 
a.project_id, 
project_description, 
sub_account, 
activity, 
financial_statement_acct_category, 
fiscal_year,
a.fund_id, 
prime_sponsor_id, 
direct_sponsor_id, 
project_type, 
federal_flow_through_code, 
indirect_cost_base, 
indirect_cost_rate, 
on_campus_flag, 
research_and_development_flag, 
project_begin_date, 
project_end_date, 
award_id, 
award_description, 
award_type, 
award_active_flag, 
award_federal_arra_flag, 
b.nsf_id, 
nsf_description, 
spx_project_id, 
sponsor_id_d, 
sponsor_description_d, 
sponsor_category_d,
sponsor_foreign_domestic_flag_d, 
sponsor_id_p,
sponsor_description_p, 
sponsor_category_p,
foreign_domestic_flag_p,
accounting_period,
'Merced' as source,
'' as exclude_mtdc
from fdw_prod_warehouse.gl_balances_ex a 
inner join
	ucop_irap.ucm_supp_fy2024 b
	on a.entity_level_c_code=b.entity_id AND
	a.account_level_e_code=b.account_id AND
	a.fund_level_d_code=b.fund_id AND
coalesce(nullif(department_level_e_code,''), nullif(department_level_d_code,''), nullif(department_level_c_code,''), nullif(department_level_b_code,''))=b.department_id AND
a.function_id=b.function_id AND
a.program_level_b_code=b.program_id and
	a.project_id=b.project_id 
where accounting_period='2024YE'
)
UNION
(SELECT 
null as effective_gl_date, 
amount,
null as entity_level_a_code, 
'San Diego' as entity_level_a_description, 
null as entity_level_b_code, 
null as entity_level_b_description, 
'1611' as entity_level_c_code, 
null as entity_level_c_description, 
account_level_a_code, 
null as account_level_a_description, 
account_level_b_code, 
null as account_level_b_description, 
account_level_c_code, 
null as account_level_c_description, 
account_level_d_code, 
null as account_level_d_description, 
null as account_level_e_code, 
null as account_level_e_description, 
fund_level_a_code, 
null as fund_level_a_description, 
fund_level_b_code, 
null as fund_level_b_description, 
fund_level_c_code, 
null as fund_level_c_description, 
fund_level_d_code, 
null as fund_level_d_description, 
null as budgeted_flag, 
null as budgeted_type, 
null as department_level_a_code, 
null as department_level_a_description, 
null as department_level_b_code, 
null as department_level_b_description, 
null as department_level_c_code, 
null as department_level_c_description, 
null as department_level_d_code, 
null as department_level_d_description, 
null as department_level_e_code, 
null as department_level_e_description, 
null as department_type, 
null as department_type_description, 
null as function_id, 
null as function_description, 
null as program_level_a_code, 
null as program_level_a_description, 
null as program_level_b_code, 
null as program_level_b_description, 
project_id, 
null as project_description, 
null as sub_account, 
null as activity, 
null as financial_statement_acct_category, 
2024 as fiscal_year,
null as fund_id, 
prime_sponsor_id, 
direct_sponsor_id, 
null as project_type, 
federal_flow_through_code, 
null as indirect_cost_base, 
null as indirect_cost_rate, 
on_campus_flag, 
null as research_and_development_flag, 
null as project_begin_date, 
null as project_end_date, 
null as award_id, 
null as award_description, 
null as award_type, 
null as award_active_flag, 
null as award_federal_arra_flag, 
nsf_id, 
null as nsf_description, 
null as spx_project_id, 
sponsor_id_d, 
sponsor_description_d, 
sponsor_category_d,
sponsor_foreign_domestic_flag_d, 
sponsor_id_p,
sponsor_description_p, 
sponsor_category_p,
foreign_domestic_flag_p,
'2024YE' as accounting_period,
'San Diego' as source,
exclude_mtdc
FROM "ucop_irap"."ucsd_supp" a
left join 
(select distinct sponsor_id_d, sponsor_description_d, sponsor_category_d, sponsor_foreign_domestic_flag_d, sponsor_id_p, sponsor_description_p, sponsor_category_p, foreign_domestic_flag_p, project_id as project_id_x, federal_flow_through_code, on_campus_flag,sponsor_id_p as prime_sponsor_id, sponsor_id_d as direct_sponsor_id 
from fdw_prod_warehouse.gl_balances_ex 
where entity_level_c_code='1611' 
and accounting_period='2024YE'
and financial_statement_acct_category='E') b
on a.project_id=b.project_id_x 
left join
(select distinct account_level_a_code, account_level_b_code, account_level_c_code, account_level_d_code as account_level_d_code
from fdw_prod_warehouse.gl_balances_ex  
where entity_level_c_code='1611' 
and accounting_period='2024YE'
and financial_statement_acct_category='E') c
on a.account_id=c.account_level_d_code
left join
(select distinct fund_level_a_code, fund_level_b_code, fund_level_c_code, fund_level_d_code as fund_level_d_code
from fdw_prod_warehouse.gl_balances_ex  
where entity_level_c_code='1611' 
and accounting_period='2024YE'
and financial_statement_acct_category='E') d
on a.fund_id=d.fund_level_d_code)
)

SELECT
	fiscal_year,
	entity_level_a_description AS location,
	entity_level_c_code,
	a.function_id,
	CASE
		WHEN 
		(entity_level_a_description='San Diego' and department_level_c_code='300200B') OR
		(entity_level_a_description='Los Angeles' and department_level_a_description like '%DGSOM%') OR
		(entity_level_a_description='San Francisco' and department_level_a_code='100000') OR
		(entity_level_a_description='Irvine' and department_level_a_code='9030A') OR
		(entity_level_a_description='Davis' and department_level_a_code='430000C') OR
		(entity_level_a_description='Riverside' and department_level_b_code='ORG40')
		THEN 'Y'
		ELSE 'N'
	END AS med_school,
	--Assign an NSF discipline for certain funds where they are known
	CASE
	  WHEN b.nsf_id<>'' then b.nsf_id
	  when d.nsf_id<>'' then d.nsf_id
	  WHEN (trim(a.nsf_id) ='' OR a.nsf_id = '999') THEN
			(CASE
			/* These are all special state appropriations funds*/
				WHEN fund_level_c_code IN ('18073C','18074C','18075C') THEN '013'
				WHEN fund_level_c_code IN ('18081C') THEN '032'
				WHEN fund_level_c_code IN ('2085C','2086C','2088C','2089C','2090C') THEN '051'
				WHEN fund_level_c_code IN ('18070C','18071C','18072C','18076C','18077C','18078C','18079C','18080C','18089C','18090C','18092C','18093C','18094C','18098C','18099C','18100C','18101C','18102C','18103C','18104C','18105C','18106C','18107C','18108C','18109C','18110C','18111C','18112C','18113C','18114C','18115C','18116C','18117C','18118C','18119C','18120C','18121C','18122C','18123C','18127C') THEN '053'
				WHEN fund_level_c_code IN ('18091C','2087C','2092C') THEN '055'
				WHEN fund_level_c_code IN ('18083C','18084C','18085C','18087C') THEN '510'
				WHEN fund_level_c_code IN ('18082C') THEN '530'
			/*Federal Appropriations - Expanded Food and Nutrition Program (EFNEP)*/
				WHEN fund_level_c_code IN ('2091C') THEN '540'
				END)
		ELSE a.nsf_id
	END as nsf_id,
--Assign a funding category based on fund, then sponsor category. Per NSF guidelines, we first look at the prime (p) sponsor, then the direct (d) sponsor
CASE
  WHEN federal_flow_through_code IN ('2','3','6','7') THEN 'FEDERAL_UNCLASSIFIED'
	WHEN fund_level_b_code IN ('2085B') OR fund_level_c_code IN ('2000C') THEN 'FEDERAL_UNCLASSIFIED'
	WHEN fund_level_b_code IN ('1800B') OR fund_level_c_code IN ('2040C') THEN 'GOVERNMENT_STATE/LOCAL'
	WHEN     
	    (CASE
            WHEN foreign_domestic_flag_p not in (' ','') THEN foreign_domestic_flag_p
            ELSE sponsor_foreign_domestic_flag_d
        END) = 'Y' AND fund_level_c_code IN ('2070C') THEN
			CASE 	
				(CASE
            		WHEN sponsor_category_p <>'' THEN sponsor_category_p
            		ELSE sponsor_category_d
            	END)
					WHEN '03' THEN 'GOVERNMENT_FOREIGN'
					WHEN '04' THEN 'BUSINESS_FOREIGN'
					WHEN '05' THEN 'NONPROFIT_FOREIGN'
					WHEN '06' THEN 'NONPROFIT_FOREIGN'
					WHEN '07' THEN 'NONPROFIT_FOREIGN'
					WHEN '08' THEN 'HIGHER_EDUCATION_FOREIGN'
					WHEN '09' THEN 'NONPROFIT_FOREIGN'
					ELSE 'OTHER_FOREIGN'
				END
  WHEN fund_level_c_code IN ('2070C') THEN 
        CASE 	
            (CASE
             		WHEN sponsor_category_p <>'' THEN sponsor_category_p
            		ELSE sponsor_category_d
        	    END)
        	    WHEN '02' then 'GOVERNMENT_STATE/LOCAL'
        	    WHEN '03' then 'GOVERNMENT_STATE/LOCAL'
							WHEN '04' THEN 'BUSINESS_USA'
							WHEN '05' THEN 'NONPROFIT_USA'
							WHEN '06' THEN 'NONPROFIT_USA'
							WHEN '07' THEN 'NONPROFIT_USA'
							WHEN '08' THEN 'HIGHER_EDUCATION_USA'
							WHEN '09' THEN 'NONPROFIT_USA'							
							ELSE 'OTHER_USA'
		    END
	WHEN fund_level_b_code IN ('2200B') THEN 'OTHER_USA'
		ELSE 'INSTITUTIONAL'
	END AS funding_source,
    fund_level_b_code, 
    fund_level_b_description,
    fund_level_c_code,
    fund_level_c_description,
--    fund_level_d_code,
--    fund_level_d_description,
    account_level_a_code,
    account_level_a_description,
    account_level_b_code,
    account_level_b_description,
    account_level_c_code,
    account_level_c_description,
--    account_level_d_code,
--    account_level_d_description,
--    account_level_e_code,
--    account_level_e_description,
    coalesce(nullif(department_level_e_code,''), nullif(department_level_d_code,''), nullif(department_level_c_code,''), nullif(department_level_b_code,''),nullif(department_level_a_code,'')) as department_id,
    coalesce(nullif(department_level_e_description,''), nullif(department_level_d_description,''), nullif(department_level_c_description,''), nullif(department_level_b_description,''), nullif(department_level_a_description,'')) as department_desc,
	--Use prime sponsor if it exists, else use direct sponsor
	CASE
		WHEN sponsor_id_p <>'' THEN sponsor_id_p 
		ELSE sponsor_id_d
	END AS sponsor_id,
	sponsor_id_p,
	sponsor_id_d,
	sponsor_description_p,
	sponsor_description_d,
	sponsor_category_p,
	sponsor_category_d,
	CASE
		WHEN sponsor_description_p <>'' THEN sponsor_description_p
		ELSE sponsor_description_d
	END AS sponsor_description,			
	(CASE
		WHEN sponsor_category_p <>'' THEN sponsor_category_p
		ELSE sponsor_category_d
	END) AS sponsor_category,
		CASE
		WHEN foreign_domestic_flag_p not in (' ','') THEN foreign_domestic_flag_p
		ELSE sponsor_foreign_domestic_flag_d
	END AS foreign_flag,
	--Categorizing funds that UC received via an intermediary pass-through entity
	CASE
	  	  WHEN sponsor_id_p<>'' and sponsor_id_p<>sponsor_id_d THEN 'Y' else 'N' 
	END AS pass_through_flag,
	  	  
	    CASE
    		WHEN sponsor_category_d = '08' THEN 'HIGHER EDUCATION'
    		WHEN sponsor_category_d = '04' THEN 'BUSINESS'
    		WHEN sponsor_category_d  IN ('05','06','07','09') THEN 'NONPROFIT'
    		--Federal sponsors do not pass-through, so the following are NONE
    		WHEN sponsor_category_d  IN ('01','13','99') THEN 'NONE'
    		WHEN (sponsor_category_d IS NULL OR sponsor_category_d='') THEN 'NONE'
    		ELSE 'OTHER'
	END AS pass_through_entity,
	award_id,
	award_description,
	a.project_id,
	project_description,
	CASE
		WHEN award_type = '2' THEN 'CONTRACTS'
		ELSE 'GRANTS/OTHER'
	END AS nsf_award_type,
	CASE on_campus_flag
		WHEN 'Y' THEN '1'
		WHEN 'N' THEN '2'
		ELSE '1'
	END AS on_off_campus,
	CASE
		WHEN account_level_c_code IN ('53810C','53800C') THEN 'RECOVERED_INDIRECT_COSTS'
		WHEN account_level_a_code IN ('50000A','50500A','50600A','50700A','51000A') THEN 'LABOR'
		WHEN account_level_c_code IN ('52600C') THEN 'CAPITALIZED_SOFTWARE'
		WHEN account_level_c_code IN ('52590C') THEN 'CAPITALIZED_EQUIPMENT'
		WHEN account_level_b_code IN ('53300B','40840B') THEN 'PASS_THROUGHS'
		ELSE 'OTHER_DIRECT_COSTS'
	END AS nsf_cost_type,
	sum(CASE
		WHEN account_level_c_code IN ('53810C','53800C') THEN 0 --facilities & administration reimbursements
		ELSE amount 
	END) AS direct,
	sum(CASE
	  WHEN exclude_mtdc='Y' then 0 --UCSD recharge debits
		WHEN account_level_c_code IN ('53810C','53800C') THEN 0 --facilities & administration reimbursements
		WHEN account_level_a_code IN ('51000A', '55000A') THEN 0 --financial aid & scholarships, utilities
		WHEN account_level_b_code IN ('50200B','50810B','52000B','53500B') THEN 0 --medical salaries, local benefit programs, health supplies & pharmaceuticals, medical professional fees  
		WHEN account_level_c_code in ('50700C','53210C','53230C','52590C','52600C','53210C','53230C','53310C','53800C') THEN 0 --group health insurance, building leases, repairs & maintenance, capitalized equipment, capitalized software, building leases, repairs & maintenance, subcontracts > $25K, facilities & administration reimbursements
		ELSE amount
	END) AS mtdc,
	sum(CASE
		WHEN account_level_c_code IN ('53800C') THEN amount
		when account_level_c_code IN ('53810C') AND entity_level_a_description='Santa Cruz' THEN amount --facilities & administration reimbursements
		ELSE 0
	END) AS reimbursement,
	CASE 
	  when a.source IN ('Merced','San Diego') then 'Y'
	  when b.entity_id <> '' then 'Y'
	  when c.entity_id <> '' then 'Y'
	  when d.location_code <> '' then 'Y'
	  else 'N'
	END AS supplemental_flag
	
FROM
	a
LEFT JOIN
	ucop_irap.nsf_supp_fy2024 b
  	on 
        a.entity_level_c_code=b.entity_id AND
        a.account_level_e_code=b.account_id AND
        a.fund_level_d_code=b.fund_id AND
        coalesce(nullif(department_level_e_code,''), nullif(department_level_d_code,''), nullif(department_level_c_code,''), nullif(department_level_b_code,''))=b.department_id AND
    	a.function_id=b.function_id AND
    	(CASE when a.entity_level_a_description in ('Irvine') then '' else 
    	a.project_id
    	END)=
    	(CASE when b.entity_id in ('1911') then '' else b.project_id END) AND
    	(CASE when a.entity_level_a_description in ('Irvine') then '' else a.program_level_b_code end)=
    	(CASE when b.entity_id in ('1911') then '' else b.program_id end)

--Supplemental for UCSF only, just based on project code
LEFT JOIN
  (select * from ucop_irap.nsf_supp_fy2024 where entity_id='1211') c
    on
      a.entity_level_c_code=c.entity_id AND
    	a.project_id=c.project_id 

LEFT JOIN
ucop_irap.ucla_supp d
on
substr(a.project_description,1,6)=d.account and 
case
    WHEN substr(a.project_description,13,1)='/' then substr(a.project_description,8,5)
    ELSE substr(a.project_description,11,5)
end=d.fund

WHERE
accounting_period = '2024YE'
AND entity_level_a_description in ('Berkeley')
AND 
(
    (
      (
      (a.function_id = '44' OR c.entity_id<> '' OR (entity_level_a_description = 'San Diego' AND fund_level_c_code IN ('2000C','2040C','2070C')))
    	AND financial_statement_acct_category = 'E'
    	AND NOT fund_level_b_code IN ('2400B','2600B','2630B','3000B','3100B','3200B','4000B','5000B') --exclude debt service, restricted unexpendable funds, net investment in capital, custodial funds
      	AND
    		(
    			account_level_a_code IN ('50000A','50500A','50600A','50700A','51000A','53000A','55000A') --labor compensation, other operating expenses, utilities
    			OR account_level_b_code IN ('52000B','52200B') --supplies
    			OR account_level_c_code IN ('52590C','52600C','52620C','52630C','52640C') --capitalized equipment, capitalized software, capitalized intangibles, capitalized libraries and collections, capitalized special collections
    		)
    	AND NOT
    		(
    			account_level_b_code IN ('50450B','50610B','50850B','52400B','53700B') --exclude eliminations, actuarial adjustment, impairment of capital assets
    			OR account_level_c_code IN ('50520C','52200C','52210C','52270C','53040C','53200C','53810C','53920C') -- exclude actuarial adjustment, food & beverage supplies, bookstore resales, federally-unchargeable subscriptions & memberships, federally-unchargeable advertising, facilities construction, facilities & administration offsets, royalties
		)
		) 
		OR a.source IN ('Merced','San Diego')
		OR b.entity_id <> ''
		OR (d.location_code <> '' 
		      and financial_statement_acct_category in ('E','R'))
		--This line below would include all intercampus transfers
		--OR (a.function_id='44' and (account_level_d_code like '7250%' or account_level_d_code like '7251%') AND NOT fund_level_b_code IN ('2400B','2600B','2630B','3000B','3100B','3200B','4000B','5000B'))
		)
	--Added to account for anomalous IDC recording at these campuses
	OR (entity_level_a_description='Berkeley' AND financial_statement_acct_category='E' AND account_level_c_code='53800C' AND a.function_id='80' AND a.project_id<>'')
	OR (entity_level_a_description='Riverside' AND financial_statement_acct_category='E' AND account_level_c_code='53800C' AND a.function_id='80' AND a.project_id<>'0000000000')
	OR (entity_level_a_description='Santa Cruz' AND financial_statement_acct_category='E' AND account_level_c_code='53810C' AND a.function_id='44')
    )
GROUP BY
fiscal_year,
accounting_period,
entity_level_a_description,
entity_level_c_code,
a.function_id,
CASE
	WHEN 
	(entity_level_a_description='San Diego' and department_level_c_code='300200B') OR
	(entity_level_a_description='Los Angeles' and department_level_a_description like '%DGSOM%') OR
	(entity_level_a_description='San Francisco' and department_level_a_code='100000') OR
	(entity_level_a_description='Irvine' and department_level_a_code='9030A') OR
	(entity_level_a_description='Davis' and department_level_a_code='430000C') OR
	(entity_level_a_description='Riverside' and department_level_b_code='ORG40')
	THEN 'Y'
	ELSE 'N'
END,
	CASE
	  WHEN b.nsf_id<>'' then b.nsf_id
	  when d.nsf_id<>'' then d.nsf_id
	  WHEN (trim(a.nsf_id) ='' OR a.nsf_id = '999') THEN
			(CASE
			/* These are all special state appropriations funds*/
				WHEN fund_level_c_code IN ('18073C','18074C','18075C') THEN '013'
				WHEN fund_level_c_code IN ('18081C') THEN '032'
				WHEN fund_level_c_code IN ('2085C','2086C','2088C','2089C','2090C') THEN '051'
				WHEN fund_level_c_code IN ('18070C','18071C','18072C','18076C','18077C','18078C','18079C','18080C','18089C','18090C','18092C','18093C','18094C','18098C','18099C','18100C','18101C','18102C','18103C','18104C','18105C','18106C','18107C','18108C','18109C','18110C','18111C','18112C','18113C','18114C','18115C','18116C','18117C','18118C','18119C','18120C','18121C','18122C','18123C','18127C') THEN '053'
				WHEN fund_level_c_code IN ('18091C','2087C','2092C') THEN '055'
				WHEN fund_level_c_code IN ('18083C','18084C','18085C','18087C') THEN '510'
				WHEN fund_level_c_code IN ('18082C') THEN '530'
			/*Federal Appropriations - Expanded Food and Nutrition Program (EFNEP)*/
				WHEN fund_level_c_code IN ('2091C') THEN '540'
				END)
		ELSE a.nsf_id
	END,
CASE
  WHEN federal_flow_through_code IN ('2','3','6','7') THEN 'FEDERAL_UNCLASSIFIED'
	WHEN fund_level_b_code IN ('2085B') OR fund_level_c_code IN ('2000C') THEN 'FEDERAL_UNCLASSIFIED'
	WHEN fund_level_b_code IN ('1800B') OR fund_level_c_code IN ('2040C') THEN 'GOVERNMENT_STATE/LOCAL'
	WHEN     
	    (CASE
            WHEN foreign_domestic_flag_p not in (' ','') THEN foreign_domestic_flag_p
            ELSE sponsor_foreign_domestic_flag_d
        END) = 'Y' AND fund_level_c_code IN ('2070C') THEN
			CASE 	
				(CASE
            		WHEN sponsor_category_p <>'' THEN sponsor_category_p
            		ELSE sponsor_category_d
            	END)
					WHEN '03' THEN 'GOVERNMENT_FOREIGN'
					WHEN '04' THEN 'BUSINESS_FOREIGN'
					WHEN '05' THEN 'NONPROFIT_FOREIGN'
					WHEN '06' THEN 'NONPROFIT_FOREIGN'
					WHEN '07' THEN 'NONPROFIT_FOREIGN'
					WHEN '08' THEN 'HIGHER_EDUCATION_FOREIGN'
					WHEN '09' THEN 'NONPROFIT_FOREIGN'
					ELSE 'OTHER_FOREIGN'
				END
  WHEN fund_level_c_code IN ('2070C') THEN 
        CASE 	
            (CASE
             		WHEN sponsor_category_p <>'' THEN sponsor_category_p
            		ELSE sponsor_category_d
        	    END)
        	    WHEN '02' then 'GOVERNMENT_STATE/LOCAL'
        	    WHEN '03' then 'GOVERNMENT_STATE/LOCAL'
							WHEN '04' THEN 'BUSINESS_USA'
							WHEN '05' THEN 'NONPROFIT_USA'
							WHEN '06' THEN 'NONPROFIT_USA'
							WHEN '07' THEN 'NONPROFIT_USA'
							WHEN '08' THEN 'HIGHER_EDUCATION_USA'
							WHEN '09' THEN 'NONPROFIT_USA'							
							ELSE 'OTHER_USA'
		    END
	WHEN fund_level_b_code IN ('2200B') THEN 'OTHER_USA'
		ELSE 'INSTITUTIONAL'
	END,
fund_level_b_code, 
fund_level_b_description,
fund_level_c_code,
fund_level_c_description,
--fund_level_d_code,
--fund_level_d_description,
account_level_a_code,
account_level_a_description,
account_level_b_code,
account_level_b_description,
account_level_c_code,
account_level_c_description,
--account_level_d_code,
--account_level_d_description,
--account_level_e_code,
--account_level_e_description,
    coalesce(nullif(department_level_e_code,''), nullif(department_level_d_code,''), nullif(department_level_c_code,''), nullif(department_level_b_code,''),nullif(department_level_a_code,'')),
    coalesce(nullif(department_level_e_description,''), nullif(department_level_d_description,''), nullif(department_level_c_description,''), nullif(department_level_b_description,''), nullif(department_level_a_description,'')),
   CASE
	WHEN sponsor_id_p <>'' THEN sponsor_id_p 
	ELSE sponsor_id_d
END,
	sponsor_id_p,
	sponsor_id_d,
	sponsor_description_p,
	sponsor_description_d,
	sponsor_category_p,
	sponsor_category_d,
CASE
	WHEN sponsor_description_p <>'' THEN sponsor_description_p
	ELSE sponsor_description_d
END,			
CASE
	WHEN sponsor_category_p <>'' THEN sponsor_category_p
	ELSE sponsor_category_d
END,
CASE
    WHEN  foreign_domestic_flag_p not in (' ','') THEN foreign_domestic_flag_p
    ELSE sponsor_foreign_domestic_flag_d
END,
	CASE
	  	  WHEN sponsor_id_p<>'' and sponsor_id_p<>sponsor_id_d THEN 'Y' else 'N' 
	END,
	    CASE
    		WHEN sponsor_category_d in ('08','14') THEN 'HIGHER EDUCATION'
    		WHEN sponsor_category_d = '04' THEN 'BUSINESS'
    		WHEN sponsor_category_d  IN ('05','06','07','09') THEN 'NONPROFIT'
    		--Federal sponsors do not pass-through, so the following are NONE
    		WHEN sponsor_category_d  IN ('01','13','99') THEN 'NONE'
    		WHEN (sponsor_category_d IS NULL OR sponsor_category_d='') THEN 'NONE'
    		ELSE 'OTHER'
	END,
award_id,
award_description,
a.project_id,
project_description,
CASE
	WHEN award_type = '2' THEN 'CONTRACTS'
	ELSE 'GRANTS/OTHER'
END,
CASE on_campus_flag
	WHEN 'Y' THEN '1'
	WHEN 'N' THEN '2'
	ELSE '1'
END,
CASE
	WHEN account_level_c_code IN ('53800C') THEN 'RECOVERED_INDIRECT_COSTS'
	WHEN account_level_a_code IN ('50000A','50500A','50600A','50700A','51000A') THEN 'LABOR'
	WHEN account_level_c_code IN ('52600C') THEN 'CAPITALIZED_SOFTWARE'
	WHEN account_level_c_code IN ('52590C') THEN 'CAPITALIZED_EQUIPMENT'
	WHEN account_level_b_code IN ('53300B') THEN 'PASS_THROUGHS'
	ELSE 'OTHER_DIRECT_COSTS'
END,
	CASE 
		  when a.source IN ('Merced','San Diego') then 'Y'
	  when b.entity_id <> '' then 'Y'
	  when c.entity_id <> '' then 'Y'
	  when d.location_code <> '' then 'Y'
	  else 'N'
	END

