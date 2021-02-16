--Author- Mirza Wasim Ahmed
--1.a) Display a list of all property names and their property id’s for Owner Id: 1426. 

SELECT
	op.PropertyId,op.OwnerId,p.Name AS 'property_name'
FROM 
	dbo.Property AS p
LEFT JOIN 
	dbo.OwnerProperty AS op ON p.Id = op.PropertyId
WHERE op.OwnerId = 1426;


--1.b. Current home value for each property in question 1.a

SELECT
	op.PropertyId, op.OwnerId,p.name AS 'property_name',value AS 'Property_Value'
FROM
	dbo.OwnerProperty AS op
LEFT JOIN
	dbo.Property AS p ON p.id= op.PropertyId

LEFT JOIN
	dbo.PropertyHomeValue AS phv ON phv.PropertyId= p.id

WHERE op.OwnerId=1426
	  AND phv.IsActive=1;

--1.c.i) For each property in question a), return the following: Using rental payment amount, rental payment frequency, 
--tenant start date and tenant end date to write a query that returns the sum of all payments from start date to end date. 

SELECT 
	tp.PropertyId,op.OwnerId,p.Name as 'Property_Name',
(CASE
WHEN tp.PaymentFrequencyId= 1
THEN DATEDIFF(Week, StartDate, EndDate)*tp.PaymentAmount

WHEN tp.PaymentFrequencyId= 2
THEN (DATEDIFF(Week, StartDate, EndDate)/2)*tp.PaymentAmount

WHEN tp.PaymentFrequencyId= 3
THEN (DATEDIFF(Month, StartDate, EndDate)+1)*tp.PaymentAmount
--Added 1 with the number of month as DATEDIFF function counts the difference of StartDate and EndDate
-- So the difference become 11 months and 1 month goes missing, although the duration is 1 full year=12 months.
ELSE ''
END ) AS Total_Rent_Received

FROM 
	TenantProperty AS tp

	LEFT JOIN Property AS p
	ON tp.PropertyId= p.Id

	LEFT JOIN OwnerProperty AS op
	ON p.Id = op.PropertyId

WHERE op.OwnerId=1426;

--1.c.ii) Display the yield.

SELECT 
	tp.PropertyId,op.OwnerId,p.Name as 'Property_Name',
(CASE
WHEN tp.PaymentFrequencyId= 1
THEN DATEDIFF(Week, StartDate, EndDate)*tp.PaymentAmount

WHEN tp.PaymentFrequencyId= 2
THEN (DATEDIFF(Week, StartDate, EndDate)/2)*tp.PaymentAmount

WHEN tp.PaymentFrequencyId= 3
THEN (DATEDIFF(Month, StartDate, EndDate)+1)*tp.PaymentAmount
ELSE ''
END ) AS Total_Rent_Received,phv.value AS 'Property_Value',

(CASE
WHEN tp.PaymentFrequencyId= 1
THEN ((DATEDIFF(Week, StartDate, EndDate)*tp.PaymentAmount)/phv.Value)*100

WHEN tp.PaymentFrequencyId= 2
THEN ((DATEDIFF(Week, StartDate, EndDate)/2)*tp.PaymentAmount/phv.Value)*100

WHEN tp.PaymentFrequencyId= 3
THEN ((DATEDIFF(Month, StartDate, EndDate)+1)*tp.PaymentAmount/phv.Value)*100
ELSE ''
END ) AS Yield

FROM 
	TenantProperty AS tp
	LEFT JOIN Property AS p
	ON tp.PropertyId= p.Id
	LEFT JOIN OwnerProperty AS op
	ON p.Id = op.PropertyId
	LEFT JOIN dbo.PropertyHomeValue AS phv ON phv.PropertyId= p.id
WHERE op.OwnerId=1426
AND phv.IsActive=1;
 

 --1.d Display all the jobs available
SELECT j.PropertyId,jm.JobId, j.JobDescription AS Curently_available_job_Description, j.PaymentAmount
FROM Job as j
LEFT JOIN JobMedia as jm
ON j.PropertyId= jm.PropertyId
WHERE JobStatusId=1;


--1.e) Display all property names,current tenants first names and last names and rental payments per
--week/ fortnight/month for the properties in question a). 

SELECT pr.name as Property_Name, concat( pn.FirstName,'',pn.MiddleName,'',pn.LastName) as Tenant_full_Name, t.PaymentAmount,
(CASE
WHEN t.PaymentFrequencyId= 1
THEN 'Weekly'

WHEN t.PaymentFrequencyId= 2
THEN 'Fortnitely'

WHEN t.PaymentFrequencyId=3
THEN 'Monthly'
ELSE ''
END) as Payment_method

From TenantProperty t, Person pn, Property as pr

where t.PropertyId= pr.Id
and t.TenantId= pn.Id and t.PropertyId in
(SELECT DISTINCT p.id 
from property p, OwnerProperty AS op
WHERE p.id= op.PropertyId 
AND op.OwnerId= 1426)



--2. Develop SSRS report:

SELECT p.Name AS Property_Name,
CONCAT( Pn.FirstName, ' ' , Pn.LastNAme) AS Current_Owner,
CONCAT (A.Number,',' , A.Suburb, ',' , A.City, ', ' , A.PostCode) AS Property_Address,
CONCAT (p.Bedroom,' ' , 'Bedroom ,' , p.Bathroom, ' ' , 'Bathroom') AS Property_Details,
PRP.Amount AS Rent,
(CASE WHEN tpf.id=1 THEN 'Weekly'
WHEN tpf.id=2 THEN 'Fortnightly'
WHEN tpf.id=3 THEN 'Monthly'
END ) AS RentFrequency,
PE.Description AS Expence , PE.Amount AS ExpenseAmount, PE.Date AS ExpenseDate
FROM Property p, Address A , PropertyRentalPayment PRP, Ownerproperty OP,
Person AS PN, PropertyExpense PE, TenantPaymentFrequencies TPF
WHERE p.Name= 'Property A'
AND p.AddressId= a.AddressID
AND PRP.PropertyID=p.Id
AND op.PropertyID=p.Id
AND op.OwnerID=pn.Id
AND pe.PropertyId=p.Id
AND PRP.FrequencyType=tpf.Id;

