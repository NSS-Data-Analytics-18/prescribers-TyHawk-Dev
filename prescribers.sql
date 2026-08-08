SELECT 
	npi,
	nppes_provider_last_org_name,
	nppes_provider_first_name,
	specialty_description,
	SUM(total_claim_count) AS total_claims_by_prescriber
FROM prescriber INNER JOIN prescription USING (npi)
GROUP BY 
	npi, 
	nppes_provider_last_org_name,
	nppes_provider_first_name,
	specialty_description
ORDER BY total_claims_by_prescriber DESC;

--Question 1a: NPI - 1881634483, Total Claims - 99,707
--Question 1b: Name - Bruce Pendley, Specialty Description - Family Practice, Total Claims - 99,707

SELECT 
	specialty_description,
	SUM(total_claim_count) AS total_claims_per_specialty
FROM prescriber INNER JOIN prescription USING (npi)
GROUP BY
	specialty_description
ORDER BY total_claims_per_specialty DESC;

--Question 2a: Family Practice (9752347)

SELECT
	specialty_description
	, SUM(total_claim_count) AS total_opiod_claims_per_specialty
FROM prescriber
	INNER JOIN prescription ON prescriber.npi = prescription.npi
	INNER JOIN drug ON prescription.drug_name = drug.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY
	specialty_description
ORDER BY total_opiod_claims_per_specialty DESC;

--Question 2b: Nurse Practitioner (900845)

SELECT *
	-- specialty_description
	-- , drug_name
FROM prescriber
	RIGHT JOIN prescription ON prescriber.npi = prescription.npi;
--WHERE total_claim_count = '0'
-- GROUP BY 
	-- specialty_description
	-- , drug_name

--Question 2c: TBD
--Question 2d: TBD

SELECT
	generic_name
	, ROUND(total_drug_cost, 2) AS total_drug_cost
FROM drug
	INNER JOIN prescription ON drug.drug_name = prescription.drug_name
GROUP BY
	generic_name
	, total_drug_cost
ORDER BY total_drug_cost DESC;

--Question 3a: PIRFENIDONE has the highest total amount of 2,829,174.3. The individual cost (per claim) is 8,129.81, which is also the highest

SELECT
	generic_name
	, ROUND((total_drug_cost / total_claim_count / 30), 2) AS individual_daily_drug_cost
FROM drug
	INNER JOIN prescription ON drug.drug_name = prescription.drug_name
GROUP BY
	generic_name
	, individual_daily_drug_cost
ORDER BY individual_daily_drug_cost DESC;

--Question 3b: ASFOTASE ALFA has the highest cost per day for an individual 30 day refill (94,305.81). 

SELECT
	generic_name
	, ROUND((total_drug_cost / 30), 2) AS daily_total_drug_cost
FROM drug
	INNER JOIN prescription ON drug.drug_name = prescription.drug_name
GROUP BY
	generic_name
	, daily_total_drug_cost
ORDER BY daily_total_drug_cost DESC;

--Question 3b: In total, PIRFENIDONE has the highest total cost per day (94,305.81)

SELECT 
	drug_name,
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN long_acting_opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antiboitic'
		ELSE 'neither'
	END drug_type
FROM drug;

--Question 4a: Code above

--Question 4b:
