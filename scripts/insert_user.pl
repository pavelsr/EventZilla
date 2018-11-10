# please provide user_id as $ARGV[0]

use VK;
use DB;
use Data::Dumper;
use Data::Dumper::AutoEncode;
use feature 'say';


my $vk = VK->new;
my $res = $vk->query( 'users.get', {
    user_id => $ARGV[0] || 4485606,  # Оля: 2606187,
    extended => 1,
    fields => $ENV{'USER_GET_FIELDS'}
} );

warn eDumper $res;

my $db = DB->new();
$db->insert_user($res->{response}->[0]);
