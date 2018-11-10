use VK;
use Data::Dumper;
use Data::Dumper::AutoEncode;

my $vk = VK->new;
my $user_id = 4485606;

warn Dumper $vk->query( 'users.getSubscriptions', {
    user_id => $user_id,
    extended => 1,
    count => 20
} );
