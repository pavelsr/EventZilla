use DB;
my $db = DB->new;
$db->export_all_users_to_csv(v=>1);
