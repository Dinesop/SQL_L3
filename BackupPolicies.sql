SET identity_insert BackupPolicies on;

insert into BackupPolicies (id, PolicyName) values (1, 'Full');
insert into BackupPolicies (id, PolicyName) values (2, 'Incremental');

SET identity_insert BackupPolicies off;
GO