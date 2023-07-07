
--Cleaning data with SQL Queries

select *
from PortfolioProject2.dbo.NashvilleHousing


-- Standardize Date Format

select SaleDateConverted-- Convert(Date,Saledate) 
from PortfolioProject2.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(date,saledate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(date,saledate)



--POPULATE PROPERTY ADDRESS DATA

SELECT propertyaddress
from PortfolioProject2.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

Select *
from PortfolioProject2.DBO.NashvilleHousing
WHERE PropertyAddress is null
	
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.propertyaddress,b.PropertyAddress)
from PortfolioProject2.DBO.NashvilleHousing a
join PortfolioProject2.dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
   AND A.[UniqueID ] <> B.[UniqueID ]
--WHERE A.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
from PortfolioProject2.DBO.NashvilleHousing a
join PortfolioProject2.dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
   AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null


--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
 CHARINDEX(',', PropertyAddress)  --( To find the position of comma)
From PortfolioProject2.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) 
as Address
From PortfolioProject2.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress
= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity
= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



select *
From PortfolioProject2.dbo.NashvilleHousing

Select 
PARSENAME(replace(owneraddress,',','.'), 3),
PARSENAME(replace(owneraddress,',','.'), 2),
PARSENAME(replace(owneraddress,',','.'), 1)
from PortfolioProject2.dbo.NashvilleHousing



Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress
= PARSENAME(replace(owneraddress,',','.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity
= PARSENAME(replace(owneraddress,',','.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState
= PARSENAME(replace(owneraddress,',','.'), 1)



--CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD


SELECT Distinct(SOLDASVACANT), count(soldasvacant)
FROM PortfolioProject2.DBO.NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject2.DBO.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject2.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject2.dbo.NashvilleHousing



-- Delete unused columns

Select *
From PortfolioProject2.dbo.NashvilleHousing


ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

