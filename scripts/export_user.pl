# export_user

use DB;
  use Data::Dumper::AutoEncode;

my $user_id = $ARGV[0] || 4485606;

my $db = DB->new;
$db->export_user(user_id => $user_id);
