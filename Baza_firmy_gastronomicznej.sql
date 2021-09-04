use u_maruszak
GO
------------------------------------------------------------------------------------FUNKCJE---------------------------------------------------------------------------------

IF OBJECT_ID('Calculate_Discount_For_The_Number_Of_Orders') IS NOT NULL
DROP FUNCTION Calculate_Discount_For_The_Number_Of_Orders 
GO
CREATE FUNCTION dbo.Calculate_Discount_For_The_Number_Of_Orders (@Amount int, @price money)
RETURNS decimal(5,2)
AS BEGIN
DECLARE @AmountOfDiscount decimal(5,2)
IF (@Amount > 10)
BEGIN     
	SET @AmountOfDiscount = (@Amount * @price)/100
END
ELSE
BEGIN
SET @AmountOfDiscount =NULL
END
    RETURN @AmountOfDiscount
END
GO


IF OBJECT_ID('Calculate_Discount_For_The_Number_Of_Days') IS NOT NULL
DROP FUNCTION Calculate_Discount_For_The_Number_Of_Days 
GO

CREATE FUNCTION dbo.Calculate_Discount_For_The_Number_Of_Days  (@price money, @numDays int)
RETURNS decimal(5,2)
AS BEGIN
DECLARE @AmountOfDiscount decimal(5,2)
IF (@numDays=7)
BEGIN     
	SET @AmountOfDiscount = 5.00
END
ELSE
BEGIN
SET @AmountOfDiscount = NULL
END
    RETURN @AmountOfDiscount
END
GO

---------------------------------------------------------------------------------TABELE-----------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.[Tables]', 'U') IS NOT NULL
    DROP TABLE dbo.[Tables];

CREATE TABLE [Tables]( 
	TableID int NOT NULL ,
	NumberOfSeats int NOT NULL,
	TableNumber int UNIQUE  NOT NULL,
	CONSTRAINT PK_tables PRIMARY KEY CLUSTERED (TableID ASC),
	CONSTRAINT Table_Number_Tables CHECK (TableNumber > 0),
	CONSTRAINT Number_Of_Seats_Tables CHECK (NumberOfSeats >= 2)


)

IF OBJECT_ID('dbo.Company', 'U') IS NOT NULL
    DROP TABLE dbo.Company;

CREATE TABLE Company (
	CompanyID     int IDENTITY (1, 1) NOT NULL,
	CompanyName    nvarchar(50) NOT NULL ,
	CompanyPhone   nvarchar(50) NOT NULL ,
	CompanyEmail  nvarchar(50) NOT NULL ,
	CompanyAddress nvarchar(50) NOT NULL ,

	CONSTRAINT PK_Supplier PRIMARY KEY CLUSTERED (CompanyID ASC),
	CONSTRAINT AK1_Supplier_CompanyName UNIQUE NONCLUSTERED (CompanyName ASC),
	CONSTRAINT Check_Email_Com CHECK (CompanyEmail LIKE '%_@_%._%')
)

IF OBJECT_ID('dbo.IndividualCustomer', 'U') IS NOT NULL
    DROP TABLE dbo.IndividualCustomer;

CREATE TABLE IndividualCustomer (
	CustomerID int IDENTITY (1, 1) NOT NULL,
	FirstName nvarchar(50) NOT NULL ,
	LastName nvarchar(50) NOT NULL ,
	Phone_no  nvarchar(20) NOT NULL CONSTRAINT [DF_IndividualCustomer_Phone_no] DEFAULT ((0)) ,
	[Address] nvarchar(50) NULL ,
	Email    nvarchar(50) NOT NULL ,

	CONSTRAINT PK_Product PRIMARY KEY CLUSTERED (CustomerID ASC),
	CONSTRAINT AK1_Product_SupplierId_ProductName UNIQUE NONCLUSTERED (FirstName ASC),
	CONSTRAINT Check_Email_IC CHECK (Email LIKE '%_@_%._%')
)

IF OBJECT_ID('dbo.RestaurantWorker', 'U') IS NOT NULL
    DROP TABLE dbo.RestaurantWorker;

CREATE TABLE RestaurantWorker (
	WorkerID int IDENTITY (1, 1) NOT NULL ,
	CONSTRAINT PK_workers PRIMARY KEY CLUSTERED (WorkerID ASC)
)

IF OBJECT_ID('dbo.Reservation', 'U') IS NOT NULL
    DROP TABLE dbo.Reservation;

CREATE TABLE Reservation (
	ReservationID     int NOT NULL,
	ReservationByPhone nvarchar(50) NULL ,
	ReservationDate   nvarchar(50) NOT NULL ,
	CompanyID         int NULL ,
	CustomerID         int NULL ,
	WorkerID          int NOT NULL ,
	OnilneReservation  nvarchar(50) NULL ,
	TableID           int NOT NULL ,
	CompanyEmployeeID int NULL,
	CancelDate date NULL

	CONSTRAINT PK_reservation PRIMARY KEY CLUSTERED (ReservationID ASC),
	CONSTRAINT FK_company_res FOREIGN KEY (CompanyID)  REFERENCES Company(CompanyID),
	CONSTRAINT FK_individual_customer_res FOREIGN KEY (CustomerID)  REFERENCES IndividualCustomer(CustomerID),
	CONSTRAINT FK_restaurant_worker_res FOREIGN KEY (WorkerID)  REFERENCES RestaurantWorker(WorkerID),
	CONSTRAINT FK_table_res FOREIGN KEY (TableID)  REFERENCES [Tables](TableID),
	CONSTRAINT FK_company_em FOREIGN KEY (CompanyEmployeeID)  REFERENCES  CompanyEmployee( CompanyEmployeeID)	
)
GO
CREATE NONCLUSTERED INDEX fkIdx_company_res ON Reservation (
  CompanyID ASC
 )

GO

CREATE NONCLUSTERED INDEX fkIdx_individual_customer_res ON Reservation (
  CustomerID ASC
 )

GO

CREATE NONCLUSTERED INDEX fkIdx_restaurant_worker_res ON Reservation (
  WorkerID ASC
 )

GO

CREATE NONCLUSTERED INDEX fkIdx_table_res ON Reservation (
  TableID ASC
 )

GO

CREATE NONCLUSTERED INDEX fkIdx_company_em ON Reservation (
  CompanyEmployeeID ASC
 )

GO
ALTER TABLE dbo.Reservation  
DROP CONSTRAINT FK_company_res;
ALTER TABLE dbo.Reservation  
DROP CONSTRAINT FK_individual_customer_res;
ALTER TABLE dbo.Reservation  
DROP CONSTRAINT FK_restaurant_worker_res;
ALTER TABLE dbo.Reservation  
DROP CONSTRAINT FK_table_res; 
ALTER TABLE dbo.Reservation  
DROP CONSTRAINT FK_company_em; 


IF OBJECT_ID('dbo.Menu', 'U') IS NOT NULL
    DROP TABLE dbo.Menu;
	
CREATE TABLE Menu (
	MenuID     int NOT NULL ,
	MenuVersion nvarchar(50) NOT NULL ,

	CONSTRAINT PK_menu PRIMARY KEY CLUSTERED (MenuID ASC)
)

IF OBJECT_ID('dbo.SeaFoodDishes', 'U') IS NOT NULL
    DROP TABLE dbo.SeaFoodDishes;

CREATE TABLE SeaFoodDishes (
	SeaFoodID               int NOT NULL ,
	PossibleDaysToOrder     nvarchar(50) NOT NULL ,
	DepletionOfIntermediates bit NOT NULL ,

	CONSTRAINT PK_SeaFoodDishes PRIMARY KEY CLUSTERED (SeaFoodID ASC)
	
)

IF OBJECT_ID('dbo.MenuItems', 'U') IS NOT NULL
    DROP TABLE dbo.MenuItems;

CREATE TABLE MenuItems (
	ItemID        int NOT NULL ,
	ItemName       nvarchar(50) NOT NULL ,
	ItemDescription nvarchar(100) NOT NULL ,
	ItemPrice       money NOT NULL ,
	MenuID          int NOT NULL ,
	SeaFoodID      int  NULL ,


	CONSTRAINT PK_menuitems PRIMARY KEY CLUSTERED (ItemID ASC),
	CONSTRAINT FK_menu_id FOREIGN KEY (MenuID)  REFERENCES Menu(MenuID),
	CONSTRAINT FK_sea_food_id FOREIGN KEY (SeaFoodID)  REFERENCES SeaFoodDishes(SeaFoodID),
	CONSTRAINT Check_Price_MI CHECK (ItemPrice > 0)
	 
)
GO

CREATE NONCLUSTERED INDEX fkIdx_menu_id ON MenuItems (
  MenuID ASC
 )

GO

CREATE NONCLUSTERED INDEX fkIdx_sea_food_id ON MenuItems (
  SeafoodID ASC
 )

GO

ALTER TABLE dbo.MenuItems  
DROP CONSTRAINT FK_menu_id;
ALTER TABLE dbo.MenuItems  
DROP CONSTRAINT FK_sea_food_id;


IF OBJECT_ID('dbo.Payments', 'U') IS NOT NULL
    DROP TABLE dbo.Payments;

CREATE TABLE Payments (
 PaymentID         int NOT NULL ,
 CashPayment        bit NULL ,
 BankTransferPayment bit NULL ,
 CardPayment       bit  NULL ,
 PaymentDate       nvarchar(50) NULL,
 PaymentCancelDate date NULL


 CONSTRAINT PK_payments PRIMARY KEY CLUSTERED (PaymentID ASC),
 CONSTRAINT payment_check CHECK((CashPayment='FALSE' AND BankTransferPayment='FALSE' AND CardPayment='TRUE') OR (CashPayment='FALSE' AND BankTransferPayment='TRUE' AND CardPayment='FALSE') OR
 (CashPayment='TRUE' AND BankTransferPayment='FALSE' AND CardPayment='FALSE'))
)

IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL
    DROP TABLE dbo.Orders;

CREATE TABLE Orders (
 OrderID          int IDENTITY (1, 1) NOT NULL ,
 CompanyEmployeeID int  NULL ,
 OrderDate         nvarchar(50) NULL ,
 CustomerID        int NULL ,
 CompanyID         int NULL ,
 OrderStatus       nvarchar(50) NOT NULL ,
 PaymentID         int NOT NULL ,
 ApprovedOrderID   bit NOT NULL ,
 OrderTypeName     nvarchar(50) NOT NULL ,
 WorkerID         int NOT NULL ,


 CONSTRAINT PK_Order PRIMARY KEY CLUSTERED (OrderId ASC),
 CONSTRAINT FK_customer_id FOREIGN KEY (CustomerID)  REFERENCES IndividualCustomer(CustomerID),
 CONSTRAINT FK_company_em_id FOREIGN KEY (CompanyEmployeeID)  REFERENCES CompanyEmployee(CompanyEmployeeID),
 CONSTRAINT FK_company_id_orders FOREIGN KEY (CompanyID)  REFERENCES Company(CompanyID),
 CONSTRAINT FK_payment_id FOREIGN KEY (PaymentID)  REFERENCES Payments(PaymentID),
 CONSTRAINT FK_worker_id FOREIGN KEY (WorkerID)  REFERENCES RestaurantWorker(WorkerID)
)
GO

CREATE NONCLUSTERED INDEX fkIdx_customer_id ON Orders (
  CustomerID ASC
 )

GO

CREATE NONCLUSTERED INDEX fkIdx_company_em_id ON Orders (
  CompanyEmployeeID ASC
 )

GO

CREATE NONCLUSTERED INDEX fkIdx_company_id_orders ON Orders (
  CompanyID ASC
 )

GO

CREATE NONCLUSTERED INDEX fkIdx_payment_id ON Orders (
  PaymentID ASC
 )

GO

CREATE NONCLUSTERED INDEX fkIdx_worker_id ON Orders (
  WorkerID ASC
 )

GO
ALTER TABLE dbo.Orders 
DROP CONSTRAINT FK_customer_id;
ALTER TABLE dbo.Orders 
DROP CONSTRAINT FK_company_em_id;
ALTER TABLE dbo.Orders  
DROP CONSTRAINT FK_company_id_orders;
ALTER TABLE dbo.Orders  
DROP CONSTRAINT FK_payment_id;
ALTER TABLE dbo.Orders  
DROP CONSTRAINT FK_worker_id;

IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL
    DROP TABLE dbo.OrderDetails;

CREATE TABLE OrderDetails (
 OrderID    int NOT NULL ,
 ItemID    int NOT NULL , 
 Amount     int NOT NULL ,
 UnitPrice  decimal(12,2) NOT NULL ,
 AmountOfOrders int NOT NULL,
 Discount decimal(5,2) NULL ,
 NumberOfDaysOfPlacedOrders int NULL, 


 CONSTRAINT PK_OrderItem PRIMARY KEY CLUSTERED (OrderID ASC, ItemID ASC),
 CONSTRAINT FK_order_id FOREIGN KEY (OrderID)  REFERENCES Orders(OrderID),
 CONSTRAINT FK_item_id FOREIGN KEY (ItemID)  REFERENCES MenuItems(ItemID),
 CONSTRAINT Check_Amount_OD CHECK (Amount > 0),
 CONSTRAINT Check_UnitProce_OD CHECK (UnitPrice > 0),
 CONSTRAINT Check_Amount_Of_Orders_OD CHECK (AmountOfOrders > 0)
)
GO

CREATE NONCLUSTERED INDEX fkIdx_order_id ON OrderDetails (
  OrderID ASC
 )

GO

CREATE NONCLUSTERED INDEX fkIdx_item_id ON OrderDetails (
  ItemID ASC
 )

GO
ALTER TABLE dbo.OrderDetails 
DROP CONSTRAINT FK_order_id;
ALTER TABLE dbo.OrderDetails  
DROP CONSTRAINT FK_item_id;


IF OBJECT_ID('dbo.Manager', 'U') IS NOT NULL
    DROP TABLE dbo.Manager;

CREATE TABLE Manager (
 ManagerID int IDENTITY (1, 1) NOT NULL ,

 CONSTRAINT PK_manager PRIMARY KEY CLUSTERED (ManagerID ASC)
)

IF OBJECT_ID('dbo.RestaurantEmployees', 'U') IS NOT NULL
    DROP TABLE dbo.RestaurantEmployees;

CREATE TABLE RestaurantEmployees (
 WorkerID int NOT NULL ,
 ManagerID int  NOT NULL ,
 FirstName nvarchar(50) NOT NULL ,
 LastName  nvarchar(50) NOT NULL ,
 HireDate  date NULL ,
 [Address]   nvarchar(50) NOT NULL ,
 HomePhone nvarchar(50)  NULL ,


 CONSTRAINT PK_restaurantemployee PRIMARY KEY CLUSTERED (WorkerID ASC, ManagerID ASC),
 CONSTRAINT FK_worker_id FOREIGN KEY (WorkerID)  REFERENCES RestaurantWorker(WorkerID),
 CONSTRAINT FK_manager_id FOREIGN KEY (ManagerID)  REFERENCES Manager(ManagerID)
 )
 GO

 CREATE NONCLUSTERED INDEX fkIdx_worker_id ON RestaurantEmployees (
  WorkerID ASC
 )

GO

CREATE NONCLUSTERED INDEX fkIdx_manager_id ON RestaurantEmployees (
  ManagerID ASC
 )

GO
ALTER TABLE dbo.RestaurantEmployees 
DROP CONSTRAINT FK_worker_id;
ALTER TABLE dbo.RestaurantEmployees 
DROP CONSTRAINT FK_manager_id;

IF OBJECT_ID('dbo.Reports', 'U') IS NOT NULL
    DROP TABLE dbo.Reports;

CREATE TABLE Reports (
 ReportID   int NOT NULL ,
 ManagerID  int NOT NULL ,
 CompanyID int NULL ,
 CustomerID int  NULL ,
 ReportDate nvarchar(50)  NULL ,


 CONSTRAINT PK_reports PRIMARY KEY CLUSTERED (ReportID ASC),
 CONSTRAINT FK_manager_id FOREIGN KEY (ManagerID)  REFERENCES Manager(ManagerID),
 CONSTRAINT FK_company_id_reports FOREIGN KEY (CompanyID)  REFERENCES Company(CompanyID),
 CONSTRAINT FK_customer_id FOREIGN KEY (CustomerID)  REFERENCES IndividualCustomer(CustomerID)
)
GO

CREATE NONCLUSTERED INDEX fkIdx_manager_id ON Reports (
  ManagerID ASC
 )

GO

CREATE NONCLUSTERED INDEX fkIdx_company_id_reports ON Reports (
  CompanyID ASC
 )

GO

CREATE NONCLUSTERED INDEX fkIdx_customer_id ON Reports (
  CustomerID ASC
 )

GO
ALTER TABLE dbo.Reports 
DROP CONSTRAINT FK_manager_id;
ALTER TABLE dbo.Reports 
DROP CONSTRAINT FK_company_id_reports;
ALTER TABLE dbo.Reports 
DROP CONSTRAINT FK_customer_id;

IF OBJECT_ID('dbo.Invoices', 'U') IS NOT NULL
    DROP TABLE dbo.Invoices;

CREATE TABLE Invoices (
 InvoiceID         int NOT NULL ,
 SingleInvoice     bit  NULL ,
 CompanyID        int NOT NULL ,
 ManagerID         int NOT NULL ,
 InvoiceDate       nvarchar(50) NULL ,
 CollectiveInvoice bit  NULL ,


 CONSTRAINT PK_invoices PRIMARY KEY CLUSTERED (InvoiceID ASC),
 CONSTRAINT FK_company_id_invoices FOREIGN KEY (CompanyID)  REFERENCES Company(CompanyID),
 CONSTRAINT FK_manager_id FOREIGN KEY (ManagerID)  REFERENCES Manager(ManagerID)
)
GO
CREATE NONCLUSTERED INDEX fkIdx_company_id_invoices ON Invoices (
  CompanyID ASC
 )

GO

CREATE NONCLUSTERED INDEX fkIdx_manager_id ON Invoices (
  ManagerID ASC
 )

GO
ALTER TABLE dbo.Invoices 
DROP CONSTRAINT FK_company_id_invoices;
ALTER TABLE dbo.Invoices 
DROP CONSTRAINT FK_manager_id;

IF OBJECT_ID('dbo.CompanyEmployee', 'U') IS NOT NULL
    DROP TABLE dbo.CompanyEmployee;

CREATE TABLE CompanyEmployee (
 CompanyEmployeeID int IDENTITY (1, 1) NOT NULL ,
 FirstName        nvarchar(40) NOT NULL ,
 LastName          nvarchar(20) NOT NULL ,
 Phone            nvarchar(20) NOT NULL ,
 Email            nvarchar(50) NOT NULL ,
 CompanyID        int NOT NULL ,


 CONSTRAINT PK_Customer PRIMARY KEY CLUSTERED (CompanyEmployeeID ASC),
 CONSTRAINT AK1_Customer_CustomerName UNIQUE NONCLUSTERED (FirstName ASC),
 CONSTRAINT FK_company_id_company_em FOREIGN KEY (CompanyID)  REFERENCES Company(CompanyID),
 CONSTRAINT CheckEmail_CE CHECK(Email LIKE '%_@_%._%')
)
GO
CREATE NONCLUSTERED INDEX fkIdx_company_id_company_em ON CompanyEmployee (
  CompanyID ASC
 )

GO
ALTER TABLE dbo.CompanyEmployee
DROP CONSTRAINT FK_company_id_company_em;



-----------------------------------------------------------------------PROCEDURY DO DODAWANIA DANYCH--------------------------------------------------------------------------------

IF OBJECT_ID('Add_Table') IS NOT NULL 
DROP PROC Add_Table;
GO

CREATE PROCEDURE dbo.Add_Table  @TableID int , @NumberOfSeats int , @TableNumber int AS 
BEGIN 
     SET NOCOUNT ON 

     INSERT INTO dbo.[Tables]
          (                    
            TableID,                    
            NumberOfSeats,                   
            TableNumber                 
          ) 
     VALUES 
          ( 
             @TableID,
            @NumberOfSeats,
            @TableNumber
          ) 

END 
GO


IF OBJECT_ID('Add_Company') IS NOT NULL 
DROP PROC Add_Company;
GO

CREATE PROCEDURE dbo.Add_Company  @CompanyID int , @CompanyName nvarchar(50) , @CompanyPhone  nvarchar(50), @CompanyEmail nvarchar(50), @CompanyAddress nvarchar(50)  AS 
BEGIN 
     SET NOCOUNT ON 
	 SET IDENTITY_INSERT dbo.Company ON
     INSERT INTO dbo.Company
          (                    
            CompanyID,
			CompanyName,
			CompanyPhone,
			CompanyEmail,
			CompanyAddress                
          ) 
     VALUES 
          ( 
            @CompanyID,
			@CompanyName,
			@CompanyPhone,
			@CompanyEmail,
			@CompanyAddress 
          ) 
	SET IDENTITY_INSERT dbo.Company OFF

END 
GO

IF OBJECT_ID('Add_Individual_Customer') IS NOT NULL 
DROP PROC Add_Individual_Customer;
GO


CREATE PROCEDURE dbo.Add_Individual_Customer  @CustomerID int , @FirstName nvarchar(50) , @LastName  nvarchar(50), @Phone_no nvarchar(50), @Address nvarchar(50), @Email nvarchar(50) AS 
BEGIN 
     SET NOCOUNT ON 
	 SET IDENTITY_INSERT dbo.IndividualCustomer ON
     INSERT INTO dbo.IndividualCustomer
          (                    
            CustomerID,
			FirstName,
			LastName,
			Phone_no,
			[Address],
			 Email                  
          ) 
     VALUES 
          ( 
            @CustomerID,
			@FirstName,
			@LastName,
			@Phone_no,
			@Address,
			@Email
          ) 
	SET IDENTITY_INSERT dbo.IndividualCustomer OFF

END 
GO

IF OBJECT_ID('Add_Restaurant_Worker') IS NOT NULL 
DROP PROC Add_Restaurant_Worker;
GO


CREATE PROCEDURE dbo.Add_Restaurant_Worker  @WorkerID int  AS 
BEGIN 
     SET NOCOUNT ON 
	 SET IDENTITY_INSERT dbo.RestaurantWorker ON
     INSERT INTO dbo.RestaurantWorker
          (                    
            WorkerID
			                  
          ) 
     VALUES 
          ( 
            @WorkerID
			
          ) 
	SET IDENTITY_INSERT dbo.RestaurantWorker OFF

END 
GO

IF OBJECT_ID('Add_Reservation') IS NOT NULL 
DROP PROC Add_Reservation;
GO

CREATE PROCEDURE dbo.Add_Reservation 
@ReservationID int ,
@ReservationDate nvarchar(50) ,
@FirstNameIC nvarchar(50) =NULL,
@LastNameIC nvarchar(50)=NULL,
@CompanyName nvarchar(50)=NULL, 
@Worker  int=NULL,
@TableNumber int,
@FirstNameCE  nvarchar(50) = NULL,
@LastNameCE nvarchar(50) =NULL
AS 
BEGIN 
     SET NOCOUNT ON 
	 DECLARE @CustomerID AS int
		SET @CustomerID = (
			SELECT CustomerID 
			FROM IndividualCustomer
			WHERE FirstName = @FirstNameIC AND LastName=@LastNameIC		
		)
	DECLARE @CompanyID AS int
		SET @CompanyID = (
			SELECT CompanyID 
			FROM Company
			WHERE CompanyName=@CompanyName	
		)
	DECLARE @WorkerID AS int
		SET @WorkerID = (
			SELECT WorkerID 
			FROM RestaurantWorker
			WHERE WorkerID=@Worker	
		)
	DECLARE @TableID AS int
		SET @TableID = (
			SELECT TableID 
			FROM [Tables]
			WHERE TableNumber=@TableNumber
		)
	DECLARE @CompanyEmplID AS int
		SET @CompanyEmplID  = (
			SELECT CompanyEmployeeID 
			FROM CompanyEmployee
			WHERE FirstName=@FirstNameCE AND LastName=@LastNameCE
		)
	DECLARE @ReservationByPhone AS nvarchar(50) = NULL
	IF @CompanyID IS NULL AND @CustomerID IS NULL AND @CompanyEmplID IS NOT NULL
	BEGIN
		SET @ReservationByPhone  = (
			SELECT Phone  
			FROM CompanyEmployee
			WHERE CompanyEmployeeID=@CompanyEmplID
		)
	END
	ELSE IF @CompanyID IS NULL AND @CustomerID IS NOT NULL AND @CompanyEmplID IS  NULL
	BEGIN
		SET @ReservationByPhone  = (
			SELECT Phone_no 
			FROM IndividualCustomer
			WHERE CustomerID=@CustomerID
			
		)
	END
	ELSE IF @CompanyID IS NOT NULL AND @CustomerID IS  NULL AND @CompanyEmplID IS  NULL
	BEGIN
		SET  @ReservationByPhone  = (
			SELECT CompanyPhone 
			FROM Company
			WHERE CompanyID=@CompanyID
		)	 
	END
	DECLARE @OnlineResrvationName AS nvarchar(50) = NULL
	IF @CompanyID IS NULL AND @CustomerID IS NULL AND @CompanyEmplID IS NOT NULL
	BEGIN
		SET @OnlineResrvationName  = (
			SELECT FirstName+ ' ' + LastName  
			FROM CompanyEmployee
			WHERE FirstName=@FirstNameCE AND LastName=@LastNameCE
		)
	END
	ELSE IF @CompanyID IS NULL AND @CustomerID IS NOT NULL AND @CompanyEmplID IS  NULL
	BEGIN
		SET @OnlineResrvationName  = (
			SELECT FirstName+ ' ' + LastName 
			FROM IndividualCustomer
			WHERE FirstName = @FirstNameIC AND LastName=@LastNameIC	
		)
	END
	ELSE IF @CompanyID IS NOT NULL AND @CustomerID IS  NULL AND @CompanyEmplID IS  NULL
	BEGIN
		SET @OnlineResrvationName  = (
			SELECT CompanyName 
			FROM Company
			WHERE CompanyName=@CompanyName	
		)	 
	END
     INSERT INTO dbo.Reservation
          (                    
            ReservationID,    
			ReservationByPhone, 
			ReservationDate,   
			CompanyID,         
			CustomerID,         
			WorkerID,         
			OnilneReservation,  
			TableID,           
			CompanyEmployeeID                   
          ) 
     VALUES 
          ( 
            @ReservationID,    
			@ReservationByPhone, 
			@ReservationDate,   
			@CompanyID,         
			@CustomerID,         
			@WorkerID, 
			@OnlineResrvationName,
			@TableID,			
			@CompanyEmplID
          ) 

END 
GO

IF OBJECT_ID('Add_Menu') IS NOT NULL 
DROP PROC Add_Menu;
GO

CREATE PROCEDURE dbo.Add_Menu @MenuID int , @MenuVersion nvarchar(50)  AS 
BEGIN 
     SET NOCOUNT ON 
	 
     INSERT INTO dbo.Menu
          (                    
            MenuID,    
			MenuVersion 
			               
          ) 
     VALUES 
          ( 
            @MenuID,    
			@MenuVersion
          ) 
	

END 
GO

IF OBJECT_ID('Add_SeaFoodDishes') IS NOT NULL 
DROP PROC Add_SeaFoodDishes;
GO 

CREATE PROCEDURE dbo.Add_SeaFoodDishes  @SeaFoodID int , @PossibleDaysToOrder nvarchar(50), @DepletionOfIntermediates bit  AS 
BEGIN 
     SET NOCOUNT ON 
	 
     INSERT INTO dbo.SeaFoodDishes
          (                    
            SeaFoodID,
			PossibleDaysToOrder,
			DepletionOfIntermediates
			               
          ) 
     VALUES 
          ( 
            @SeaFoodID,
			@PossibleDaysToOrder,
			@DepletionOfIntermediates
          ) 
	

END 
GO

IF OBJECT_ID('Add_Menu_Items') IS NOT NULL 
DROP PROC Add_Menu_Items;
GO  

CREATE PROCEDURE dbo.Add_Menu_Items @ItemID int , @ItemName nvarchar(50), @ItemDescription nvarchar(100) , @ItemPrice money, @MenuVersion nvarchar(100),  @SeaFoodID   int= NULL AS 
BEGIN 
     SET NOCOUNT ON 
	 DECLARE @MenuID AS int
		SET @MenuID  = (
			SELECT MenuID 
			FROM Menu
			WHERE MenuVersion=@MenuVersion
		)
	 
     INSERT INTO dbo.MenuItems
          (                    
            ItemID,
			ItemName,
			ItemDescription,
			ItemPrice,
			MenuID,
			SeaFoodID       
          ) 
     VALUES 
          ( 
            @ItemID,
			@ItemName,
			@ItemDescription,
			@ItemPrice,
			@MenuID,
			@SeaFoodID 
          ) 
	

END 
GO

IF OBJECT_ID('Add_Payments') IS NOT NULL 
DROP PROC Add_Payments;
GO  

CREATE PROCEDURE dbo.Add_Payments  @PaymentID int , @CashPayment nvarchar(50), @BankTransferPayment bit, @CardPayment bit,  @PaymentDate  nvarchar(50) AS 
BEGIN 
     SET NOCOUNT ON 
	 
     INSERT INTO dbo.Payments
          (                    
            PaymentID,
			CashPayment,
			BankTransferPayment,
			CardPayment,
			PaymentDate
			               
          ) 
     VALUES 
          ( 
            @PaymentID,
			@CashPayment,
			@BankTransferPayment,
			@CardPayment,
			@PaymentDate
          ) 
	

END 
GO

IF OBJECT_ID('Add_Orders') IS NOT NULL 
DROP PROC Add_Orders;
GO  

CREATE PROCEDURE dbo.Add_Orders 
@OrderID  int ,
@FirstNameCE nvarchar(50)=NULL,
@LastNameCE nvarchar(50)=NULL,
@OrderDate  nvarchar(50),
@FirstNameIC nvarchar(50)=NULL,
@LastNameIC nvarchar(50)=NULL,
@CompanyName nvarchar(50)=NULL,
@OrderStatus nvarchar(50),
@Payment int,
@ApprovedOrderID  bit,
@OrderTypeName nvarchar(50),
@Worker int AS 
BEGIN 
     SET NOCOUNT ON 
	 SET IDENTITY_INSERT dbo.Orders ON
	DECLARE @CustomerID AS int
		SET @CustomerID = (
			SELECT CustomerID 
			FROM IndividualCustomer
			WHERE FirstName = @FirstNameIC AND LastName=@LastNameIC		
		)
	DECLARE @CompanyID AS int
		SET @CompanyID = (
			SELECT CompanyID 
			FROM Company
			WHERE CompanyName=@CompanyName	
		)
	DECLARE @WorkerID AS int
		SET @WorkerID = (
			SELECT WorkerID 
			FROM RestaurantWorker
			WHERE WorkerID=@Worker	
		)
	DECLARE @PaymentID AS int
		SET @PaymentID = (
			SELECT PaymentID 
			FROM Payments
			WHERE PaymentID=@Payment	
		)
	DECLARE @CompanyEmplID AS int
		SET @CompanyEmplID  = (
			SELECT CompanyEmployeeID 
			FROM CompanyEmployee
			WHERE FirstName=@FirstNameCE AND LastName=@LastNameCE
		)
     INSERT INTO dbo.Orders
          (                    
             OrderID,
			 CompanyEmployeeID,
			 OrderDate,
			 CustomerID,
			 CompanyID,
			 OrderStatus,
			 PaymentID,
			 ApprovedOrderID,
			 OrderTypeName,
			 WorkerID                 
          ) 
     VALUES 
          ( 
             @OrderID,
			 @CompanyEmplID,
			 @OrderDate,
			 @CustomerID,
			 @CompanyID,
			 @OrderStatus,
			 @PaymentID,
			 @ApprovedOrderID,
			 @OrderTypeName,
			 @WorkerID  
          ) 
	SET IDENTITY_INSERT dbo.Orders OFF

END 
GO


IF OBJECT_ID('Add_Order_Details') IS NOT NULL 
DROP PROC Add_Order_Details;
GO  

CREATE PROCEDURE dbo.Add_Order_Details 
@OrderID  int ,
@ItemName nvarchar(50),
@Amount int ,
@AmountOfOrders int,
@NumberOfDaysOfPlacedOrders int = NULL
AS 
BEGIN 
     SET NOCOUNT ON 
	 DECLARE @ItemID AS int
		SET @ItemID = (
			SELECT ItemID 
			FROM MenuItems
			WHERE ItemName=@ItemName	
		)
	DECLARE @UnitPrice AS decimal(5,2)
		SET @UnitPrice = @Amount *(
			SELECT ItemPrice 
			FROM MenuItems
			WHERE ItemName=@ItemName	
		)
		DECLARE @Discount AS decimal(5,2)
		IF (@NumberOfDaysOfPlacedOrders IS NULL)
		BEGIN
		SET @Discount = (select dbo.Calculate_Discount_For_The_Number_Of_Orders(@AmountOfOrders, @Amount*@UnitPrice))
		END
		ELSE IF (@NumberOfDaysOfPlacedOrders IS NOT NULL)
		BEGIN
		SET @Discount =(select dbo.Calculate_Discount_For_The_Number_Of_Days( @Amount*@UnitPrice, @NumberOfDaysOfPlacedOrders))
		END
	
     INSERT INTO dbo.OrderDetails
          (                    
             OrderID,
			 ItemID, 
			 Amount,
			 UnitPrice,
			 AmountOfOrders,
			 Discount              
          ) 
     VALUES 
          ( 
             @OrderID,
			 @ItemID, 
			 @Amount,
			 @UnitPrice,
			 @AmountOfOrders,
			 @Discount    
          ) 
	

END 
GO

IF OBJECT_ID('Add_Manager') IS NOT NULL 
DROP PROC Add_Manager;
GO  

CREATE PROCEDURE dbo.Add_Manager  @ManagerID int AS 
BEGIN 
     SET NOCOUNT ON 
	 SET IDENTITY_INSERT dbo.Manager ON
     INSERT INTO dbo.Manager
          (                    
            ManagerID
			               
          ) 
     VALUES 
          ( 
            @ManagerID
          ) 
	SET IDENTITY_INSERT dbo.Manager OFF

END 
GO

IF OBJECT_ID('Add_Restaurant_Employee') IS NOT NULL 
DROP PROC Add_Restaurant_Employee;
GO  
CREATE PROCEDURE dbo.Add_Restaurant_Employee  
@Worker int, 
@Manager int,
@FirstName nvarchar(50),
@LastName  nvarchar(50), 
@HireDate  nvarchar(50), 
@Address  nvarchar(50),
@HomePhone nvarchar(50)=NULL  AS 
BEGIN 
     SET NOCOUNT ON 
	 DECLARE @WorkerID AS int
		SET @WorkerID = (
			SELECT WorkerID 
			FROM RestaurantWorker
			WHERE WorkerID=@Worker	
		)
	DECLARE @ManagerID AS int
		SET @ManagerID = (
			SELECT ManagerID 
			FROM Manager
			WHERE ManagerID=@Manager	
		)
     INSERT INTO dbo.RestaurantEmployees
          (                    
            WorkerID,
			ManagerID,
			FirstName,
			LastName,
			HireDate,
			[Address],
			HomePhone 
			               
          ) 
     VALUES 
          ( 
            @WorkerID,
			@ManagerID,
			@FirstName,
			@LastName,
			@HireDate,
			@Address,
			@HomePhone 
          ) 
	

END 
GO

IF OBJECT_ID('Add_Report') IS NOT NULL 
DROP PROC Add_Report;
GO 

CREATE PROCEDURE dbo.Add_Report 
@ReportID int,
@ManagerName nvarchar(50),
@ManagerSurname nvarchar(50),
@CompanyName nvarchar(50)=NULL,
@FirstNameIC  nvarchar(50)=NULL,
@LastNameIC nvarchar(50)=NULL,
@ReportDate   nvarchar(50) AS 
BEGIN 
     SET NOCOUNT ON 
	 DECLARE @CustomerID AS int
		SET @CustomerID = (
			SELECT CustomerID 
			FROM IndividualCustomer
			WHERE FirstName = @FirstNameIC AND LastName=@LastNameIC		
		)
	DECLARE @CompanyID AS int
		SET @CompanyID = (
			SELECT CompanyID 
			FROM Company
			WHERE CompanyName=@CompanyName	
		)
	DECLARE @ManagerID AS int
		SET @ManagerID = (
			SELECT ManagerID 
			FROM RestaurantEmployees
			WHERE FirstName = @ManagerName AND LastName=@ManagerSurname		
		)
     INSERT INTO dbo.Reports
          (                    
             ReportID,
			 ManagerID,
			 CompanyID,
			 CustomerID,
			 ReportDate 
			               
          ) 
     VALUES 
          ( 
             @ReportID,
			 @ManagerID,
			 @CompanyID,
			 @CustomerID,
			 @ReportDate )
	

END 
GO

IF OBJECT_ID('Add_Invoice') IS NOT NULL 
DROP PROC Add_Invoice;
GO 

CREATE PROCEDURE dbo.Add_Invoice
@InvoiceID int,
@Singleinvoice bit = NULL,
@CompanyName nvarchar(50)=NULL,
@ManagerName nvarchar(50),
@ManagerSurname nvarchar(50),
@InvoiceDate  nvarchar(50)= NULL ,
@CollectiveInvoice bit = NULL 
AS
BEGIN 
     SET NOCOUNT ON 
	DECLARE @CompanyID AS int
		SET @CompanyID = (
			SELECT CompanyID 
			FROM Company
			WHERE CompanyName=@CompanyName	
		)
	DECLARE @ManagerID AS int
		SET @ManagerID = (
			SELECT ManagerID 
			FROM RestaurantEmployees
			WHERE FirstName = @ManagerName AND LastName=@ManagerSurname		
		)
     INSERT INTO dbo.Invoices
          (                    
             InvoiceID,
			 SingleInvoice,
			 CompanyID,
			 ManagerID,
			 InvoiceDate,
			 CollectiveInvoice
			               
          ) 
     VALUES 
          ( 
             @InvoiceID,
			 @SingleInvoice,
			 @CompanyID,
			 @ManagerID,
			 @InvoiceDate,
			 @CollectiveInvoice )
	

END 
GO

IF OBJECT_ID('Add_CompanyEmployee') IS NOT NULL 
DROP PROC Add_CompanyEmployee;
GO  

CREATE PROCEDURE dbo.Add_CompanyEmployee
@CompanyEmployeeID int ,
@FirstName        nvarchar(40),
@LastName          nvarchar(20),
@Phone            nvarchar(20),
@Email            nvarchar(50) ,
@CompanyName      nvarchar(20)
AS
BEGIN 
     SET NOCOUNT ON
	  SET IDENTITY_INSERT dbo.CompanyEmployee ON
	DECLARE @CompanyID AS int
		SET @CompanyID = (
			SELECT CompanyID 
			FROM Company
			WHERE CompanyName=@CompanyName	
		)
     INSERT INTO dbo.CompanyEmployee
          (                    
             CompanyEmployeeID,
			 FirstName,
			 LastName,
			 Phone,
			 Email,
			 CompanyID 
			               
          ) 
     VALUES 
          ( 
             @CompanyEmployeeID,
			 @FirstName,
			 @LastName,
			 @Phone,
			 @Email,
			 @CompanyID )
	
 SET IDENTITY_INSERT dbo.CompanyEmployee OFF
END 
GO

-----------------------------------------------------------------------------------INNE PROCEDURY--------------------------------------------------------------------------

IF OBJECT_ID('Cancel_Reservation') IS NOT NULL
DROP PROC Cancel_Reservation
GO

CREATE PROCEDURE dbo.Cancel_Reservation
@ReservationID int 
AS 
BEGIN 
     SET NOCOUNT ON 
	UPDATE Reservation
	SET CancelDate = GETDATE()
	WHERE ReservationID = @ReservationID 
	END
GO

IF OBJECT_ID('Cancel_Table') IS NOT NULL
DROP PROC Cancel_Table
GO

CREATE PROCEDURE dbo. Cancel_Table
@TableNumber int
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @TableID AS int
		SET @TableID = (
			SELECT TableID 
			FROM [Tables]
			WHERE TableNumber=@TableNumber
		)
	UPDATE Reservation
	SET CancelDate = GETDATE()
	WHERE TableID=@TableID
	END
GO

IF OBJECT_ID('Cancel_Payment') IS NOT NULL
DROP PROC Cancel_Payment
GO

CREATE PROCEDURE dbo. Cancel_Payment
@PaymentID int
AS
BEGIN
	SET NOCOUNT ON
	UPDATE Payments
	SET PaymentCancelDate = GETDATE()
	WHERE PaymentID=@PaymentID
	END
GO


-------------------------------------------------------------------------------------WIDOKI----------------------------------------------------------------------------------------


IF OBJECT_ID('Menu_View') IS NOT NULL
DROP VIEW Menu_View
GO

CREATE VIEW Menu_View AS
SELECT ItemName, ItemDescription, ItemPrice
FROM MenuItems
GO


IF OBJECT_ID('Unreserved_Tables') IS NOT NULL
DROP VIEW Unreserved_Tables
GO

CREATE VIEW Unreserved_Tables AS
SELECT [Tables].TableID
FROM [Tables] INNER JOIN Reservation ON Reservation.TableID=[Tables].TableID
WHERE Reservation.TableID IS NULL
GO

IF OBJECT_ID('To_which_company_the_employee_belongs') IS NOT NULL
DROP VIEW To_which_company_the_employee_belongs
GO

CREATE VIEW To_which_company_the_employee_belongs AS
SELECT CompanyName, FirstName + ' ' + LastName as worker
FROM CompanyEmployee INNER JOIN Company ON Company.CompanyID= CompanyEmployee.CompanyID
GO

IF OBJECT_ID('Unapproved_Orders') IS NOT NULL
DROP VIEW Unapproved_Orders
GO

CREATE VIEW Unapproved_Orders AS
SELECT OrderID, ApprovedOrderID
FROM Orders
WHERE ApprovedOrderID='FALSE'
GO

IF OBJECT_ID('Approved_Orders') IS NOT NULL
DROP VIEW Approved_Orders
GO

CREATE VIEW Approved_Orders AS
SELECT OrderID, ApprovedOrderID
FROM Orders
WHERE ApprovedOrderID='TRUE'
GO

IF OBJECT_ID('Canceled_Payments') IS NOT NULL
DROP VIEW Canceled_Payments
GO

CREATE VIEW Canceled_Payments AS
SELECT PaymentID
FROM Payments
WHERE PaymentCancelDate IS NOT NULL
GO

IF OBJECT_ID('Customers_who_booked_a_table') IS NOT NULL
DROP VIEW Customers_who_booked_a_table 
GO

CREATE VIEW Customers_who_booked_a_table AS
SELECT FirstName + ' ' + LastName as customer, TableNumber
FROM Reservation INNER JOIN IndividualCustomer ON IndividualCustomer.CustomerID=Reservation.CustomerID
INNER JOIN [Tables] ON [Tables].TableID=Reservation.TableID
GO

IF OBJECT_ID('Company_who_booked_a_table') IS NOT NULL
DROP VIEW Company_who_booked_a_table 
GO

CREATE VIEW Company_who_booked_a_table AS
SELECT CompanyName, TableNumber
FROM Reservation INNER JOIN Company ON Company.CompanyID=Reservation.CompanyID
INNER JOIN [Tables] ON [Tables].TableID=Reservation.TableID
GO

IF OBJECT_ID('Company_Employee_who_booked_a_table') IS NOT NULL
DROP VIEW Company_Employee_who_booked_a_table 
GO

CREATE VIEW Company_Employee_who_booked_a_table AS
SELECT FirstName + ' ' + LastName as company_employee, TableNumber
FROM Reservation INNER JOIN CompanyEmployee ON CompanyEmployee.CompanyEmployeeID=Reservation.CompanyEmployeeID
INNER JOIN [Tables] ON [Tables].TableID=Reservation.TableID
GO


---------------------------------------------------------------------------------WIDOKI DLA RAPORTÓW---------------------------------------------------------------------------------------------------

IF OBJECT_ID('Table_Online_Reservation_Raport_for_Individual_Customer') IS NOT NULL
DROP VIEW Table_Online_Reservation_Raport_for_Individual_Customer 
GO

CREATE VIEW Table_Online_Reservation_Raport_for_Individual_Customer AS
SELECT ManagerID, ReportDate, FirstName + ' ' + LastName as customer, TableNumber, ReservationDate
FROM Reports INNER JOIN IndividualCustomer ON IndividualCustomer.CustomerID=Reports.CustomerID
INNER JOIN Reservation ON Reservation.CustomerID=IndividualCustomer.CustomerID
INNER JOIN [Tables] ON [Tables].TableID=Reservation.TableID
WHERE OnilneReservation IS NOT NULL
GO

IF OBJECT_ID('Table_Phone_Reservation_Raport_for_Individual_Customer') IS NOT NULL
DROP VIEW Table_Phone_Reservation_Raport_for_Individual_Customer 
GO

CREATE VIEW Table_Phone_Reservation_Raport_for_Individual_Customer AS
SELECT ManagerID, ReportDate, FirstName + ' ' + LastName as customer, TableNumber, ReservationDate
FROM Reports INNER JOIN IndividualCustomer ON IndividualCustomer.CustomerID=Reports.CustomerID
INNER JOIN Reservation ON Reservation.CustomerID=IndividualCustomer.CustomerID
INNER JOIN [Tables] ON [Tables].TableID=Reservation.TableID
WHERE ReservationByPhone IS NOT NULL
GO


IF OBJECT_ID('Table_Online_Reservation_Raport_for_Company') IS NOT NULL
DROP VIEW Table_Online_Reservation_Raport_for_Company 
GO

CREATE VIEW Table_Online_Reservation_Raport_for_Company AS
SELECT ManagerID, ReportDate, CompanyName, TableNumber, ReservationDate
FROM Reports INNER JOIN Company ON Company.CompanyID=Reports.CompanyID
INNER JOIN Reservation ON Reservation.CompanyID=Company.CompanyID
INNER JOIN [Tables] ON [Tables].TableID=Reservation.TableID
WHERE OnilneReservation IS NOT NULL
GO

IF OBJECT_ID('Table_Phone_Reservation_Raport_for_Company') IS NOT NULL
DROP VIEW Table_Phone_Reservation_Raport_for_Company 
GO

CREATE VIEW Table_Phone_Reservation_Raport_for_Company AS
SELECT ManagerID, ReportDate, CompanyName, TableNumber, ReservationDate
FROM Reports INNER JOIN Company ON Company.CompanyID=Reports.CompanyID
INNER JOIN Reservation ON Reservation.CompanyID=Company.CompanyID
INNER JOIN [Tables] ON [Tables].TableID=Reservation.TableID
WHERE ReservationByPhone IS NOT NULL
GO

IF OBJECT_ID('Discount_Raport_for_Individual_Customer') IS NOT NULL
DROP VIEW Discount_Raport_for_Individual_Customer 
GO

CREATE VIEW Discount_Raport_for_Individual_Customer AS
SELECT ManagerID, ReportDate, FirstName + ' ' + LastName as customer, ItemName, UnitPrice, Discount
FROM Reports INNER JOIN IndividualCustomer ON IndividualCustomer.CustomerID=Reports.CustomerID
INNER JOIN Orders ON Orders.CustomerID=IndividualCustomer.CustomerID
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN MenuItems ON MenuItems.ItemID=OrderDetails.ItemID
WHERE Discount IS NOT NULL

GO

IF OBJECT_ID('Discount_Raport_for_Company') IS NOT NULL
DROP VIEW Discount_Raport_for_Company 
GO

CREATE VIEW Discount_Raport_for_Company AS
SELECT ManagerID, ReportDate, CompanyName, ItemName, UnitPrice, Discount
FROM Reports INNER JOIN Company ON Company.CompanyID=Reports.CompanyID
INNER JOIN Orders ON Orders.CompanyEmployeeID=Company.CompanyID
INNER JOIN OrderDetails ON OrderDetails.OrderID=Orders.OrderID
INNER JOIN MenuItems ON MenuItems.ItemID=OrderDetails.ItemID
WHERE Discount IS NOT NULL

GO


---------------------------------------------------------------------------TRIGGERY-----------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('LimitTable') IS NOT NULL
DROP TRIGGER LimitTable 
GO

CREATE TRIGGER LimitTable
ON [Tables]
AFTER INSERT
AS
    DECLARE @tableCount int
    SELECT @tableCount = Count(*)
    FROM [Tables]

    IF @tableCount > 25
    BEGIN
        ROLLBACK
    END
GO

IF OBJECT_ID('Cancel_Record') IS NOT NULL
DROP TRIGGER Cancel_Record 
GO

CREATE TRIGGER Cancel_Record
ON Payments
FOR DELETE
AS
DELETE FROM Orders
	WHERE PaymentID =
	(SELECT PaymentID FROM Payments WHERE PaymentCancelDate IS NOT NULL)
GO

IF OBJECT_ID('Cancel_Reservation_trigg') IS NOT NULL
DROP TRIGGER Cancel_Reservation_trigg 
GO

CREATE TRIGGER Cancel_Reservation_trigg
ON Reservation
FOR DELETE
AS
DELETE FROM Reservation
	WHERE CancelDate IS NOT NULL
GO