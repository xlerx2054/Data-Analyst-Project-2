-- Convert SaleDate to Date data type
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousingPlan

-- Select rows where PropertyAddress is null
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousingPlan
WHERE PropertyAddress is null

-- Update rows with null PropertyAddress based on matching ParcelID
SELECT table_a.ParcelID,table_a.PropertyAddress,table_b.ParcelID,table_b.PropertyAddress, ISNULL(table_a.PropertyAddress,table_b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousingPlan table_a 
JOIN PortfolioProject.dbo.NashvilleHousingPlan table_b 
    ON table_a.ParcelID = table_b.ParcelID 
    AND table_a.[UniqueID] <> table_b.[UniqueID]
WHERE table_a.PropertyAddress is null

-- Update rows with null PropertyAddress based on matching ParcelID
UPDATE table_a 
SET PropertyAddress = ISNULL(table_a.PropertyAddress,table_b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousingPlan table_a 
JOIN PortfolioProject.dbo.NashvilleHousingPlan table_b 
    ON table_a.ParcelID = table_b.ParcelID 
    AND table_a.[UniqueID] <> table_b.[UniqueID]
WHERE table_a.PropertyAddress is null

-- Split PropertyAddress into Address and LocationAddress based on comma delimiter
SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as LocationAddress
FROM PortfolioProject.dbo.NashvilleHousingPlan

-- Add columns for split PropertyAddress
ALTER TABLE NashvilleHousingPlan
ADD PropertySplitAddress Nvarchar(255);

-- Update split PropertyAddress
UPDATE NashvilleHousingPlan
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

-- Add column for split PropertyCity
ALTER TABLE NashvilleHousingPlan
ADD PropertySplitCity Nvarchar(255);

-- Update split PropertyCity
UPDATE NashvilleHousingPlan
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

-- Split OwnerAddress into Address, City, and State based on comma delimiter and reverse order
SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousingPlan

-- Add columns for split OwnerAddress
ALTER TABLE NashvilleHousingPlan
ADD OwnerSplitAddress Nvarchar(255);

-- Update split OwnerAddress
UPDATE NashvilleHousingPlan
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

-- Add columns for split OwnerCity
ALTER TABLE NashvilleHousingPlan
ADD OwnerSplitCity Nvarchar(255);

-- Update split OwnerCity
UPDATE NashvilleHousingPlan
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

-- Add columns for split OwnerState
ALTER TABLE NashvilleHousingPlan
ADD OwnerSplitState Nvarchar(255);

-- Update split OwnerState
UPDATE NashvilleHousingPlan
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

-- Update SoldAsVacant values to 'Yes' or 'No'
SELECT SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
FROM PortfolioProject.dbo.NashvilleHousingPlan

-- Update SoldAsVacant column with 'Yes' or 'No'
UPDATE NashvilleHousingPlan
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
                    END

-- Identify duplicate rows based on certain columns
WITH RowNumCTE AS(
    SELECT *, ROW_NUMBER() OVER(
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueId) row_num
    FROM PortfolioProject.dbo.NashvilleHousingPlan
)

-- Select duplicate rows
SELECT *
FROM RowNumCTE
WHERE row_num > 1

-- Drop SaleDate column from table
ALTER TABLE PortfolioProject.dbo.NashvilleHousingPlan
DROP COLUMN SaleDate 

-- Select all rows from table and order by UniqueID
SELECT *
FROM PortfolioProject.dbo.NashvilleHousingPlan
ORDER BY UniqueID
