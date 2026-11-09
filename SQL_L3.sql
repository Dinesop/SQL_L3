/* ============================================================================
   FAILSAFE IT - INFRASTRUKTUR- OCH BEHÖRIGHETSREGISTER
   STARTSKRIPT FÖR LEKTION 3: Datamodellering, ER-diagram & Normalisering
   ============================================================================ */

USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'FailSafe_Lektion3')
BEGIN
    ALTER DATABASE FailSafe_Lektion3 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FailSafe_Lektion3;
END
GO

CREATE DATABASE FailSafe_Lektion3;
GO

USE FailSafe_Lektion3;
GO



PRINT 'FailSafeIT-databasen är skapad och preparerad för Lektion 3!';

-- Steg 0: UNF - kaos
CREATE TABLE Legacy_Incident_Chaos
(
	ServerName NVARCHAR(100),
	Incident_And_Date NVARCHAR(250),
	InvestigatedByTechs NVARCHAR(MAX)
);

INSERT INTO Legacy_Incident_Chaos
VALUES  ('Prod_Web_01', 'DDoS:2026-11-05', 'Erik Nilsson, Lina Berg'),
		('Prod_Web_01', 'DDoS:2026-11-06', 'Erik Nilsson');

-- Steg 1: Transformera till 1NF
CREATE TABLE Incident_1NF
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	ServerName NVARCHAR(100),
	IncidentType NVARCHAR(100),
	IncidentDate DATETIME2,
	TechName NVARCHAR(150)
);
INSERT INTO Incident_1NF VALUES
	('Prod_Web_01', 'DDoS', '2026-11-05', 'Erik Nilsson'),
	('Prod_Web_01', 'DDoS', '2026-11-05', ' Lina Berg'),
	('Prod_Web_01', 'DDoS', '2026-11-06', 'Erik Nilsson');
GO

-- Steg 2: Transformera till 2NF
CREATE TABLE IncidentServers_2NF
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	ServerName NVARCHAR(100)
);

CREATE TABLE Incidents_And_Techs_2NF
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	IncidentType NVARCHAR(100),
	IncidentDate DATETIME2,
	TechName NVARCHAR(150)
);

INSERT INTO IncidentServers_2NF VALUES 
	('Prod_Web_01');

INSERT INTO Incidents_And_Techs_2NF VALUES
	('DDoS', '2026-11-05', 'Erik Nilsson'), 
	('DDoS', '2026-11-05', ' Lina Berg'),
	('DDoS', '2026-11-06', 'Erik Nilsson');
GO

-- Steg 3: Transformera till 3NF & Upplöst M:M
CREATE TABLE IncidentServers
	(Id INT IDENTITY(1,1) PRIMARY KEY, ServerName NVARCHAR(100));

CREATE TABLE SecurityTechs(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	TechName NVARCHAR(150));

CREATE TABLE Incidents (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	IncidentType NVARCHAR(100) NOT NULL, 
	IncidentDate DATETIME2 NOT NULL DEFAULT GETDATE(),
	ServerId INT FOREIGN KEY REFERENCES IncidentServers(Id));

CREATE TABLE IncidentAssignments(
	IncidentId INT NOT NULL,
	TechId INT NOT NULL,
	CONSTRAINT PK_IncidentAssignments PRIMARY KEY (IncidentId, TechId), --En sammansatt primärnyckel
	CONSTRAINT FK_Assignment_Incident FOREIGN KEY (IncidentId)
		REFERENCES Incidents(Id),
	CONSTRAINT FK_Assignment_Tech FOREIGN KEY (TechId)
		REFERENCES SecurityTechs(Id)
);

INSERT INTO IncidentServers VALUES 
	('Prod_Web_01');

INSERT INTO SecurityTechs VALUES
	('Erik Nilsson'),
	('Lina Berg');

INSERT INTO Incidents VALUES
	('DDoS', '2026-11-05', 1),
	('DDoS', '2026-11-05', 2);

INSERT INTO IncidentAssignments(IncidentId, TechId) VALUES
	(1, 1),
	(1, 2),
	(2, 1);

GO

-- Steg 4: Verifiera att det funkar genom att återskapa ursprungsdatan via joins.
SELECT
	s.ServerName, 
	i.IncidentType + ':' + CONVERT(VARCHAR, i.IncidentDate, 23) as Incident_And_Date,
	t.TechName as InvestigatedByTech
FROM Incidents i
	INNER JOIN IncidentServers s on i.ServerId = s.Id
	INNER JOIN IncidentAssignments a on i.Id = a.IncidentId
	INNER JOIN SecurityTechs t on a.TechId = t.Id;
GO

-- Uppgift ? kopierat från LucidChart
CREATE TABLE [BackupServers] (
  [Id] INT IDENTITY(1,1) PRIMARY KEY,
  [ServerName] NVARCHAR(100) NOT NULL UNIQUE,
);

CREATE TABLE [BackupPolicies] (
  [Id] INT IDENTITY(1,1) PRIMARY KEY,
  [PolicyName] NVARCHAR(100) NOT NULL UNIQUE,
  [IntervalHours] INT,
);

CREATE TABLE [ServerPolicyMap] (
  [ServerId] INT NOT NULL,
  [PolicyId] INT NOT NULL,
  [IsActive] BIT DEFAULT 1,
  CONSTRAINT PK PRIMARY KEY ([ServerId], [PolicyId]),
  CONSTRAINT [FK_ServerPolicyMaps_ServerId]
    FOREIGN KEY ([ServerId])
      REFERENCES [BackupServers]([Id]),
  CONSTRAINT [FK_ServerPolicyMap_PolicyId]
    FOREIGN KEY ([PolicyId])
      REFERENCES [BackupPolicies]([Id])
);


-- Insert data from Mockaroo
SET identity_insert BackupPolicies on;
insert into BackupPolicies (id, PolicyName, IntervalHours) values (1, 'Full', 24);
insert into BackupPolicies (id, PolicyName, IntervalHours) values (2, 'Incremental', 24);
SET identity_insert BackupPolicies off;
GO

SET identity_insert BackupServers on;
insert into BackupServers (id, ServerName) values (1, 'Prod-Web-01');
insert into BackupServers (id, ServerName) values (2, 'Dev-Db-01');
insert into BackupServers (id, ServerName) values (3, 'Test-App-04');
SET identity_insert BackupServers off;
GO

insert into ServerPolicyMap (ServerId, PolicyId) values (1, 1);
insert into ServerPolicyMap (ServerId, PolicyId) values (3, 2);
insert into ServerPolicyMap (ServerId, PolicyId) values (2, 1);

-- Verifiera data från ?
print 'Verifierar data från Block 2' -- har inte implementerat Claes blockstruktur än.
SELECT * FROM BackupPolicies
SELECT * FROM BackupServers
SELECT * FROM ServerPolicyMap
GO