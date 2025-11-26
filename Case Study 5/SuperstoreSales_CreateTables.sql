CREATE TABLE Customer (
    ID           VARCHAR(10)      PRIMARY KEY,
    FirstName    VARCHAR(50),
    LastName     VARCHAR(50),
    Email        VARCHAR(100),
    City         VARCHAR(100),
    State        VARCHAR(100),
    Country      VARCHAR(100),
    Region       VARCHAR(50)
);


CREATE TABLE Products (
    ProductID     VARCHAR(20)     PRIMARY KEY,
    Category      VARCHAR(50),
    SubCategory   VARCHAR(50),
    ProductName   VARCHAR(200),
    Manufacturer  VARCHAR(100),
    Price         DECIMAL(12,2)
);


CREATE TABLE Shipping (
    ShippingID     VARCHAR(10)     PRIMARY KEY,
    ShipMode       VARCHAR(50),
    ShippingCost   DECIMAL(10,2),
    Carrier        VARCHAR(50)
);

CREATE TABLE Sales (
    OrderID      VARCHAR(20),
    CustomerID   VARCHAR(10),
    ProductID    VARCHAR(20),
    Quantity     INT,
    Price        DECIMAL(12,2),
    Discount     DECIMAL(5,2),
    Profit       DECIMAL(12,2),
    OrderDate    DATE,
	ShipDate    DATE,
    ShippingID   VARCHAR(10),

    FOREIGN KEY (CustomerID) REFERENCES Customer(ID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (ShippingID) REFERENCES Shipping(ShippingID)
);

CREATE TABLE TargetSales (
    Category      VARCHAR(50),
    [2020_Sales]  INT,
    [2021_Sales]  INT,
    [2022_Sales]  INT,
    [2023_Sales]  INT
);
