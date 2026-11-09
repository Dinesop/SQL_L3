-- Steg 0: UNF - kaos
CREATE TABLE Legacy_Incident_Chaos
(
	ServerName NVARCHAR(100),
	Incident_And_Date NVARCHAR(250),
	InvestigatedByTechs NVARCHAR(MAX)
);

INSERT INTO Legacy_Incident_Chaos
VALUES('Prod_Web_01', 'DDoS:2026-11-05', 'Erik Nilsson, Lina Berg');

