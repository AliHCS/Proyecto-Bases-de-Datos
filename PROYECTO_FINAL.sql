--PROYECTO FINAL
--Gómez Trejo Gustavo Ali
--Hernández Escobar Oswaldo
--Rangel García Carlos Alberto
-- Creación de tablas con llaves foráneas depediendo de la cardinalidad
CREATE TABLE Conductor(
	rfc varchar(15) NOT NULL PRIMARY KEY,
	nombre varchar(25) NOT NULL, 
	direccion varchar(20) NOT NULL
)
INSERT INTO Conductor
VALUES('ERTY1548FG','Jose Jimenez','Calle 35'),('JOTY7848JK','Pablo Chacon','Calle 78'),
('ETYH7853LK','Karla Cruz','Calle 103'),('DANT7896LU','Daniel Ramirez','Sur 305'),('JULI2548FG','Julio Ruiz','Oriente 669');
---------------------------------------------------------------------------------------------------------
CREATE TABLE CLocal(
	codigoLocal int NOT NULL PRIMARY KEY,
	nombre varchar(20) NOT NULL
)
INSERT INTO CLocal
VALUES(101,'FedEx'),(102,'Envios Express'),(103,'DLH'),(104,'FeedPack'),(105,'Rapid Envios');
---------------------------------------------------------------------------------------------------------
CREATE TABLE PaqueteNacional(
	codigoN int NOT NULL PRIMARY KEY,
	direccion varchar(30) NOT NULL,
	peso decimal NOT NULL,
	destinatario varchar(30) NOT NULL,
	ciudadDestino varchar(15) NOT NULL,
	ruta int NOT NULL,
	idConductor varchar(15) NOT NULL,
CONSTRAINT FK_idConductor FOREIGN KEY(idConductor) REFERENCES Conductor (rfc) 
)
INSERT INTO PaqueteNacional
VALUES(200,'Calle Numero 1',15.5,'Jose Rivera','CDMX',1,'ERTY1548FG'),(201,'Calle Numero 2',5.3,'Carlos Rangel','CDMX',1,'JOTY7848JK'),
(202,'Calle Numero 3',11,'Juan Perez','CDMX',1,'JULI2548FG'),(203,'Calle Numero 4',9.5,'Josefina Carrillo','Nuevo Leon',1,'ETYH7853LK'),
(204,'Calle Numero 5',12,'Miguel Felix','Nuevo Leon',1,'JULI2548FG');
---------------------------------------------------------------------------------------------------------
CREATE TABLE PaqueteInternacional(
	codigoI int NOT NULL PRIMARY KEY,
	direccion varchar(30) NOT NULL,
	peso decimal NOT NULL,
	destinatario varchar(30) NOT NULL,
	lineaAerea varchar(15) NOT NULL,
	fechaEntrega date NOT NULL,
	idLocal int NOT NULL,
CONSTRAINT FK_idLocal FOREIGN KEY(idLocal) REFERENCES CLocal (codigoLocal)
)
INSERT INTO PaqueteInternacional
VALUES(300,'Iceberg Lounge',15.5,'Oswald Cobblepot','Linea 52','2018/02/12',101),(301,'Latveria',15.5,'Victor Von Doom','Linea 78','2018/02/12',101),
(302,'Park Avenue',15.5,'Mary Jane','Linea 103','2018/02/12',102),(303,'Park Avenue',15.5,'Peter Parker','Linea 103','2018/02/12',103),
(304,'Gotham City',15.5,'Bruce Wayne','Linea 52','2018/02/12',103);
---------------------------------------------------------------------------------------------------------
CREATE TABLE Camion(
	placa varchar(8) NOT NULL PRIMARY KEY,
	cargaMaxima int NOT NULL, 
	ciudadResguardo varchar(20) NOT NULL 
)
INSERT INTO Camion
VALUES('PKR-1589',1200,'CDMX'),('ERT-7895',900,'CDMX'),('WER-7896',1000,'Monterrey'),('TRU-1234',800,'Hermosillo'),('QWE-8520',500,'Juarez');
---------------------------------------------------------------------------------------------------------
CREATE TABLE Conduce(
	fecha date NOT NULL,
	idConductor varchar(15) NOT NULL,
	idCamion varchar(8) NOT NULL,
CONSTRAINT FK_ConductorID FOREIGN KEY(idConductor) REFERENCES Conductor (rfc), 
CONSTRAINT FK_CamionID FOREIGN KEY(idCamion) REFERENCES Camion (Placa) 
)
INSERT INTO Conduce
VALUES('2018/12/12','ERTY1548FG','PKR-1589'),('2018/11/12','JULI2548FG','ERT-7895'),('2019/01/06','DANT7896LU','WER-7896'),
('2019/02/01','ETYH7853LK','TRU-1234'),('2019/03/11','JOTY7848JK','QWE-8520');
---------------------------------------------------------------------------------------------------------
--------------------------- Codigo para atributo multivaluado "ruta" ------------------------------------
CREATE TABLE Ruta(
	idRuta int NOT NULL PRIMARY KEY
)

CREATE TABLE RutaConductor(
	idRutaC int NOT NULL PRIMARY KEY,
    conductorID varchar(15) NOT NULL,
CONSTRAINT FK_conductor_ID FOREIGN KEY(conductorID) REFERENCES Conductor (rfc),
CONSTRAINT FK_idRutaC FOREIGN KEY(idRutaC) REFERENCES Ruta (idRuta)
)

CREATE TABLE RutaNacional(
	idRutaN int NOT NULL PRIMARY KEY,
	nacionalID int NOT NULL,
CONSTRAINT FK_naciona_ID FOREIGN KEY(nacionalID) REFERENCES PaqueteNacional (codigoN),
CONSTRAINT FK_idRutaN FOREIGN KEY(idRutaN) REFERENCES Ruta (idRuta)
)

INSERT INTO Ruta
VALUES(1),(2),(3),(4),(5),
	  (6),(7),(8),(9),(10);
---------------------------------------------------------------------------------------------------------
SELECT * FROM Conduce
SELECT * FROM PaqueteNacional
SELECT * FROM Camion
SELECT * FROM RutaNacional
SELECT * FROM RutaConductor
SELECT * FROM Ruta
SELECT * FROM PaqueteInternacional
SELECT * FROM CLocal
SELECT * FROM Conductor


DROP TABLE RutaNacional
DROP TABLE RutaConductor
DROP TABLE Ruta
DROP TABLE Conduce
DROP TABLE Camion
DROP TABLE PaqueteInternacional
DROP TABLE PaqueteNacional
DROP TABLE CLocal
DROP TABLE Conductor
----------------------------------------------TRIGGERS---------------------------------------------------
CREATE TRIGGER InsertNacional
ON PaqueteNacional
FOR insert
AS
	DECLARE @Codigo int
	SET @Codigo = (SELECT codigoN FROM inserted)
	IF EXISTS (SELECT * FROM PaqueteInternacional WHERE codigoI = @Codigo)
	BEGIN
	   RAISERROR('ESTE PAQUETE YA ES DEL TIPO INTERNACIONAL',10,1) 
       ROLLBACK TRANSACTION 
	END


DROP TRIGGER InsertNacional
INSERT INTO PaqueteNacional
VALUES(208,'Calle Numero 1',15.5,'Jose Rivera','CDMX',1,'ERTY1548FG')
VALUES(300,'Calle Numero 1',15.5,'Jose Rivera','CDMX',1,'ERTY1548FG')
---------------------------------------------------------------------------------------------------------
CREATE TRIGGER InsertInternacional
ON PaqueteInternacional
FOR insert
AS
	DECLARE @Codigo int
	SET @Codigo = (SELECT codigoI FROM inserted)
	IF EXISTS (SELECT * FROM PaqueteNacional WHERE codigoN = @Codigo)
	BEGIN
	   RAISERROR('ESTE PAQUETE YA ES DEL TIPO NACIONAL',10,1) 
       ROLLBACK TRANSACTION 
	END

DROP TRIGGER InsertInternacional

INSERT INTO PaqueteInternacional
VALUES(310,'Iceberg Lounge',15.5,'Oswald Cobblepot','Linea 52','2018/02/12',101)


INSERT INTO PaqueteInternacional
VALUES(208,'Iceberg Lounge',15.5,'Oswald Cobblepot','Linea 52','2018/02/12',101)
---------------------------------------------------------------------------------------------------------
CREATE TRIGGER LimitePeso
ON Camion
FOR INSERT 
AS
DECLARE 
	@peso decimal
	SET @peso = (SELECT cargaMaxima FROM inserted)
	IF @peso < 250 OR @peso > 1250
		BEGIN
		   RAISERROR('LA CARGA DEL CAMION NO ESTA EN LOS ESTANDARES PERMITIDOS',10,1) 
		   ROLLBACK TRANSACTION 
		END

DROP TRIGGER LimitePeso

INSERT INTO camion
VALUES('PDJ-4950',1259,'celaya')

INSERT INTO camion
VALUES('PDJ-4950',10,'celaya')

INSERT INTO camion
VALUES('PDJ-4950',300,'celaya')

---------------------------------------------------------------------------------------------------------
CREATE TABLE Tabla (
codigo int NOT NULL PRIMARY KEY,
ciudad varchar(15) NOT NULL,
total int NOT NULL
)

CREATE TRIGGER InsertNacional2
ON PaqueteNacional
FOR insert
AS BEGIN
	DECLARE @codigo int
	DECLARE @ciudad varchar(15) 
	DECLARE @totalEnvios int

	SET @codigo = (SELECT codigoN FROM inserted)
	SET @ciudad = (SELECT ciudadDestino FROM inserted)
	SET @totalEnvios =  (SELECT count(ciudadDestino) FROM PaqueteNacional
	                     WHERE ciudadDestino = @ciudad)
	
	INSERT INTO Tabla(codigo,ciudad,total)
	VALUES (@codigo,@ciudad,@totalEnvios)
END


INSERT INTO PaqueteNacional
VALUES(210,'Calle Sin Nombre',10.5,'Perdo Gomez','CDMX',2,'ERTY1548FG');

DROP TRIGGER InsertaNacional2

select* from PaqueteNacional
select* from Tabla
drop table Tabla
---------------------------------------------------------------------------------------------------------
--------------------------------------- PROCEDIMIENTO ALMACENADO ----------------------------------------
CREATE PROCEDURE MuestraInfo
@codigoPaquete as int
AS 
	IF @codigoPaquete IN (SELECT codigoN FROM PaqueteNacional)
		SELECT codigoN,p.direccion,peso,p.idConductor,ruta,idCamion,fecha FROM PaqueteNacional p
		JOIN Conductor co ON (p.idConductor = co.rfc)
		JOIN Conduce c ON (co.rfc = c.idConductor)
		WHERE @codigoPaquete = codigoN
	IF @codigoPaquete IN (SELECT codigoI FROM PaqueteInternacional)
		SELECT codigoI,direccion,lineaAerea,idLocal FROM PaqueteInternacional
		WHERE @codigoPaquete = codigoI
    ELSE 
			PRINT 'EL CODIGO NO EXISTE EN LA BASE DE DATOS'

DROP PROCEDURE MuestraInfo


SELECT * FROM PaqueteInternacional
EXECUTE MuestraInfo 300

SELECT * FROM PaqueteNacional
SELECT * FROM Conduce
EXECUTE MuestraInfo 203

SELECT* FROM tabla
---------------------------------------------------------------------------------------------------------

