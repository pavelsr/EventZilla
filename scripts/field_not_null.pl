# Выводит все ненулевые значения по выбранному полю

use VK;
use Data::Dumper;
use Data::Dumper::AutoEncode;
use DBI;
use DBI::Log;
use DBD::MariaDB;
use feature 'say';

my $dsn = "DBI:MariaDB:database=".$ENV{'DATABASE'}.";host=".$ENV{'DB_HOST'}.";port=".$ENV{'DB_PORT'};
say "DSN: ".$dsn;
say "DB User: ".$ENV{'DB_USER'};
say "DB password: ".$ENV{'DB_PASSWORD'};
my $dbh = DBI->connect( $dsn, $ENV{'DB_USER'}, $ENV{'DB_PASSWORD'} );

my $table ='users';
my $field = 'vk_interests';

my $q = $dbh->selectall_arrayref("SELECT $field FROM $table WHERE $field IS NOT NULL", { Slice => {} });
my @checks = map { $_->{vk_interests} } @$q;
print join ("\n", @checks);
