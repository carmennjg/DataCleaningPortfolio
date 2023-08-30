SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--standarize date format
SELECT SaleDate2, CONVERT(date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing 
Add SaleDate2 Date

UPDATE NashvilleHousing 
SET SaleDate2 =(date, SaleDate)

--populate property address data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b 
ON a.ParcelID = b.ParcelID 
AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b 
ON a.ParcelID = b.ParcelID 
AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

--splitting address into address, city
SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Adress, 
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
add SplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET SplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
add SplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET SplitCity= SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--slpitting owner address into address, city, state
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
add OwnerSlpitAddress Nvarchar(255)
ALTER TABLE NashvilleHousing
add OwnerSlpitCity Nvarchar(255)
ALTER TABLE NashvilleHousing
add OwnerSlpitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSlpitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 
UPDATE NashvilleHousing
SET OwnerSlpitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 
UPDATE NashvilleHousing
SET OwnerSlpitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 

--changing Y and N to Yes and No in SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END 
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END 
FROM PortfolioProject.dbo.NashvilleHousing

SELECT Distinct (SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

--remove duplicates
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

From PortfolioProject.dbo.NashvilleHousing
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

DELETE
From RowNumCTE
Where row_num > 1

--DELETING COLUMNS

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress

