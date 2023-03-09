/*

Cleaning Data in SQL Queries

*/

SELECT  SaleDateConverted
FROM NashvilleHouseCSV

----Standardize Data Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHouseCSV

Update NashvilleHouseCSV
SET SaleDate= CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHouseCSV
add SaleDateConverted Date;

Update NashvilleHouseCSV
SET SaleDateConverted = CONVERT(Date, SaleDate)

-------------------------------------------------------------------------------------------------
--Populate Property Address data

SELECT*
FROM  NashvilleHouseCSV
--WHERE PropertyAddress is not null
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHouseCSV as a
JOIN NashvilleHouseCSV as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHouseCSV as a
JOIN NashvilleHouseCSV as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------
---Breaking out address into Individual Columns (address, city, state)

SELECT PropertyAddress
FROM  NashvilleHouseCSV
--WHERE PropertyAddress is not null
--ORDER BY ParcelID


SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)  as Address 
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))  as Address 
FROM  NashvilleHouseCSV


ALTER TABLE NashvilleHouseCSV
ADD PropertySplitAddress Nvarchar(225);

UPDATE NashvilleHouseCSV
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHouseCSV
ADD PropertySplitCity Nvarchar(225);

UPDATE NashvilleHouseCSV
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT*
FROM NashvilleHouseCSV


--- Let's rearrange the owner address by splitting them by address, city, and state.

SELECT OwnerAddress
FROM NashvilleHouseCSV

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From NashvilleHouseCSV


ALTER TABLE NashvilleHouseCSV
ADD OwnerSplitAddress Nvarchar(225);

UPDATE NashvilleHouseCSV
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHouseCSV
ADD OwnerSplitCity Nvarchar(225);

UPDATE NashvilleHouseCSV
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHouseCSV
ADD OwnerSplitState Nvarchar(225);

UPDATE NashvilleHouseCSV
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT*
FROM NashvilleHouseCSV

------------------------------------------------------------------------------------------------------------------

---Change 1 and 0 to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHouseCSV
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHen SoldAsVacant = '1' THEN 'Yes'
	WHEN SoldAsVacant = '0' THEN 'No'
	END
FROM NashvilleHouseCSV


UPDATE NashvilleHouseCSV
SET SoldAsVacant = CASE  WHen SoldAsVacant = '1' THEN 'Yes'
	WHEN SoldAsVacant = '0' THEN 'No'
	END



--------------------------------------------------------------------------------------------------------------------------
--------Remove Duplicate

---First write the following code 

--WITH RowNumCTE as (
--SELECT*, 
--	ROW_NUMBER() OVER (
--	PARTITION BY ParcelID,
--				PropertyAddress,
--				SalePrice,
--				SaleDate,
--				LegalReference
--				ORDER BY
--				uniqueID
--				) row_num
--FROM NashvilleHouseCSV)
----ORDER BY ParcelID
--DELETE
--FROM RowNumCTE
--Where row_num >1
--ORder By PropertyAddress


----write this following code to double check if the duplicate still exist.
WITH RowNumCTE as (
SELECT*, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				uniqueID
				) row_num
FROM NashvilleHouseCSV)
--ORDER BY ParcelID
SELECT*
FROM RowNumCTE
Where row_num >1
ORder By PropertyAddress


-------------------------------------------------------------------------------------------------------------------------
----------Delete Unused Columns

SELECT*
FROM NashvilleHouseCSV

ALTER TABLE NashvilleHouseCSV
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE  NashvilleHouseCSV
DROP COLUMN SaleDate