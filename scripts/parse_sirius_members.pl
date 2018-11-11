use Data::Dumper;
use Data::Dumper::AutoEncode;
# use utf8;
use DB;
use VK;
my $vk = VK->new;

my $group_id = 71991592;
my $count = 1000;

my $total = $vk->query('groups.getMembers', {
    group_id => $group_id,
    extended => 1,
    fields => $ENV{'USER_GET_FIELDS'},
    count => 1 # default
})->{response}{count};

warn $total;
my $i = 0;
my $db = DB->new;

while ( $i < $total ) {
  my @res = @{ $vk->query('groups.getMembers', {
        group_id => $group_id,
        extended => 1,
        fields => $ENV{'USER_GET_FIELDS'},
        offset => $i,
        count => $count
    })->{response}{items} };
    print "total: ".scalar @res."\n";

    warn eDumper $res[0];

    for my $j (0 .. $#res) {
      $db->insert_user(user_id => $res[$j]->{id} );
      print $i+$j.' | id: '.$res[$j]->{id}."\n";
    }

    $i = $i+$count;
}


# for ( my $i=0, $i > $total;  $i = $i+$count ) {
#   my $res = $vk->query('groups.getMembers', {
#       group_id => $group_id,
#       extended => 1,
#       fields => $ENV{'USER_GET_FIELDS'},
#       offset => $i,
#       count => $count
#   });
#   print "total: ".scalar @$res."\n";
# }

# warn Dumper $res;


# for my $row ( @{ $res->{response}{items} }) {
#   warn Dumper $row;
# }

# warn eDumper $res;
