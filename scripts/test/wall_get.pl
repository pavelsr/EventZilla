use VK;
use Data::Dumper;
use Data::Dumper::AutoEncode;

my $vk = VK->new;
my $user_id = 4485606;

warn eDumper $vk->query( 'wall.get', {
    owner_id => $user_id,  # minus if group id
    count => 1
} );
