-- ALX AirBnB Database Schema
-- schema.sql

-- Enable foreign key constraints
PRAGMA foreign_keys = ON;

-- Drop tables if they exist to ensure clean creation
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS PropertyAmenityMapping;
DROP TABLE IF EXISTS PropertyAmenity;
DROP TABLE IF EXISTS PropertyAvailability;
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS Property;
DROP TABLE IF EXISTS Address;
DROP TABLE IF EXISTS User;

-- User Entity
CREATE TABLE User (
    UserID INTEGER PRIMARY KEY AUTOINCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL, -- Storing hashed password
    PhoneNumber VARCHAR(20),
    DateJoined DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ProfilePicture VARCHAR(255),
    UserType ENUM('Host', 'Guest') NOT NULL,
    
    -- Indexes
    INDEX idx_user_email (Email),
    INDEX idx_user_type (UserType)
);

-- Address Entity (extracted from Property for normalization)
CREATE TABLE Address (
    AddressID INTEGER PRIMARY KEY AUTOINCREMENT,
    StreetAddress VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    StateProvince VARCHAR(100),
    Country VARCHAR(100) NOT NULL,
    PostalCode VARCHAR(20),
    
    -- Indexes
    INDEX idx_address_city (City),
    INDEX idx_address_country (Country)
);

-- Property Entity
CREATE TABLE Property (
    PropertyID INTEGER PRIMARY KEY AUTOINCREMENT,
    HostID INTEGER NOT NULL,
    AddressID INTEGER NOT NULL,
    Title VARCHAR(255) NOT NULL,
    Description TEXT,
    PropertyType VARCHAR(50) NOT NULL,
    PricePerNight DECIMAL(10, 2) NOT NULL CHECK (PricePerNight > 0),
    NumberOfBedrooms INTEGER NOT NULL CHECK (NumberOfBedrooms > 0),
    NumberOfBathrooms INTEGER NOT NULL CHECK (NumberOfBathrooms > 0),
    MaxGuests INTEGER NOT NULL CHECK (MaxGuests > 0),
    Status ENUM('Available', 'Booked', 'Maintenance') NOT NULL DEFAULT 'Available',
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (HostID) REFERENCES User(UserID) ON DELETE CASCADE,
    FOREIGN KEY (AddressID) REFERENCES Address(AddressID) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_property_host (HostID),
    INDEX idx_property_address (AddressID),
    INDEX idx_property_type (PropertyType),
    INDEX idx_property_price (PricePerNight),
    INDEX idx_property_status (Status)
);

-- PropertyAmenity Entity
CREATE TABLE PropertyAmenity (
    AmenityID INTEGER PRIMARY KEY AUTOINCREMENT,
    AmenityName VARCHAR(100) NOT NULL UNIQUE,
    Description TEXT,
    
    -- Indexes
    INDEX idx_amenity_name (AmenityName)
);

-- PropertyAmenityMapping Entity (for many-to-many relationship)
CREATE TABLE PropertyAmenityMapping (
    MappingID INTEGER PRIMARY KEY AUTOINCREMENT,
    PropertyID INTEGER NOT NULL,
    AmenityID INTEGER NOT NULL,
    
    -- Foreign Keys
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID) ON DELETE CASCADE,
    FOREIGN KEY (AmenityID) REFERENCES PropertyAmenity(AmenityID) ON DELETE CASCADE,
    
    -- Unique constraint to prevent duplicates
    UNIQUE (PropertyID, AmenityID),
    
    -- Indexes
    INDEX idx_mapping_property (PropertyID),
    INDEX idx_mapping_amenity (AmenityID)
);

-- PropertyAvailability Entity
CREATE TABLE PropertyAvailability (
    AvailabilityID INTEGER PRIMARY KEY AUTOINCREMENT,
    PropertyID INTEGER NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    IsAvailable BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Check constraint to ensure valid date range
    CHECK (EndDate >= StartDate),
    
    -- Foreign Keys
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_availability_property (PropertyID),
    INDEX idx_availability_dates (StartDate, EndDate)
);

-- Booking Entity
CREATE TABLE Booking (
    BookingID INTEGER PRIMARY KEY AUTOINCREMENT,
    PropertyID INTEGER NOT NULL,
    GuestID INTEGER NOT NULL,
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    TotalPrice DECIMAL(10, 2) NOT NULL CHECK (TotalPrice > 0),
    NumberOfGuests INTEGER NOT NULL CHECK (NumberOfGuests > 0),
    BookingStatus ENUM('Pending', 'Confirmed', 'Cancelled') NOT NULL DEFAULT 'Pending',
    BookingDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Check constraint to ensure valid date range
    CHECK (CheckOutDate > CheckInDate),
    
    -- Foreign Keys
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID) ON DELETE RESTRICT,
    FOREIGN KEY (GuestID) REFERENCES User(UserID) ON DELETE RESTRICT,
    
    -- Indexes
    INDEX idx_booking_property (PropertyID),
    INDEX idx_booking_guest (GuestID),
    INDEX idx_booking_dates (CheckInDate, CheckOutDate),
    INDEX idx_booking_status (BookingStatus)
);

-- Review Entity
CREATE TABLE Review (
    ReviewID INTEGER PRIMARY KEY AUTOINCREMENT,
    BookingID INTEGER NOT NULL UNIQUE, -- One review per booking
    Rating INTEGER NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment TEXT,
    ReviewDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_review_booking (BookingID),
    INDEX idx_review_rating (Rating)
);

-- Payment Entity
CREATE TABLE Payment (
    PaymentID INTEGER PRIMARY KEY AUTOINCREMENT,
    BookingID INTEGER NOT NULL UNIQUE, -- One payment per booking
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount > 0),
    PaymentDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PaymentStatus ENUM('Pending', 'Completed', 'Failed', 'Refunded') NOT NULL DEFAULT 'Pending',
    PaymentMethod VARCHAR(50) NOT NULL,
    
    -- Foreign Keys
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE RESTRICT,
    
    -- Indexes
    INDEX idx_payment_booking (BookingID),
    INDEX idx_payment_status (PaymentStatus)
);

-- Triggers for automatically updating Property.UpdatedAt
CREATE TRIGGER update_property_timestamp
AFTER UPDATE ON Property
FOR EACH ROW
BEGIN
    UPDATE Property SET UpdatedAt = CURRENT_TIMESTAMP WHERE PropertyID = OLD.PropertyID;
END;

-- Insert common amenities for testing
INSERT INTO PropertyAmenity (AmenityName, Description) VALUES
('WiFi', 'High-speed wireless internet'),
('Air Conditioning', 'Climate control system'),
('Kitchen', 'Fully equipped kitchen'),
('Free Parking', 'On-premises parking'),
('Swimming Pool', 'Access to swimming pool'),
('Gym', 'Access to fitness center'),
('TV', 'Television with streaming services'),
('Washer', 'In-unit washing machine'),
('Dryer', 'In-unit clothes dryer'),
('Heating', 'Central heating system');