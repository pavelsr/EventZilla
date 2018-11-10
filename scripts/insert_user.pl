use VK;
use Data::Dumper;
use Data::Dumper::AutoEncode;
use DBI;
use DBD::MariaDB;
use feature 'say';

my $dsn = "DBI:MariaDB:database=".$ENV{'DATABASE'}.";host=".$ENV{'DB_HOST'}.";port=".$ENV{'DB_PORT'};
say "DSN: ".$dsn;
say "DB User: ".$ENV{'DB_USER'};
say "DB password: ".$ENV{'DB_PASSWORD'};
my $dbh = DBI->connect( $dsn, $ENV{'DB_USER'}, $ENV{'DB_PASSWORD'} );

my $vk = VK->new;
my $table ='stat';

my $res = $vk->query( 'users.get', {
    user_id => $ARGV[0],
    extended => 1,
    fields => 'sex,bdate,city,education,occupation,status,interests'
} );

warn eDumper $res;
