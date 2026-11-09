SET identity_insert BackupServers on;
insert into BackupServers (id, ServerName) values (1, 'Prod-Web-01');
insert into BackupServers (id, ServerName) values (2, 'Dev-Db-01');
insert into BackupServers (id, ServerName) values (3, 'Test-App-04');

set identity_insert BackupServers OFF;