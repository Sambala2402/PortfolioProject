--Data Cleaning

select * from PortfolioProject..NashvilleHousing

--Standardize the Date Format
select SalesDate from PortfolioProject.dbo.NashvilleHousing
--Converting DateTime Format to Date format
 
Select CONVERT(date, SaleDate) as SaleDateFormat from PortfolioProject.dbo.NashvilleHousing 

--Added a new column and updated the datatype from datetime format to date format of old column and set to new column..
Alter table NashvilleHousing
Add SalesDate date
update NashvilleHousing
Set SalesDate = CONVERT(date,SaleDate)


--to alter/change the datatype of a column 
--Alter table NashvilleHousing
--Alter column SaleDate date

-- Popoulate PropertyAddress data

select * from PortfolioProject..NashvilleHousing 

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a 
join
NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Here we updated PropertAddress value when it is null with same propertyaddress where parcelids are equal and uniqueid is unique
update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a 
join
NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out PropertyAddress to (Address,City,State)
--using Substring  --SUBSTRING(string, start, length)


select * from PortfolioProject..NashvilleHousing 

Select PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1 ) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as city
from NashvilleHousing
 
 Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255)
update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1 ) 

 Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255)
update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


--Breaking OwnerAddress into Address/city/state
--Using Parsename --PARSENAME ('object_name' , object_piece ) - PARSENAME just returns the specified part of the specified object name

select * from PortfolioProject..NashvilleHousing 

select OwnerAddress,
PARSENAME(Replace(OwnerAddress,',','.'),3) as Address,
PARSENAME(Replace(OwnerAddress,',','.'),2) as City,
PARSENAME(Replace(OwnerAddress,',','.'),1) as State
from PortfolioProject..NashvilleHousing 

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)
update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3) 

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255)
update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2) 

Alter table NashvilleHousing
Add OwnerSplitSate nvarchar(255)
update NashvilleHousing
Set OwnerSplitSate = PARSENAME(Replace(OwnerAddress,',','.'),1) 


--Change Y AND N to Yes and No in SoldAsVacant

select SoldAsVacant FROM NashvilleHousing where SoldAsVacant = 'Y'

select Distinct(SoldAsVacant),COUNT(SoldAsVacant) FROM NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant ='N' then 'No' 
else SoldAsVacant
end
FROM NashvilleHousing 

update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant ='N' then 'No' 
else SoldAsVacant
end



--Remove Duplicates
--Cte ,Window functions-Row_Number

select * from NashvilleHousing


with RowNumCte as (
select *,
ROW_NUMBER() over (Partition by 
parcelId,PropertyAddress,SaleDate,SalePrice,LegalReference 
Order by UniqueID)row_num
from NashvilleHousing 
--order by parcelId
)
select * from RowNumCte
where row_num >1
order by PropertyAddress

--Removing the duplicates using delete,cte,rownumber
with RowNumCte as (
select *,
ROW_NUMBER() over (Partition by 
parcelId,PropertyAddress,SaleDate,SalePrice,LegalReference 
Order by UniqueID)row_num
from NashvilleHousing 
--order by parcelId
)
Delete from RowNumCte
where row_num >1
--order by PropertyAddress


--Delete unused columns

select * from NashvilleHousing

Alter table NashvilleHousing 
drop column propertAdderss, OwnerAddress,TaxDistrict

