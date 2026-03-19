-- 1. Tạo Database mới

CREATE DATABASE WebApp_Manage
go
use WebApp_Manage
go 

-- ========================
-- 1. Bảng Phân quyền (Roles)
-- ========================
CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE
);

-- ========================
-- 2. Bảng Nhân viên/Tài khoản (Accounts)
-- ========================
CREATE TABLE Accounts (
    AccountID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(MAX) NOT NULL,
    FullName NVARCHAR(100),
    Email NVARCHAR(100),
    RoleID INT NOT NULL,
    IsActive BIT DEFAULT 1,
    LastLogin DATETIME2,
    CreatedDate DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_Account_Role 
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);

-- ========================
-- 3.Loại thiết bị
-- ========================
CREATE TABLE DeviceTypes (
    TypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200)
);

-- ========================
-- 4.  Vị trí
-- ========================
CREATE TABLE Locations (
    LocationID INT IDENTITY(1,1) PRIMARY KEY,
    Building NVARCHAR(100) NOT NULL,
    Floor NVARCHAR(50),
    Room NVARCHAR(50),
    Rack NVARCHAR(50)
);

-- ========================
-- 5. Bảng Thiết bị (Devices)
-- ========================
CREATE TABLE Devices (
    DeviceID INT IDENTITY(1,1) PRIMARY KEY,
    DeviceName NVARCHAR(100) NOT NULL,
    DeviceTypeID INT NOT NULL,
    LocationID INT NULL,
    Manufacturer NVARCHAR(100),
    Model NVARCHAR(100),
    SerialNumber NVARCHAR(100) UNIQUE,
    MACAddress NVARCHAR(17) UNIQUE,
    FirmwareVersion NVARCHAR(50),
    Status NVARCHAR(50) DEFAULT 'Offline',
    CreatedDate DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_Device_Type 
    FOREIGN KEY (DeviceTypeID) REFERENCES DeviceTypes(TypeID),

    CONSTRAINT FK_Device_Location 
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID)
);

-- ========================
-- 6. Bảng Cấu hình mạng chi tiết (IP, Subnet, Gateway, DNS)
-- ========================
CREATE TABLE NetworkConfigs (
    ConfigID INT IDENTITY(1,1) PRIMARY KEY,
    DeviceID INT NOT NULL UNIQUE,
    IPAddress NVARCHAR(45) NOT NULL,
    SubnetMask NVARCHAR(45),
    DefaultGateway NVARCHAR(45),
    PrimaryDNS NVARCHAR(45),
    SecondaryDNS NVARCHAR(45),
    UpdatedDate DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_Config_Device 
    FOREIGN KEY (DeviceID) REFERENCES Devices(DeviceID) ON DELETE CASCADE
);

-- ========================
-- 7. Bảng Nhật ký hoạt động nhân viên
-- ========================
CREATE TABLE ActionLogs (
    LogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    AccountID INT NOT NULL,
    ActionType NVARCHAR(50),
    Description NVARCHAR(MAX),
    DeviceID INT NULL,
    LogTime DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_Log_Account 
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID),

    CONSTRAINT FK_Log_Device 
    FOREIGN KEY (DeviceID) REFERENCES Devices(DeviceID)
);

-- ========================
-- 8. Cảnh báo phiên bản
-- ========================
CREATE TABLE FirmwareStandards (
    TypeID INT PRIMARY KEY,
    LatestVersion NVARCHAR(50),
    ReleaseDate DATETIME,

    CONSTRAINT FK_Std_Type 
    FOREIGN KEY (TypeID) REFERENCES DeviceTypes(TypeID)
);

--thêm thông tin--
--role--
INSERT INTO Roles (RoleName)
VALUES 
('Admin'),
('Technician'),
('Viewer');

--account--
INSERT INTO Accounts (Username, PasswordHash, FullName, Email, RoleID)
VALUES 
('admin', '123456', 'Nguyen Van Admin', 'admin@gmail.com', 1),
('tech1', '123456', 'Tran Van Tech', 'tech@gmail.com', 2),
('viewer1', '123456', 'Le Thi Viewer', 'viewer@gmail.com', 3);

-- devicce type--
INSERT INTO DeviceTypes (TypeName, Description)
VALUES
('Router', N'Thiết bị định tuyến'),
('Switch', N'Thiết bị chuyển mạch'),
('Server', N'Máy chủ'),
('Firewall', N'Tường lửa'),
('Access Point', 'Wifi');

-- location--
INSERT INTO Locations (Building, Floor, Room, Rack)
VALUES
(N'Tòa A', '1', '101', 'Rack 1'),
(N'Tòa A', '2', '201', 'Rack 2'),
(N'Tòa B', '1', 'B101', 'Rack 3'),
('Data Center', N'Tầng 1', 'DC1', 'Rack Core');

-- divice--
INSERT INTO Devices 
(DeviceName, DeviceTypeID, LocationID, Manufacturer, Model, SerialNumber, MACAddress, FirmwareVersion, Status)
VALUES
('Router Cisco 2901', 1, 1, 'Cisco', '2901', 'SN001', 'AA:BB:CC:DD:EE:01', '1.0.0', 'Online'),

('Switch TP-Link 24 Port', 2, 2, 'TP-Link', 'TL-SG1024', 'SN002', 'AA:BB:CC:DD:EE:02', '2.1.0', 'Offline'),

('Server Dell R740', 3, 4, 'Dell', 'R740', 'SN003', 'AA:BB:CC:DD:EE:03', '3.0.2', 'Online'),

('Firewall Fortigate', 4, 4, 'Fortinet', 'FG-100E', 'SN004', 'AA:BB:CC:DD:EE:04', '6.4.5', 'Maintenance'),

('Access Point Unifi', 5, 3, 'Ubiquiti', 'UAP-AC', 'SN005', 'AA:BB:CC:DD:EE:05', '5.6.7', 'Online')

-- network config--
INSERT INTO NetworkConfigs 
(DeviceID, IPAddress, SubnetMask, DefaultGateway, PrimaryDNS, SecondaryDNS)
VALUES
(1, '192.168.1.1', '255.255.255.0', '192.168.1.254', '8.8.8.8', '8.8.4.4'),
(2, '192.168.1.2', '255.255.255.0', '192.168.1.254', '8.8.8.8', '1.1.1.1'),
(3, '192.168.1.10', '255.255.255.0', '192.168.1.254', '8.8.8.8', NULL);

--logs--
INSERT INTO ActionLogs (AccountID, ActionType, Description, DeviceID)
VALUES
(1, 'LOGIN', N'Admin đăng nhập hệ thống', NULL),
(2, 'CHANGE_IP', N'Đổi IP Router', 1),
(2, 'REBOOT_DEVICE', N'Khởi động lại Switch', 2),
(3, 'VIEW', N'Xem danh sách thiết bị', NULL);

--cảnh báo phiên bản--
INSERT INTO FirmwareStandards (TypeID, LatestVersion, ReleaseDate)
VALUES
(1, '1.2.0', GETDATE()),
(2, '2.5.0', GETDATE()),
(3, '3.1.0', GETDATE());
 -- thông tin thiết bị mạng--
USE WebApp_Manage; -- Quan trọng: Trỏ về đúng DB của bạn
GO

SELECT 
    d.DeviceID, 
    d.DeviceName, 
    dt.TypeName, 
    l.Room, 
    nc.IPAddress, 
    fs.LatestVersion
FROM Devices d
LEFT JOIN DeviceTypes dt ON d.DeviceTypeID = dt.TypeID
LEFT JOIN Locations l ON d.LocationID = l.LocationID
LEFT JOIN NetworkConfigs nc ON d.DeviceID = nc.DeviceID
LEFT JOIN FirmwareStandards fs ON d.DeviceTypeID = fs.TypeID;

-- kiểm tra email vừa tạo--
--SELECT * FROM Accounts WHERE Email = 'email_ban_vua_dang_ky@gmail.com'--