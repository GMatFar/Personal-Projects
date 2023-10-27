-- Create new column with coverted datetime so it does not include time

ALTER TABLE PortfolioHousingProject..Nashville
ADD SaleDateConverted Date;

UPDATE PortfolioHousingProject..Nashville
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDate, SaleDateConverted
FROM PortfolioHousingProject..Nashville


-- Populate NULL values in the PropertyAddress column
-- ParcelID is tied to address, so find matching ParcelIDs,
-- if one is NULL populate with the values of the other

-- Function to find results we wish to achieve prior to updating
SELECT nashA.[UniqueID ] AS UniqueID_A,
       nashB.[UniqueID ] AS UniqueId_B,
       nashA.ParcelID,
       nashA.PropertyAddress AS AddressA,
       nashB.PropertyAddress AS AddressB,
       ISNULL(nashA.PropertyAddress, nashB.PropertyAddress) AS PopulatedAdress
FROM PortfolioHousingProject..Nashville AS nashA
JOIN PortfolioHousingProject..Nashville AS nashB
    ON nashA.ParcelID = nashB.ParcelID
    AND nashA.[UniqueID ] <> nashB.[UniqueID ]
WHERE nashA.PropertyAddress is NULL

-- Update TABLE
UPDATE nashA
SET PropertyAddress = ISNULL(nashA.PropertyAddress, nashB.PropertyAddress)
FROM PortfolioHousingProject..Nashville AS nashA
JOIN PortfolioHousingProject..Nashville AS nashB
    ON nashA.ParcelID = nashB.ParcelID
    AND nashA.[UniqueID ] <> nashB.[UniqueID ]
WHERE nashA.PropertyAddress is NULL

-- Select Function to verify results
SELECT [UniqueID ], PropertyAddress, ParcelID
FROM PortfolioHousingProject..Nashville
WHERE PropertyAddress is NULL


-- Separate street from city in PropertyAdress

-- Function to find results we wish to achieve prior to updating
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS StreetAddress,
       SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress)) AS City 
FROM PortfolioHousingProject..Nashville

-- Create and populate new columns
ALTER TABLE PortfolioHousingProject..Nashville
ADD StreetAddress NVARCHAR(255);

UPDATE PortfolioHousingProject..Nashville
SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioHousingProject..Nashville
ADD City NVARCHAR(255);

UPDATE PortfolioHousingProject..Nashville
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress))

-- Verify results
SELECT PropertyAddress, StreetAddress, City
FROM PortfolioHousingProject..Nashville


-- Split owner's adress into 3 columns for street, city and state

-- Function to find results we wish to achieve prior to updating
SELECT OwnerAddress,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerStreet,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState
FROM PortfolioHousingProject..Nashville

-- Create columns and populate them
ALTER TABLE PortfolioHousingProject..Nashville
ADD OwnerStreet NVARCHAR(255);

ALTER TABLE PortfolioHousingProject..Nashville
ADD OwnerCity NVARCHAR(255);

ALTER TABLE PortfolioHousingProject..Nashville
ADD OwnerState NVARCHAR(255);

UPDATE PortfolioHousingProject..Nashville
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE PortfolioHousingProject..Nashville
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE PortfolioHousingProject..Nashville
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Test function to see results
SELECT OwnerAddress, OwnerStreet, OwnerCity, OwnerState
FROM PortfolioHousingProject..Nashville


-- Function to find results we wish to achieve prior to updating
SELECT SoldAsVacant,
       CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
            WHEN SoldAsVacant = 'N' THEN 'No'
            ELSE SoldAsVacant
            END
FROM PortfolioHousingProject..Nashville

-- Perform the update
UPDATE PortfolioHousingProject..Nashville
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END

-- Test function to see results
SELECT SoldAsVacant
from PortfolioHousingProject..Nashville;


-- Number all rows that share the same information
-- Note that UniqueID is not used in this numbering because this refers#
-- to the database entry, so we check for all other information matching
-- Any row numbered above 1 has repeated information so we delete it

WITH NumberedRowCTE AS(
SELECT *,
       ROW_NUMBER() OVER (
       PARTITION BY ParcelID,
                    PropertyAddress,
                    SalePrice,
                    SaleDate,
                    LegalReference
                    ORDER BY [UniqueID ]
       ) AS RowNumber

FROM PortfolioHousingProject..Nashville
)

DELETE
FROM NumberedRowCTE
WHERE RowNumber > 1;

-- Create the CTE again to check results
WITH NumberedRowCTE AS(
SELECT *,
       ROW_NUMBER() OVER (
       PARTITION BY ParcelID,
                    PropertyAddress,
                    SalePrice,
                    SaleDate,
                    LegalReference
                    ORDER BY [UniqueID ]
       ) AS RowNumber

FROM PortfolioHousingProject..Nashville
)

SELECT *
FROM NumberedRowCTE
WHERE RowNumber > 1;


-- Remove columns that are now unused (for demonstration purposes only)
ALTER TABLE PortfolioHousingProject..Nashville
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate

-- Test function to see results 
SELECT *
FROM PortfolioHousingProject..Nashville