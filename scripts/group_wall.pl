use VK;
use Data::Dumper;
use Data::Dumper::AutoEncode;

my $db = DB->new;

# Parse messages of the group
# e.g https://vk.com/wall-37119411_666350

$db->parse_wall_until_epoch(-37119411, 30);
