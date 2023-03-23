/* 

QUERIES FOR CLEANING DATA IN SQL

*/

-- TO GET A GLIMPSE OF THE DATA
SELECT *
FROM ILearnSQL.dbo.NashvilleHousing;

---------------------------------------------------------------------------------------------------------------
	
-- TO CONVERT THE DATE FORMAT OF SaleDate COLUMN FROM DATETIME TO DATE ONLY / STANDARDIZING DATE
-- First we compare the data we have to what we want to derive

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM ILearnSQL.dbo.NashvilleHousing;

-- Query to Effect Change

ALTER TABLE ILearnSQL..NashvilleHousing
ALTER COLUMN SaleDate DATE;

---------------------------------------------------------------------------------------------------------------

-- TO POPULATE THE PROPERTY ADDRESS
-- We first checkout for Nulls

SELECT ParcelID, PropertyAddress
FROM ILearnSQL.dbo.NashvilleHousing a
WHERE PropertyAddress IS NULL


WITH NullAddress AS (SELECT ParcelID, PropertyAddress
FROM ILearnSQL.dbo.NashvilleHousing a
WHERE PropertyAddress IS NULL
)
SELECT a.ParcelID, a.PropertyAddress, b.PropertyAddress
FROM NullAddress a
JOIN ILearnSQL..NashvilleHousing b
ON a.ParcelID = b.ParcelID
WHERE b.PropertyAddress IS NOT NULL
ORDER BY ParcelID;

  
SELECT COUNT (ParcelID)
FROM ILearnSQL.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL;
-- with 6 repitions

--  Replacinge Null values with the ParcelID matching address

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ILearnSQL..NashvilleHousing a
JOIN ILearnSQL..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ];

 ---------------------------------------------------------------------------------------------------------------

-- TO BREAK ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

-- A view at the PorpertyAddress
SELECT PropertyAddress
FROM ILearnSQL.dbo.NashvilleHousing


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM ILearnSQL..NashvilleHousing

-- To effect our cleaning step; Address standardization into PropertyAddress1 and PropertyCity;

ALTER TABLE NashvilleHousing ADD
PropertyAddress1 Nvarchar(255);

UPDATE NashvilleHousing 
SET
PropertyAddress1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);


ALTER TABLE NashvilleHousing ADD
PropertyCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

SELECT *
FROM NashvilleHousing

---------------------------------------------------------------------------------------------------------------

-- To Clean up the OwnerAddress: Split to OwnerAddress1, City and State

-- quick view

SELECT OwnerAddress
FROM NashvilleHousing;
-- we replace the commas with period to enable PARSENAME to split
SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.'),3),
PARSENAME(REPLACE(OwnerAddress,',', '.'),2),
PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing ADD
OwnerAddress1 Nvarchar(255),
OwnerCity Nvarchar(255),
OwnerState Nvarchar(255);




UPDATE NashvilleHousing 
SET
OwnerAddress1 = PARSENAME(REPLACE(OwnerAddress,',', '.'),3);


UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2);



UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1);


----------------------------------------------------------------------------------------------------------------

-- To Clean up 'SoldAsVacant', having all answer as Yes and No all through

-- quick view
select distinct(SoldAsVacant), count(soldAsVacant)
FROM NashvilleHousing
Group by SoldAsVacant
Order by SoldAsVacant;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET  SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
						END;
----------------------------------------------------------------------------------------------------------


-- TO VIEW DUPLICATES ROWS

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					uniqueID
					)AS row_num
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyCity;


-- TO REMOVE DUPLICATE ROWS

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					uniqueID
					)AS row_num
FROM NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1;


----------------------------------------------------------------------------------------------------------------

-- To DELETE UNWANTED COLUMNS

ALTER TABLE NasvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict




