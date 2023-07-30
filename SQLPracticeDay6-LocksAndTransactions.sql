--Practice Exercises - DAY 6:	
-----------------------------LOCKS AND TRANSACTIONS----

CREATE DATABASE LockDatabase
USE LockDatabase

CREATE TABLE Table1(
Column1 int,
Column2 char(5))

INSERT INTO Table1 VALUES
(1, 'A'),
(2, 'B')

SELECT * FROM Table1

----------Locks:

--Exclusive Locking: (X)-WRITE LOCKS
-----USER 1:
BEGIN TRANSACTION
	UPDATE Table1 SET Column2 = 'C' WHERE Column1 = 2		--Exclusive Lock applied.
--/ROLLBACK
--/COMMIT TRANSACTION

-----USER 2:
SELECT * FROM Table1 WHERE Column1 = 2		--Executing query....


--Shared Locking: (S)-READ LOCKS
-----USER 1:
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRANSACTION
	SELECT * FROM Table1 WHERE Column1 = 2		--Shared Lock applied.
--/ROLLBACK
--/COMMIT TRANSACTION

-----USER 2:
BEGIN TRANSACTION
	UPDATE Table1 SET Column2 = 'C' WHERE Column1 = 2		--Executing query....
--/COMMIT TRANSACTION
--/ROLLBACK		


--Update Locking: (U)
-----USER 1:
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRANSACTION
	UPDATE Table1 SET Column2 = 'C' WHERE Column1 = 2		--Shared Lock applied.
--/ROLLBACK
--/COMMIT TRANSACTION

-----USER 2:
BEGIN TRANSACTION
	UPDATE Table1 SET Column2 = 'C' WHERE Column1 = 2		--Executing query....
--/COMMIT TRANSACTION
--/ROLLBACK	


----------Transaction:

USE LockDatabase

CREATE TABLE Table2(
Id int unique,
Name varchar(5))

--Autocommit Transction:
INSERT INTO Table2 VALUES
(1, 'Abish')	
		--SQL Server will automatically start a transaction and then it commits the transaction because this insert statement will not return any error

INSERT INTO Table2 VALUES
(1, 'Ashish')		--OUTPUT: The statement has been terminated.
		--SQL Server rollbacks the data modification due to a duplicate primary key error


--Implicit Transction:
	--Implicit transaction mode enables to SQL Server to start an implicit transaction for every DML statement 
	--but we need to use the commit or rolled back commands explicitly at the end of the statements
USE EmployeeDatabase

SET IMPLICIT_TRANSACTIONS ON 
	UPDATE Employee  SET EmployeeName = 'Maya' WHERE EmployeeId = 12
	SELECT 
    IIF(@@OPTIONS & 2 = 2, 
    'Implicit Transaction Mode ON', 
    'Implicit Transaction Mode OFF'
    ) AS 'Transaction Mode' 
	SELECT 
    @@TRANCOUNT AS OpenTransactions 
COMMIT TRAN 
SELECT 
    @@TRANCOUNT AS OpenTransactions


--Explicit Transction:
	--Explicit transaction mode provides to define a transaction exactly with the starting and ending points of the transaction
BEGIN TRAN
	UPDATE Employee SET EmployeeName = 'Anjali'  WHERE EmployeeId = 11
	SELECT * FROM Employee WHERE EmployeeId = 11
ROLLBACK TRAN 
 
SELECT * FROM Employee WHERE EmployeeId = 11



-----SAVEPOINT in a TRANSACTION:
BEGIN TRANSACTION 
INSERT INTO Employee VALUES
('Manya', 23, 'Accounts', '75000')
SAVE TRANSACTION InsertStatement		--Savepoints can be used to rollback any particular part of the transaction rather than the entire transaction. 
										--So that we can only rollback any portion of the transaction where between after the save point and before the rollback command.
DELETE Employee WHERE EmployeeId = 13
SELECT * FROM Employee 
ROLLBACK TRANSACTION InsertStatement
COMMIT
SELECT * FROM Employee		--only the insert statement will be committed and the delete statement will be rolled back


-----AUTO ROLLBACK in a TRANSACTION:
BEGIN TRANSACTION
	INSERT INTO Employee VALUES
	('Lasya', 25, 'Marketing', '80000')
    UPDATE Employee SET Age='MiddleAge' WHERE EmployeeId = 19
	SELECT * FROM Employee
COMMIT TRAN
		--OUTPUT: Employee Details inserted successfully
	--(1 row affected)
	--Msg 245, Level 16, State 1, Line 121
	--Conversion failed when converting the varchar value 'MiddleAge' to data type int.

--There was an error that occurred in the update statement due to the data type conversion issue. 
--In this case, the inserted data is erased and the select statement did not execute.