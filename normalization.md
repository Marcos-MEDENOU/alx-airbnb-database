# Database Normalization 3NF

## Overview
This document outlines the normalization process applied to the Airbnb-like database schema to ensure it meets Third Normal Form (3NF) requirements. Normalization reduces data redundancy and prevents anomalies during data manipulation operations.

## Original Schema
The initial database schema consists of five main entities:

1. **User**
2. **Property**
3. **Booking**
4. **Review**
5. **Payment**

## Normalization Process

### First Normal Form (1NF)
First Normal Form requires that:
- Each table has a primary key
- Each column contains atomic values
- No repeating groups

**Analysis:**
- All tables already have primary keys (UserID, PropertyID, BookingID, ReviewID, PaymentID)
- All columns appear to store atomic values
- No repeating groups identified

**✅ The schema is already in 1NF.**

### Second Normal Form (2NF)
Second Normal Form requires that:
- The table is in 1NF
- All non-key attributes are fully functionally dependent on the primary key

**Analysis:**
- **User, Property, Payment tables**: All attributes depend on their respective primary keys
- **Booking table**: All attributes depend on BookingID
- **Review table**: Contains foreign keys (BookingID, GuestID, PropertyID) that might create partial dependencies

**Issue identified:** In the Review table, some attributes might depend on BookingID rather than ReviewID.

**Resolution:**
- Keep ReviewID as the primary key in the Review table
- Ensure Rating, Comment, and ReviewDate are dependent on ReviewID
- BookingID is necessary as a foreign key to establish the relationship

**✅ With this understanding, the schema is in 2NF.**

### Third Normal Form (3NF)
Third Normal Form requires that:
- The table is in 2NF
- No transitive dependencies (non-key attributes depending on other non-key attributes)

**Analysis:**
1. **User table:** No transitive dependencies identified
2. **Property table:** No transitive dependencies identified
3. **Booking table:** TotalPrice might be calculated from PricePerNight (in Property) and the duration between CheckInDate and CheckOutDate
4. **Review table:** No transitive dependencies identified
5. **Payment table:** Amount might be a duplicate of TotalPrice from the Booking table

**Issues identified:**
1. **Transitive dependency in Booking table:** TotalPrice depends on CheckInDate, CheckOutDate, and PricePerNight (from Property)
2. **Redundant data between Booking and Payment:** Amount in Payment likely duplicates TotalPrice in Booking

**Resolution:**
1. **For TotalPrice in Booking:**
   - Option 1 (Preferred): Keep TotalPrice in the Booking table, but document that it's a calculated field. This denormalization is accepted for performance reasons.
   - Option 2: Remove TotalPrice and calculate it when needed.

2. **For Amount in Payment:**
   - Clearly document that Amount in Payment should reference TotalPrice from Booking
   - This denormalization is acceptable for audit and historical purposes

## Additional Normalization Considerations

### Potential New Entities:
1. **Address Entity**
   - Extract address-related fields from Property (Address, City, State/Province, Country, PostalCode) into a new Address table
   - Add AddressID as FK to Property
   - Benefit: Allows for more complex address handling and reuse for user addresses in future

2. **PropertyAmenities Entity**
   - Create a separate table for amenities with a many-to-many relationship to Property
   - Structure: AmenityID (PK), AmenityName, Description
   - Join table: PropertyAmenityID (PK), PropertyID (FK), AmenityID (FK)
   - Benefit: Allows for flexible amenity management

3. **PropertyAvailability Entity**
   - Create a separate table to track property availability periods
   - Structure: AvailabilityID (PK), PropertyID (FK), StartDate, EndDate, IsAvailable
   - Benefit: Better handling of property availability

## Final Normalized Schema

After applying normalization principles, the recommended schema is:

### User
- UserID (PK)
- FirstName
- LastName
- Email
- Password (hashed)
- PhoneNumber
- DateJoined
- ProfilePicture
- UserType (Host/Guest)

### Address
- AddressID (PK)
- StreetAddress
- City
- State/Province
- Country
- PostalCode

### Property
- PropertyID (PK)
- HostID (FK -> User)
- AddressID (FK -> Address)
- Title
- Description
- PropertyType
- PricePerNight
- NumberOfBedrooms
- NumberOfBathrooms
- MaxGuests
- Status (Available, Booked, Maintenance)

### PropertyAmenity
- AmenityID (PK)
- AmenityName
- Description

### PropertyAmenityMapping
- MappingID (PK)
- PropertyID (FK -> Property)
- AmenityID (FK -> PropertyAmenity)

### PropertyAvailability
- AvailabilityID (PK)
- PropertyID (FK -> Property)
- StartDate
- EndDate
- IsAvailable

### Booking
- BookingID (PK)
- PropertyID (FK -> Property)
- GuestID (FK -> User)
- CheckInDate
- CheckOutDate
- TotalPrice (calculated field)
- NumberOfGuests
- BookingStatus (Pending, Confirmed, Cancelled)
- BookingDate

### Review
- ReviewID (PK)
- BookingID (FK -> Booking)
- Rating
- Comment
- ReviewDate

### Payment
- PaymentID (PK)
- BookingID (FK -> Booking)
- Amount (same as Booking.TotalPrice)
- PaymentDate
- PaymentStatus
- PaymentMethod

## Conclusion

The normalized schema adheres to 3NF principles with some practical considerations for denormalization where it makes sense for performance or business requirements. The additional suggested entities (Address, PropertyAmenity, PropertyAvailability) provide more flexibility and better data organization but can be implemented based on project requirements and scope.

These normalizations help to:
1. Eliminate data redundancy
2. Prevent update anomalies
3. Ensure data integrity
4. Create a more flexible database structure