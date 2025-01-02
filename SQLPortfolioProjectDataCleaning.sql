-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022


-- Cleaning data in SQL Queries

SELECT 
	*
FROM SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning


SELECT 
	SaleDate, CONVERT(Date,SaleDate)
FROM SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning


UPDATE Nashville_Housing_Data_for_Data_Cleaning
SET SaleDate = CONVERT(Date,SaleDate)


SELECT
	*
FROM SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning
WHERE PropertyAddress = NULl


UPDATE Nashville_Housing_Data_for_Data_Cleaning
SET PropertyAddress = '' 
WHERE PropertyAddress = 'NULL'


-- Populate Property Address data

SELECT 
	*
FROM SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning
--WHERE PropertyAddress = ''
ORDER BY ParcelID


SELECT 
	a. ParcelID, 
	a.PropertyAddress, 
	b.ParcelID, 
	b.PropertyAddress, 
	(SELECT 
		b.PropertyAddress 
	FROM SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning
	WHERE a.PropertyAddress = '')
FROM SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning a
JOIN SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b. [UniqueID ]
WHERE a.PropertyAddress = ''

-- Breaking out Address into Individual Columns (Adress, City, State)

SELECT PropertyAddress
FROM SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning


SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address

FROM SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning


ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning
ADD PropertySplitAddress nvarchar(255);

UPDATE Nashville_Housing_Data_for_Data_Cleaning
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning
ADD PropertySplitCity nvarchar(255);

UPDATE Nashville_Housing_Data_for_Data_Cleaning
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT
	*
FROM Nashville_Housing_Data_for_Data_Cleaning


SELECT 
	OwnerAddress
FROM SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning


SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),3)
	,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
	,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning


ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning
ADD OwnerSplitAddress nvarchar(255);

UPDATE Nashville_Housing_Data_for_Data_Cleaning
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning
ADD OwnerSplitCity nvarchar(255);

UPDATE Nashville_Housing_Data_for_Data_Cleaning
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashville_Housing_Data_for_Data_Cleaning
ADD OwnerSplitState nvarchar(255);

UPDATE Nashville_Housing_Data_for_Data_Cleaning
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT 
	Distinct(SoldAsVacant)
	,COUNT (SoldAsVacant)
FROM SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning
GROUP BY SoldAsVacant
ORDER BY 2


SELECT 
	SoldAsVacant
	,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		  WHEN SoldAsVacant = 'N' THEN 'No'
		  ELSE SoldAsVacant
	END
FROM SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning


UPDATE Nashville_Housing_Data_for_Data_Cleaning
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END



-- Remove Duplicates

WITH RowNumCTE AS(
SELECT
	*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


WITH RowNumCTE AS(
SELECT
	*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


-- Delete Unused Columns


ALTER TABLE SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE SQLPortfolioProjectDataCleaning.dbo.Nashville_Housing_Data_for_Data_Cleaning
DROP COLUMN SaleDate