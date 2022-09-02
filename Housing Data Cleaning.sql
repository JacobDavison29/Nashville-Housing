
-- DATA CLEANING --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Convert Date to a standard format (Removing time in datetime value)-------------------------------------------------------------------------

-- Looking at the difference between the two formats
SELECT SaleDate, CONVERT(Date,SaleDate) AS Sale_Date
FROM Housing;

-- Creating a new column in the database to house the dates in the new formats
ALTER TABLE Housing
ADD Sale_Date DATE;

-- Populating the new column with the new date format
UPDATE Housing
SET Sale_Date = CONVERT(DATE,SaleDate);

-- Checking to make sure column was properly populated
SELECT Sale_Date From Housing;

-- Fill in blank data in PropertyAddress Column-------------------------------------------------------------------------------------------------------

-- Getting The Address that needs to be populated based on the same ParcelID's
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Housing AS A
JOIN Housing AS B ON A.ParcelID = B.ParcelID
AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress is NULL;

-- Updating the dataset with new Addresses 
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Housing AS A
JOIN Housing AS B ON A.ParcelID = B.ParcelID 
AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress is NULL;

-- Serperate PropertyAddress and OwnerAddress----------------------------------------------------------------------------------------------

-- Sepertating PropertyAddress into (Address, City)-----------------------------------------------

-- Seperating the Address and City by comma
SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM Housing;

--Updating the table with new Column Property_Address
ALTER TABLE Housing
ADD Property_Address Nvarchar(255);

--Populating the new Property_Address column with the data
UPDATE Housing
SET Property_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1);

--Updating the table with new column Property_City
ALTER TABLE Housing
ADD Property_City Nvarchar(255);

-- Populating the new Property_City column with the data
UPDATE Housing
SET Property_City = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

--Seperating OwnerAddress Into (Address, City, State)------------------------------------------------------------

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Owner_Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS Owner_City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS Owner_State
FROM Housing;

--Updating the table with new Column Owner_Address
ALTER TABLE Housing
ADD Owner_Address Nvarchar(255);

--Populating the new Owner_Address column with the data
UPDATE Housing
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

--Updating the table with new Column Owner_City
ALTER TABLE Housing
ADD Owner_City Nvarchar(255);

--Populating the new Owner_City column with the data
UPDATE Housing
SET Owner_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

--Updating the table with new Column Owner_State
ALTER TABLE Housing
ADD Owner_State Nvarchar(255);

--Populating the new Owner_State column with the data
UPDATE Housing
SET Owner_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1);


-- Change Y and N values in vacant field to Yes and No--------------------------------------------------------------------------------------------------------------

--Checking values in column SoldAsVacant
SELECT DISTINCT SoldAsVacant, Count(SoldAsVacant)
FROM Housing
GROUP BY SoldAsVacant
ORDER BY 2;


-- Changing values N and Y into Yes and No
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END AS Sold_As_Vacant
FROM Housing;


--Updating the dataset
UPDATE Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END;

-- Remove Duplicates---------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Creating a CTE to Organize the data by ROW_Number to Identify what values are duplicated, then deleting these values.
WITH Row_Num_CTE AS(
SELECT *, 
	ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice,SaleDate,LegalReference ORDER BY UniqueID) AS Row_Num
FROM Housing)
DELETE
FROM Row_Num_CTE
WHERE Row_Num > 1;

-- Delete Unused Columns-----------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE Housing
DROP COLUMN SaleDate,PropertyAddress,OwnerAddress;
