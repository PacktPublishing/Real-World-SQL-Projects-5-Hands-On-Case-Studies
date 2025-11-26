-- Create Airports Table
CREATE TABLE Airports (
    AirportID INT PRIMARY KEY,
    Name VARCHAR(100),
    Location VARCHAR(100),
    Country VARCHAR(50)
);

-- Create Airlines Table
CREATE TABLE Airlines (
    AirlineID INT PRIMARY KEY,
    Name VARCHAR(100),
    Country VARCHAR(50)
);

-- Create Flights Table
CREATE TABLE Flights (
    FlightID INT PRIMARY KEY,
    Origin INT REFERENCES Airports(AirportID),
    Destination INT REFERENCES Airports(AirportID),
    DepartureTime DATETIME,
    ArrivalTime DATETIME,
    AirlineID INT REFERENCES Airlines(AirlineID)
);

-- Create Passengers Table
CREATE TABLE Passengers (
    PassengerID INT PRIMARY KEY,
    Name VARCHAR(100),
    DOB DATE,
    FrequentFlyerStatus VARCHAR(50)
);

-- Create Tickets Table
CREATE TABLE Tickets (
    TicketID INT PRIMARY KEY,
    PassengerID INT REFERENCES Passengers(PassengerID),
    FlightID INT REFERENCES Flights(FlightID),
    Price DECIMAL(10, 2)
);


INSERT INTO Airports (AirportID, Name, Location, Country) VALUES
(1, 'Indira Gandhi International Airport', 'Delhi', 'India'),
(2, 'Chhatrapati Shivaji Maharaj International Airport', 'Mumbai', 'India'),
(3, 'Heathrow Airport', 'London', 'UK'),
(4, 'John F. Kennedy International Airport', 'New York', 'USA'),
(5, 'Dubai International Airport', 'Dubai', 'UAE');


INSERT INTO Airlines (AirlineID, Name, Country) VALUES
(1, 'Air India', 'India'),
(2, 'British Airways', 'UK'),
(3, 'Emirates', 'UAE'),
(4, 'Delta Airlines', 'USA'),
(5, 'IndiGo', 'India');


INSERT INTO Flights (FlightID, Origin, Destination, DepartureTime, ArrivalTime, AirlineID) VALUES
(101, 1, 3, '2025-08-01 06:00', '2025-08-01 12:00', 1),
(102, 2, 4, '2025-08-02 10:00', '2025-08-02 20:00', 4),
(103, 5, 2, '2025-08-03 05:30', '2025-08-03 09:30', 3),
(104, 3, 1, '2025-08-04 13:00', '2025-08-04 21:00', 2),
(105, 4, 5, '2025-08-05 08:00', '2025-08-05 16:00', 4),
(106, 1, 2, '2025-08-06 07:00', '2025-08-06 09:00', 5),
(107, 2, 5, '2025-08-07 18:00', '2025-08-07 22:30', 1),
(108, 5, 1, '2025-08-08 03:00', '2025-08-08 09:00', 3),
(109, 4, 3, '2025-08-09 14:00', '2025-08-09 22:00', 4),
(110, 3, 5, '2025-08-10 11:00', '2025-08-10 19:00', 2),
(111, 2, 1, '2025-08-11 05:30', '2025-08-11 07:30', 5),
(112, 1, 4, '2025-08-12 06:45', '2025-08-12 14:45', 1),
(113, 4, 2, '2025-08-13 08:00', '2025-08-13 16:30', 4),
(114, 3, 2, '2025-08-14 10:15', '2025-08-14 18:15', 2),
(115, 5, 4, '2025-08-15 23:30', '2025-08-16 07:30', 3),
(116, 1, 2, '2025-08-16 10:00', '2025-08-16 11:55', 1);


INSERT INTO Passengers (PassengerID, Name, DOB, FrequentFlyerStatus) VALUES
(201, 'Aarav Sharma', '1985-06-15', 'Gold'),
(202, 'Meera Iyer', '1990-09-21', 'Silver'),
(203, 'Kabir Joshi', '1995-12-11', 'Platinum'),
(204, 'Ananya Reddy', '1988-03-19', 'None'),
(205, 'Rohan Mehta', '1992-07-02', 'Gold'),
(206, 'Diya Kapoor', '2000-05-23', 'None'),
(207, 'Vikram Sinha', '1983-10-12', 'Silver'),
(208, 'Sanya Arora', '1991-01-29', 'Gold'),
(209, 'Arjun Patel', '1994-04-18', 'None'),
(210, 'Neha Das', '1987-08-30', 'Platinum'),
(211, 'Rahul Verma', '1996-06-05', 'Silver'),
(212, 'Pooja Nair', '1989-11-25', 'None'),
(213, 'Kunal Rao', '1993-03-17', 'Gold'),
(214, 'Ishita Ghosh', '1998-09-09', 'Silver'),
(215, 'Manav Bhatia', '1986-12-01', 'Platinum'),
(216, 'Riya Jain', '1997-07-27', 'None'),
(217, 'Yash Malhotra', '1984-02-13', 'Gold'),
(218, 'Tanvi Shetty', '1990-10-03', 'Silver'),
(219, 'Siddharth Kulkarni', '1999-01-14', 'None'),
(220, 'Aisha Qureshi', '1992-05-09', 'Gold'),
(221, 'Nikhil Chopra', '1985-03-20', 'Silver'),
(222, 'Swati Aggarwal', '1993-06-22', 'None'),
(223, 'Devansh Saxena', '1991-04-07', 'Platinum'),
(224, 'Sneha Pillai', '1994-12-19', 'Gold'),
(225, 'Tanishq Goel', '1995-08-11', 'Silver');


INSERT INTO Tickets (TicketID, PassengerID, FlightID, Price) VALUES
(301, 201, 101, 6500.00),
(302, 202, 102, 7200.00),
(303, 203, 103, 8500.00),
(304, 204, 104, 9200.00),
(305, 205, 105, 4500.00),
(306, 206, 106, 3200.00),
(307, 207, 107, 6100.00),
(308, 208, 108, 8900.00),
(309, 209, 109, 5100.00),
(310, 210, 110, 9600.00),
(311, 211, 101, 7300.00),
(312, 212, 102, 4700.00),
(313, 213, 103, 8800.00),
(314, 214, 104, 5300.00),
(315, 215, 105, 7600.00),
(316, 216, 106, 8100.00),
(317, 217, 107, 9900.00),
(318, 218, 108, 3400.00),
(319, 219, 109, 3900.00),
(320, 220, 110, 5600.00),
(321, 221, 101, 9200.00),
(322, 222, 102, 2900.00),
(323, 223, 103, 10400.00),
(324, 224, 104, 3300.00),
(325, 225, 105, 4100.00),
(326, 201, 106, 5200.00),
(327, 202, 107, 6200.00),
(328, 203, 108, 5800.00),
(329, 204, 109, 4700.00),
(330, 205, 110, 8200.00),
(331, 206, 101, 7900.00),
(332, 207, 102, 6500.00),
(333, 208, 103, 8700.00),
(334, 209, 104, 3300.00),
(335, 210, 105, 5500.00),
(336, 211, 106, 6300.00),
(337, 212, 107, 3100.00),
(338, 213, 108, 7100.00),
(339, 214, 109, 4600.00),
(340, 215, 110, 8800.00),
(341, 216, 101, 5700.00),
(342, 217, 102, 6200.00),
(343, 218, 103, 4300.00),
(344, 219, 104, 6500.00),
(345, 220, 105, 7900.00),
(346, 221, 106, 9700.00),
(347, 202, 107, 3600.00),
(348, 223, 108, 7100.00),
(349, 224, 109, 8300.00),
(350, 225, 110, 5100.00),
(351, 201, 101, 5900.00),
(352, 202, 102, 9900.00),
(353, 203, 103, 10400.00),
(354, 204, 104, 6800.00);
