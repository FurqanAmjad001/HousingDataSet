
/*
Cleaning data in SQL Queries
*/

Select *
From master.dbo.NashVilleHousing


--- Standardize date format ---
Select SalesDateConverted, CONVERT(Date,SaleDate)
From master.dbo.NashVilleHousing

Update NashVilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashVilleHousing
Add SalesDateConverted Date;

Update NashVilleHousing
SET SalesDateConverted = CONVERT(Date,SaleDate)



/*
Populate property Address data */

Select *
From master.dbo.NashVilleHousing
--Where PropertyAddress is null
order by ParcelID



Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
From master.dbo.NashVilleHousing as A
Join master.dbo.NashVilleHousing as B
	on A.ParcelID = B.ParcelID
	And A.[UniqueID ] <> B.[UniqueID ]
Where a.PropertyAddress is Null

Update A
Set PropertyAddress = isnull(A.PropertyAddress,B.PropertyAddress)
From master.dbo.NashVilleHousing as A
Join master.dbo.NashVilleHousing as B
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null


-- Breaking Out Address into individual Columns (Address, City, State)

Select PropertyAddress
From master.dbo.NashVilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address

From master.dbo.NashVilleHousing

ALTER TABLE NashVilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashVilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashVilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashVilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))



Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From master.dbo.NashVilleHousing

ALTER TABLE NashVilleHousing
	Add OwnerSplitCity Nvarchar(255),
		OwnerSplitAddress Nvarchar(255),
		OwnerSplitState Nvarchar(255);

Update NashVilleHousing
	SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
		OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
		OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

/*

Change Y and N to Yes and No in "Sold as Vacant" Field

*/

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)	
From master.dbo.NashVilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 ELSE SoldAsVacant
	 END
From master.dbo.NashVilleHousing

Update NashVilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 ELSE SoldAsVacant
	 END


	/*
	Remove Duplicates */
WITH RowNumCTE as(
Select *,
	ROW_NUMBER() OVER(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				Order By 
				UniqueID
					) row_num
From master.dbo.NashVilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--- Delete Unused Columns ---
Select *
From master.dbo.NashVilleHousing

ALTER TABLE master.dbo.NashVilleHousing
DROP Column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate