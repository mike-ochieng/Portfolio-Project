/*

Cleaning NashvilleHousing Data in SQL

*/

Select * from NashvilleHousing

-- To standardize the date format (SaleDate Column)

Select SaleDateConverted from NashvilleHousing

Select SaleDate, CONVERT (Date, SaleDate) AS new_SaleDate from NashvilleHousing

update NashvilleHousing SET SaleDate = CONVERT (Date, SaleDate) 

-- If the column SaleDate does not update properly, try the code below 
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date; --to add a bew column SaleDateConverted

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate) --To update the new column in the correct date format

--delete from NashvilleHousing where SaleDate = SaleDate


--Populating the PropertyAddress column with row set a null to be set with values

Select * From NashvilleHousing Where PropertyAddress is null

Select PropertyAddress From NashvilleHousing Where PropertyAddress is null

Select * From NashvilleHousing 
ORDER BY ParcelID

-- To populate the not null values in the PropertyAddress with the ParcelID reference for the PropertyAdress which is similar for one parcelID to another

Select A.ParcelID, a.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
From NashvilleHousing AS A
JOIN NashvilleHousing AS B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NOT NULL

UPDATE A 
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
From NashvilleHousing AS A
JOIN NashvilleHousing AS B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

------------------------------------------------------------------------------------------------------------------

-- Breaking the PropertyAddress column into (Address and City)

select * from NashvilleHousing

select PropertyAddress from NashvilleHousing 

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1 ) AS address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS address

FROM NashvilleHousing

-- Adding two new columns (new_property_address) and (property_city) into the NashvilleHousing table

ALTER TABLE NashvilleHousing
Add new_property_address Nvarchar(255);

Update NashvilleHousing
SET new_property_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add property_city Nvarchar(255);

Update NashvilleHousing
SET property_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select * From NashvilleHousing


-- Breaking the OwnerAddress column into (Address, City State)

Select OwnerAddress From NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing


ALTER TABLE NashvilleHousing
Add new_owner_address Nvarchar(255);

Update NashvilleHousing
SET new_owner_address = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add owner_city Nvarchar(255);

Update NashvilleHousing
SET owner_city = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add owner_state Nvarchar(255);

Update NashvilleHousing
SET owner_state = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select * From NashvilleHousing

---------------------------------------------------------------------------------------------------------------

-- Changign the Y and N letters to Yes and No words in (SoldAsVacant) field

Select SoldAsVacant From NashvilleHousing

Select Distinct(SoldAsVacant)
From NashvilleHousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


Select SoldAsVacant, 
CASE 
When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = 
CASE 
When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

-- Removing duplicates

WITH row_num_CTE AS(
select *,

ROW_NUMBER() OVER(
PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
ORDER BY UniqueID) row_num

from NashvilleHousing
)

select * from row_num_CTE
where row_num > 1 
ORDER BY PropertyAddress


WITH row_num_CTE AS(
select *,

ROW_NUMBER() OVER(
PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
ORDER BY UniqueID) row_num

from NashvilleHousing
)

DELETE FROM row_num_CTE
where row_num > 1 

-----------------------------------------------------------------------------------------------------------------

--Deleting unused columns

select * from NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

