use Data::Dumper;
use Data::Dumper::AutoEncode;

use DB;
use VK;
my $vk = VK->new;

my $group_id = 71991592;

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
