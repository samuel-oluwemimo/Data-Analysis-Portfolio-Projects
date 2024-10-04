select *
from [;PortfolioProject]..NashvilleHousing


-- Changing date

select SaleDateConverted, convert(date, SaleDate)
from [;PortfolioProject]..NashvilleHousing

update [;PortfolioProject]..NashvilleHousing
set SaleDate = convert(date, SaleDate)

ALTER TABLE [;PortfolioProject]..NashvilleHousing
add SaleDateConverted Date;

update [;PortfolioProject]..NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

-- Updating null values in property address

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [;PortfolioProject]..NashvilleHousing a
join [;PortfolioProject]..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [;PortfolioProject]..NashvilleHousing a
join [;PortfolioProject]..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- splitting the property address into city and address
select PropertyAddress, 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
from [;PortfolioProject]..NashvilleHousing

ALTER TABLE [;PortfolioProject]..NashvilleHousing
add AddressUpdated Nvarchar(255);

update [;PortfolioProject]..NashvilleHousing
SET AddressUpdated = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE [;PortfolioProject]..NashvilleHousing
add City  Nvarchar(255);

update [;PortfolioProject]..NashvilleHousing
set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- splitting the owner address
select PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from [;PortfolioProject]..NashvilleHousing

ALTER TABLE [;PortfolioProject]..NashvilleHousing
add OwnerAddressUpdated Nvarchar(255);

update [;PortfolioProject]..NashvilleHousing
SET OwnerAddressUpdated = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [;PortfolioProject]..NashvilleHousing
add OwnerCity  Nvarchar(255);

update [;PortfolioProject]..NashvilleHousing
set OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE [;PortfolioProject]..NashvilleHousing
add OwnerState Nvarchar(255);

update [;PortfolioProject]..NashvilleHousing
SET OwnerState =  PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- changing Y and N to yes and no in soldasvacant

select DISTINCT(SoldAsVacant), count(SoldAsVacant)
from [;PortfolioProject]..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'N' Then 'No'
	WHEN SoldAsVacant = 'Y' Then 'Yes'
	ELSE SoldAsVacant
END
from [;PortfolioProject]..NashvilleHousing

UPDATE [;PortfolioProject]..NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'N' Then 'No'
	WHEN SoldAsVacant = 'Y' Then 'Yes'
	ELSE SoldAsVacant
END

-- deleting duplicate row
WITH RowNumber
as(
select *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
					ORDER BY
					UniqueID
		) RowNum
from [;PortfolioProject]..NashvilleHousing)

DELETE
from RowNumber
where RowNum > 1

-- deleting unused columns

ALTER TABLE [;PortfolioProject]..NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress, TaxDistrict
