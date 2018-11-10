use VK;
use Data::Dumper;
use Data::Dumper::AutoEncode;

my $vk = VK->new;
my $user_id = 4485606;

warn eDumper $vk->query( 'users.get', {
    user_id => $user_id,
    extended => 1,
    fields => 'sex,bdate,city,education,occupation,status,interests'
    # count => 20s
} );
