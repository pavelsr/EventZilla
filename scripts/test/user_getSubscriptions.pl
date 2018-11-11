use VK;
use Data::Dumper;
use Data::Dumper::AutoEncode;

my $vk = VK->new;
my $user_id = 4485606;

my $res = $vk->query( 'users.getSubscriptions', {
    user_id => $user_id,
    extended => 1,
    count => 2,   # max: 200,
    fields => 'city,description,posts'
} )->{response}{items};

warn Dumper $res;

my @a = map { $_->{city}{title} } @$res;

warn Dumper \@a;
