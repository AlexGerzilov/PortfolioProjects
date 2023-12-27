-- Cleaning data in SQL queries

select *
from [Portfolio Project].dbo.NashvilleHousing

--Standardize date format

select SaleDateConverted, convert(date,saledate)
from [Portfolio Project].dbo.NashvilleHousing

update nashvillehousing 
set saledate = convert(date,saledate)

alter table nashvillehousing
add SaleDateConverted date;

update nashvillehousing 
set SaleDateConverted = convert(date,saledate)


-- Populate Property Address data

select *
from [Portfolio Project].dbo.NashvilleHousing
order by parcelid

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress,b.propertyaddress)
from [Portfolio Project].dbo.NashvilleHousing a
join [Portfolio Project].dbo.NashvilleHousing b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from [Portfolio Project].dbo.NashvilleHousing a
join [Portfolio Project].dbo.NashvilleHousing b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null


-- breaking addres into individual columns (Address, City, State)

select propertyaddress
from [Portfolio Project].dbo.NashvilleHousing

select
substring (propertyaddress, 1, charindex(',', propertyaddress) -1) as Address
, substring (propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress)) as Address
from [Portfolio Project].dbo.NashvilleHousing


alter table nashvillehousing
add PropertySplitAddress nvarchar(255);

update nashvillehousing 
set PropertySplitAddress = substring (propertyaddress, 1, charindex(',', propertyaddress) -1)

alter table nashvillehousing
add PropertySplitCity nvarchar(255);

update nashvillehousing 
set PropertySplitCity = substring (propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress))

select *
from [Portfolio Project].dbo.NashvilleHousing



select owneraddress
from [Portfolio Project].dbo.NashvilleHousing


select
parsename(replace (owneraddress, ',', '.'), 3)
, parsename(replace (owneraddress, ',', '.'), 2)
, parsename(replace (owneraddress, ',', '.'), 1)
from [Portfolio Project].dbo.NashvilleHousing



alter table nashvillehousing
add OwnerSplitAddress nvarchar(255);

update nashvillehousing 
set OwnerSplitAddress = parsename(replace (owneraddress, ',', '.'), 3)

alter table nashvillehousing
add OwnerSplitCity nvarchar(255);

update nashvillehousing 
set OwnerSplitCity = parsename(replace (owneraddress, ',', '.'), 2)

alter table nashvillehousing
add OwnerSplitState nvarchar(255);

update nashvillehousing 
set OwnerSplitState = parsename(replace (owneraddress, ',', '.'), 1)

select *
from [Portfolio Project].dbo.NashvilleHousing


-- change Y and N to 'Yes' and 'No' in "sold as vacant" field

select distinct(SoldAsVacant), count (SoldAsVacant)
from [Portfolio Project].dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from [Portfolio Project].dbo.NashvilleHousing


update [Portfolio Project].dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end



-- remove duplicates


with RowNumCTE as(
select *,
row_number() over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) row_num

from [Portfolio Project].dbo.NashvilleHousing
)

select *
from RowNumCTE
where row_num > 1
order by propertyaddress


-- delete unused columns

select *
from [Portfolio Project].dbo.NashvilleHousing

alter table [Portfolio Project].dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, Propertyaddress

alter table [Portfolio Project].dbo.NashvilleHousing
drop column SaleDate