/*

Cleaning Data in SQL Queries

*/

Select * 
from PortfolioProject.dbo.NashvilleHousing
-------------------------------------------------------------------------------------------------------------------------------

-- Standardize the Data Format

Select Saledate, Convert(Date,Saledate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing 
Set SaleDate=Convert(date,Saledate)

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date;

------------------------------------------------

-- Populate property address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

-----------------------------------------------------------------------------------

-- Breaking out address into Individual columns (Address, City, State)

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address 
,SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) + 1), LEN(PropertyAddress) as Address
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

ALTER table PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySlitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER table PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1), LEN(PropertyAddress)


SELECT LegalReference, SUBSTRING(LegalReference,CHARINDEX('-',LegalReference)+1, LEN(LegalReference))
FROM PortfolioProject.dbo.NashvilleHousing


SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress,',' , '.'),2),
PARSENAME(REPLACE(OwnerAddress,',' , '.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',' , '.'),2)

ALTER table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',' , '.'),1)

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold As Vacant" field

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


Select SoldAsVacant,
	CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing 
SET SoldAsVacant= CASE 
		WHEN SoldAsVacant='Y' THEN 'Yes'
		WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END

------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  Order By UniqueID
				  ) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
Order By PropertyAddress

----------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict


-----------------------------------------------------------------------------------