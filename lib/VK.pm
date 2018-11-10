package VK;

use Mojo::UserAgent;
use feature 'say';
use Data::Dumper;

my $ua = Mojo::UserAgent->new;
my $vk_api_endpoint = 'https://api.vk.com/method/';

sub new {
  my $class = shift;
  return bless {}, $class;
}

# sub get_service_key {
#   # https://vk.com/dev/client_cred_flow
# }
#
# sub get_user_key {
#   # https://vk.com/dev/authcode_flow_user
# }

sub query {
  my ($self, $method, $params) = @_;

  $params->{v} = $ENV{'VK_API_VERSION'};
  $params->{access_token} = $ENV{'APP_ACCESS_TOKEN'};

  my $res = $ua->get($vk_api_endpoint.$method => form => $params)->res; # or ->post if data is higher than 2KB
  # $res = Mojo::Message::Response
  if    ($res->is_error)  { die $res->message  }
  elsif ($res->is_success)    { return $res->json }    # ->{response}
  elsif ($res->code == 301) { die $res->headers->location }
  else                      { die 'API connection error' }
}
