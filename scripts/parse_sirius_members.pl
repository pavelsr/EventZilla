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

my $vk = VK->new;
my $group_id = 71991592;

sub insert_user {
  my $row = shift;
  $row->{sex} = 'f' if ( $row->{sex} == 1 );
  $row->{sex} = 'm' if ( $row->{sex} == 2 );
  $dbh->do(
    qq/
      INSERT
        INTO users
        (vk_id, bdate, age, sex, city, faculty, cathedra, vk_interests, status, vk_all_group_names, vk_all_posts, vk_all_group_descr)
        VALUES
        (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    /,
    undef,
    $row->{id}, $row->{bdate}, $row->{age}, $row->{sex}, $row->{city}{title}, $row->{name}, '', $row->{interests}, $row->{status}, '', '', '' );
   print "User inserted";
}


my $res = $vk->query('groups.getMembers', {
    group_id => $group_id,
    extended => 1,
    fields => $ENV{'USER_GET_FIELDS'},
    count => 1000 # default
}); # arrayref

for my $row ( @{ $res->{response}{items} }) {
  insert_user($row);
}

# warn eDumper $res;
