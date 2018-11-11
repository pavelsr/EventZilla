# Parse all user groups

use DB;
use Data::Dumper;
use Data::Dumper::AutoEncode;

my $db = DB->new;
warn Dumper $db->vk;
my $user_id = $ARGV[0] || 4485606;

$db->insert_user(user_id => $user_id, v => 1);

# warn eDumper $res;
