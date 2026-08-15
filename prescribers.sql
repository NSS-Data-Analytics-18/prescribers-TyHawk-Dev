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

SELECT 
	specialty_description,
	SUM(total_claim_count) AS total_claim_count
FROM prescriber
	LEFT JOIN prescription ON prescriber.npi = prescription.npi
GROUP BY 
	specialty_description
ORDER BY total_claim_count DESC;

--Question 2c: 15 specialty_descriptions with no claims

SELECT
	specialty_description,
	SUM(total_claim_count) AS total_claim_count,
	SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count ELSE 0 END) AS opioid_claim_count,
	ROUND(SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count ELSE 0 END) / SUM(total_claim_count) * 100, 2) AS opioid_percentage_of_claims
FROM prescriber
	INNER JOIN prescription USING (npi)
	INNER JOIN drug USING (drug_name)
GROUP BY 
	specialty_description
ORDER BY opioid_percentage_of_claims DESC;

--Question 2d: Sheeeeeesh. It was unintuitive to wrap the division aspect in SUM once again to make it work. That said, I learned that this is because using an ALIAS that you already established earlier in the SELECT statement doesn't work. You essentially have to re-write the calculation within your division computation.

SELECT
	generic_name
	, ROUND(total_drug_cost, 2) AS total_drug_cost
FROM drug
	INNER JOIN prescription ON drug.drug_name = prescription.drug_name
GROUP BY
	generic_name
	, total_drug_cost
ORDER BY total_drug_cost DESC;

--Question 3a: PIRFENIDONE has the highest total amount of 2,829,174.3. The individual cost (per claim) is 8,129.81, which is also the highest.

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

--Question 3b: In total, PIRFENIDONE has the highest total cost per day (94,305.81).

SELECT 
	drug_name,
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN long_acting_opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antiboitic'
		ELSE 'neither'
	END drug_type
FROM drug;

--Question 4a: Query above
--Later in the assignment, I realized that including the long_acting_opioid_drug_flag was unncessary because anything flagged as such was always a 'Y' in the opioid_drug_flag column as well.

SELECT 
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN long_acting_opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antiboitic'
		ELSE 'neither'
	END drug_type,
	SUM(total_drug_cost)::money AS drug_type_cost
FROM drug
	INNER JOIN prescription ON drug.drug_name = prescription.drug_name
GROUP BY
	drug_type,
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN long_acting_opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antiboitic'
		ELSE 'neither'
	END;

--Question 4b: More was spent on opioids ($105,080,626.37) compared to antibiotics ($34,972,135.84).

SELECT COUNT(cbsa) AS cbsa_TN_total
FROM cbsa
	INNER JOIN fips_county USING (fipscounty)
WHERE state = 'TN';

--Question 5a: 42 CBSAs in TN

SELECT cbsa, cbsaname, SUM(population) AS total_population
FROM cbsa
	INNER JOIN fips_county USING (fipscounty)
	INNER JOIN population USING (fipscounty)
GROUP BY 
	cbsa.cbsa,
	cbsa.cbsaname
ORDER BY total_population DESC;

--Question 5b: Nashville-Davidson--Murfreesboro--Franklin, TN has the highest population (1,830,410) and Morristown, TN has the smallest population (116352)

SELECT county, SUM(population) AS total_population
FROM population
	FULL JOIN fips_county USING (fipscounty)
	FULL JOIN cbsa USING (fipscounty)
WHERE cbsa IS NULL
GROUP BY 
	fips_county.county
ORDER BY total_population DESC NULLS LAST;

--Question 5c: Sevier County has the largest population which is not included in a CBSA (95,523).

SELECT *
FROM prescription
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;

--Question 6a: This query returns all rows with 3k+ total claims from the prescribers table

SELECT drug_name, SUM(total_claim_count) AS total_claim_count
FROM prescription
WHERE total_claim_count >= 3000
GROUP BY drug_name, total_claim_count
ORDER BY total_claim_count DESC;

--Question 6a: Slightly cleaned up version here. There are 9 drugs with over 3k claims and OXYCODONE HCL has the highest (4538), but LEVOTHYROXINE SODIUM is listed twice w/ different values (because of different NPIs). 

SELECT drug_name, SUM(total_claim_count) AS total_claim_count
FROM prescription
WHERE total_claim_count >= 3000
GROUP BY drug_name
ORDER BY total_claim_count DESC;

--Question 6a (Cont.): If you want to look at just drugs and their claims, regardless of NPI, then you have 7 drugs w/ LEVOTHYROXINE SODIUM being the highest (9262)

SELECT
	drug_name, 
	SUM(total_claim_count) AS total_claim_count,
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'Y'
		WHEN long_acting_opioid_drug_flag = 'Y' THEN 'Y'
		ELSE 'N'
	END opioid
FROM prescription
	INNER JOIN drug USING (drug_name)
WHERE total_claim_count >= 3000
GROUP BY drug_name, opioid_drug_flag, long_acting_opioid_drug_flag
ORDER BY total_claim_count DESC;

--Question 6b: Query above. 2 are opioids and 5 are not. I stuck with the drug grouping here because listing the same drug twice would be redundant if you only cared about whether it was an opioid or not.

SELECT
	prescriber.nppes_provider_first_name,
	prescriber.nppes_provider_last_org_name,
	drug_name,
	total_claim_count,
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'Y'
		WHEN long_acting_opioid_drug_flag = 'Y' THEN 'Y'
		ELSE 'N'
	END opioid
FROM prescription
	INNER JOIN drug USING (drug_name)
	INNER JOIN prescriber USING (npi)
WHERE total_claim_count >= 3000;

--Question 6c: Query above. This time including duplicate drugs because now we care about who the prescriber is for each drug, rather than drugs in general.

SELECT 
	prescriber.npi,
	drug.drug_name
FROM prescriber
	CROSS JOIN drug
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y';

--Question 7a: Query above showing all NPIs & Drug Name combinations

SELECT 
	prescriber.npi,
	drug.drug_name,
	total_claim_count
FROM prescriber
	CROSS JOIN drug
	LEFT JOIN prescription USING (drug_name, npi)
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
ORDER BY total_claim_count DESC;

--Question 7b: Query above.

SELECT 
	prescriber.npi,
	drug.drug_name,
	COALESCE(total_claim_count, 0) AS total_claim_count
FROM prescriber
	CROSS JOIN drug
	LEFT JOIN prescription USING (drug_name, npi)
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
ORDER BY total_claim_count DESC;

--Question 7c: Query above. I initially ordered by total_claim_count w/ 0's first to show that COALESCE was applied and [nulls] were replaced by 0's. Then, I realized I could also order by DESC to show the same thing, because if [nulls] were present, they would have come first. DESC is a more useful visualization.


SELECT
	specialty_description,
	SUM(total_claim_count) AS total_claim_count,
	SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count ELSE 0 END) AS opioid_claim_count,
	ROUND(SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count ELSE 0 END) / SUM(total_claim_count) * 100, 2) AS opioid_percentage_of_claims
FROM prescriber
	INNER JOIN prescription USING (npi)
	INNER JOIN drug USING (drug_name)
GROUP BY 
	specialty_description
ORDER BY opioid_percentage_of_claims DESC;

--This is going to give me each specialties total_claim_count for opioids.

-- SELECT
-- 	specialty_description,
-- 	SUM(total_claim_count) AS total_claim_count
-- FROM prescriber
-- 	INNER JOIN prescription USING (npi)
-- 	INNER JOIN drug USING (drug_name)
-- GROUP BY specialty_description;

--This is going to give me each specialties total_claim_count for all prescriptions






--The queries below were wrong, so I'm putting them down here


--Question 7a: Reading comprehension issue

-- SELECT
-- 	npi,
-- 	drug_name,
-- 	CASE
-- 		WHEN opioid_drug_flag = 'Y' THEN 'Y'
-- 		WHEN long_acting_opioid_drug_flag = 'Y' THEN 'Y'
-- 		ELSE 'N'
-- 	END opioid
-- FROM prescriber
-- 	INNER JOIN prescription USING (npi)
-- 	INNER JOIN drug USING (drug_name)
-- WHERE specialty_description = 'Pain Management'
-- 	AND nppes_provider_city = 'NASHVILLE'
-- 	AND (opioid_drug_flag = 'Y' OR long_acting_opioid_drug_flag = 'Y');


--Question 7b: Reading comprehension issue

-- SELECT
-- 	npi,
-- 	drug_name,
-- 	total_claim_count
-- FROM prescriber
-- 	FULL JOIN prescription USING (npi)
-- 	FULL JOIN drug USING (drug_name)
-- WHERE specialty_description = 'Pain Management'
-- 	AND nppes_provider_city = 'NASHVILLE'
-- 	AND (opioid_drug_flag = 'Y' OR long_acting_opioid_drug_flag = 'Y');


--Question 7c: Didn't get very far when I realized I did the entire thing wrong.

-- SELECT *
-- FROM prescriber
-- 	FULL JOIN prescription USING (npi)
-- 	FULL JOIN drug USING (drug_name)
-- WHERE specialty_description = 'Pain Management'
-- 	AND nppes_provider_city = 'NASHVILLE'
-- 	AND opioid_drug_flag = 'Y';
