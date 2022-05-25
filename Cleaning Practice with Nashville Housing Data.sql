select *
from NashvilleHousing

-- Standardize date format

select SaleDateConverted, CONVERT(date, SaleDate)
From NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

select SaleDate
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date; 

update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


-- Populate Property Address Data
select *
From NashvilleHousing
where PropertyAddress is null

select *
From NashvilleHousing
order by ParcelID

-- Each property address has a unique ParcelID
-- If a property address is missing but the parcel ID matches another parcel ID, we can populate the missing property address from that matching parcel ID 

select a.ParcelID, A.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a 
JOIN NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a 
JOIN NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

SELECT *
FROM NashvilleHousing
where PropertyAddress is null


-- Breaking out address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
from NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

update NashvilleHousing
SET PropertySplitCity =SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select *
FROM NashvilleHousing


--update Owner Address

Select OwnerAddress
FROM NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3), 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2), 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

update NashvilleHousing
SET OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

update NashvilleHousing
SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct (SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes' 
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE when SoldAsVacant = 'Y' THEN 'Yes' 
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

Select *
from NashvilleHousing


-- Remove Duplicates

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
FROM NashvilleHousing
--order by ParcelID
)
--DELETE
from RowNumCTE
where row_num > 1 
--Order by PropertyAddress

--Commented out delete in case query runs again 

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
FROM NashvilleHousing
--order by ParcelID
)
Select * 
from RowNumCTE
where row_num > 1 
--Order by PropertyAddress


-- Delete Unused Columns (Owner address, property address, and tax district)

Select * 
From NashvilleHousing


ALTER TABLE NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

