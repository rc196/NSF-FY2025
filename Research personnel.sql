select
s.business_unit, 
self.UC_SEX_DESCR_SELF,
CASE 
    WHEN b.empl_class in ('3','9','10','11','14','20','21','22','23','24') then 'RESEARCHERS'
    WHEN (cto.UC_CTO_OS_CD in ('E20','F10') or cto.UC_CTO_OS_CD like ('H%') or cto.UC_CTO_OS_CD like 'I%') then 'RD TECHNICIANS'
    ELSE 'RD SUPPORT STAFF'
END
AS Category,
sum(hours1) as hours,
count (distinct (case when b.job_indicator='P' then s.emplid else '' END)) as headcount
from
hcm_ods.ps_uc_ll_sal_dtl s 
inner JOIN hcm_ods.fdw_ll_map_cv m 
on  s.emplid=m.emplid and s.empl_rcd=m.empl_rcd and s.effdt=m.effdt and s.effseq=m.effseq
and s.run_id=m.run_id and s.uc_run_id_earn=m.uc_run_id_earn 
and s.business_unit=m.business_unit and s.off_cycle=m.off_cycle and s.erncd=m.erncd 
and s.journal_id=m.journal_id and s.journal_line=m.journal_line and s.jrnl_ln_ref=m.jrnl_ln_ref and s.uc_addl_seq=m.uc_addl_seq
and s.appl_jrnl_id='PAYROLL'
inner join HCM_ODS.PS_JOB b
on s.emplid=b.emplid
and s.empl_rcd=b.empl_rcd
and s.effdt=b.effdt
and s.effseq=b.effseq
inner join 
(select jobcode, uc_cto_os_cd from HCM_ODS.PS_UC_JOB_CODES job
where effdt= (select max(effdt) from HCM_ODS.PS_UC_JOB_CODES job1 where job.setid=job1.setid and job.jobcode=job1.jobcode)) cto
on b.jobcode=cto.jobcode
left join HCM_ODS.PS_UC_HR_SELF_ID self
on s.emplid=self.emplid
where
s.run_id between '2307' and '2406ZZZ'
and m.UC_FUNCTION_CD='44'
group by
  s.business_unit, 
  self.UC_SEX_DESCR_SELF,
CASE 
    WHEN b.empl_class in ('3','9','10','11','14','20','21','22','23','24') then 'RESEARCHERS'
    WHEN (cto.UC_CTO_OS_CD in ('E20','F10') or cto.UC_CTO_OS_CD like ('H%') or cto.UC_CTO_OS_CD like 'I%') then 'RD TECHNICIANS'
    ELSE 'RD SUPPORT STAFF'
END;