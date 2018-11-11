package DB;

use DBI;
use VK;

# use DBI::Log;
use DBD::MariaDB;
use Data::Dumper;
use Data::Dumper::AutoEncode;
use Text::CSV;
use utf8;

sub new {
    my $class = shift;
    my $dsn =
        "DBI:MariaDB:database="
      . $ENV{'DATABASE'}
      . ";host="
      . $ENV{'DB_HOST'}
      . ";port="
      . $ENV{'DB_PORT'};
    my $dbh = DBI->connect( $dsn, $ENV{'DB_USER'}, $ENV{'DB_PASSWORD'},
        { PrintError => 1, RaiseError => 1 } );
    return bless { vk => VK->new(), dbh => $dbh }, $class;
}

sub dbh {
    shift->{dbh};
}

sub vk {
    shift->{vk};
}

sub insert_group {
    my ( $self, $data ) = @_;
    $self->dbh->do(
        qq/
      INSERT
        INTO groups
        (vk_id, vk_name, vk_description)
        VALUES
        (?, ?, ?)
        ON DUPLICATE KEY UPDATE vk_id = VALUES(vk_id)
    /,
        undef,
        $data->{id}, $data->{name}, $data->{description}
    );
}

sub insert_post {
    my ( $self, $data ) = @_;
    $self->dbh->do(
        qq/
      INSERT
        INTO posts
        (owner_id, vk_post_id, created, text)
        VALUES
        (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE hash = VALUES(hash)
    /,
        undef,
        $data->{owner_id}, $data->{id}, $data->{date}, $data->{text} # from_id ?
    );
}

# Insert user and everything list of all his groups
sub insert_user {
    my ( $self, %params ) = @_;

    die "No user_data or user_id provided"
      if ( !defined $params{user_id} && !defined $params{user_data} );
    my $row = $params{user_data};

    if ( !defined $params{user_data} && defined $params{user_id} ) {

        $row = $self->vk->query(
            'users.get',
            {
                user_id  => $params{user_id},
                extended => 1,
                fields   => $ENV{'USER_GET_FIELDS'}
            }
        )->{response}->[0];

    }

    # print eDumper $row if $params{v};

    $row->{sex} = 'f' if ( $row->{sex} == 1 );
    $row->{sex} = 'm' if ( $row->{sex} == 2 );

    eval {

        # $self->dbh->begin_work;

        $self->dbh->do(
            qq/
            INSERT INTO
            users
            (vk_id, bdate, age, sex, city, faculty, cathedra, vk_interests, status, vk_all_group_names, vk_all_posts, vk_all_group_descr)
            VALUES
            (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE vk_id = VALUES(vk_id)
            /,
            undef,
            $row->{id}, $row->{bdate}, $row->{age}, $row->{sex},
            $row->{city}{title}, '', '', $row->{interests}, $row->{status}, '',
            '',                  ''
        );

        $rv = $self->dbh->last_insert_id();

        # warn $rv;

        # write user posts

        my $user_posts = $self->vk->query(
            'wall.get',
            {
                owner_id => $params{user_id},
                count    => $ENV{'USER_GET_WALL_LIMIT'}
            }
        )->{response}{items};

        # warn eDumper $user_posts;

        for my $post (@$user_posts) {
            $self->dbh->do(
                qq/
         INSERT
           INTO posts
           (owner_id, vk_post_id, created, text)
           VALUES
           (?, ?, ?, ?)
           ON DUPLICATE KEY UPDATE hash = VALUES(hash)
       /,
                undef,
                $post->{owner_id}, $post->{id}, $post->{date}, $post->{text}
            );
        }

        my $subscriptions = $self->vk->query(
            'users.getSubscriptions',
            {
                user_id  => $params{user_id},
                extended => 1,
                count    => $ENV{'USER_GET_SUBSCRIPTIONS_LIMIT'},    # max: 200
                fields   => 'city,description'
            }
        )->{response}{items};

        # return if (!@$subscriptions);
        $self->dbh->do(
            qq/
           INSERT
             INTO posts
             (owner_id, vk_post_id, created, text)
             VALUES
             (?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE hash = VALUES(hash)
         /,
            undef,
            $p->{owner_id}, $p->{id}, $p->{date}, $p->{text}    # from_id ?
        );

        for my $s (@$subscriptions) {

            # subscriptions
            $self->dbh->do(
                qq/
               INSERT
               INTO subscriptions
               (user_id, group_id)
               VALUES
               (?, ?)
               ON DUPLICATE KEY UPDATE hash = VALUES(hash)
               /,
                undef,
                $params{user_id}, $s->{id}
            );

            my $wall_posts = $self->vk->query(
                'wall.get',
                {
                    owner_id => $s->{id},
                    count    => $ENV{'GROUP_GET_WALL_POSTS_LIMIT'}
                }
            )->{response}{items};

            for my $p (@$wall_posts) {

                $self->dbh->do(
                    qq/
                       INSERT
                         INTO posts
                         (owner_id, vk_post_id, created, text)
                         VALUES
                         (?, ?, ?, ?)
                         ON DUPLICATE KEY UPDATE hash = VALUES(hash
                     /,
                    undef,
                    $p->{owner_id}, $p->{id}, $p->{date}, $p->{text} # from_id ?
                );

            }

        }

        # $self->dbh->commit;

    };
}

# http://127.0.0.1:3100/?user_id=4485606

sub get_user_preferences {
    my ( $self, %params ) = @_;

    my $user_id = $params{user_id};

    # interests, city, about, status, description
    my $row = $self->dbh->selectrow_hashref(
        "SELECT vk_id, vk_interests FROM users WHERE vk_id = $user_id");

    my $fav_groups = $self->dbh->selectall_arrayref(
        qq/
    SELECT vk_name, vk_description FROM groups
    WHERE vk_id
    IN ( SELECT group_id FROM subscriptions WHERE user_id = $user_id )
  /, { Slice => {} }
    );

    my $fav_group_posts_list = $self->dbh->selectall_arrayref(
        qq/
    SELECT owner_id,vk_post_id,text FROM posts
    WHERE owner_id
    IN ( SELECT group_id FROM subscriptions WHERE user_id = $user_id )
  /, { Slice => {} }
    );

    my $user_posts = $self->dbh->selectall_arrayref(
        qq/
    SELECT owner_id,vk_post_id,text FROM posts
    WHERE owner_id = $user_id/, { Slice => {} }
    );

    # ((?!\p{L}).)
    # s/[\;|\,|\\n\#\@]/ /

    my $vk_all_group_names = join( " ", map { $_->{vk_name} } @$fav_groups );
    $vk_all_group_names =~ s/((?!\p{L}).)/ /;

    my $vk_all_group_descr =
      join( " ", map { $_->{vk_description} } @$fav_groups );
    # $vk_all_group_descr =~ s/((?!\p{L}).)/ /;
    $vk_all_group_descr =~ s/\#/ /;

    # warn $vk_all_group_descr;

    my $vk_fav_group_posts_list =
      join( " ", map { $_->{vk_description} } @$fav_groups );
    $vk_fav_group_posts_list =~ s/((?!\p{L}).)/ /;

    my $vk_own_posts = join( " ", map { $_->{text} } @$user_posts );
    $vk_own_posts =~ s/((?!\p{L}).)/ /;

    return {
        vk_id                   => $user_id,
        vk_interests            => $row->{vk_interests},
        vk_all_group_names      => $vk_all_group_names,
        vk_all_group_descr      => $vk_all_group_descr,
        vk_fav_group_posts_list => $vk_fav_group_posts_list,
        vk_own_posts            => $vk_own_posts
    };
}

sub export_all_users_to_csv {
    my ( $self, %params) = @_;

    my $csv = Text::CSV->new()
      or die "Cannot use CSV: " . Text::CSV->error_diag();
    open my $fh, ">:encoding(utf8)", "test.csv" or die "test.csv: $!";
    $csv->eol("\012");

    my $all_user_ids = $self->dbh->selectall_arrayref( "SELECT vk_id FROM users",  { Slice => {} } );
    @$all_user_ids = map { $_->{vk_id} } @$all_user_ids;
    # warn Dumper \@$all_user_ids if $params{v};

    $csv->print( $fh, [
        'vk_id',
        'vk_interests',
        'vk_all_group_names',
        'vk_all_group_descr',
        'vk_fav_group_posts_list',
        'vk_own_posts'
    ] );

    for my $id (@$all_user_ids) {
        my $h = $self->get_user_preferences( user_id => $id );
        $csv->print( $fh, [
            $h->{'vk_id'},
            $h->{'vk_interests'},
            $h->{'vk_all_group_names'},
            $h->{'vk_all_group_descr'},
            $h->{'vk_fav_group_posts_list'},
            $h->{'vk_own_posts'}
        ] );
    }
}


#
# sub parse_wall_until_epoch {
#     my ( $self, $group_id, $days_ago ) = @_;
#
#     my $count     = 100;
#     my $first_100 = $vk->query(
#         'wall.get',
#         {
#             owner_id => $group_id,    # minus if group id
#             count    => $count
#         }
#     );
#
#     my $total = $first_100->{response}{count};
#     warn $total;
#
#     return 1 if ( $total < $count );
#
#     for (
#         @{ $first_100->{response}{items} )
#         {
#             $self->insert_post($_);
#         }
#
#         while ( $i < $total ) {
#             my @res = @{
#                 $vk->query(
#                     'groups.getMembers',
#                     {
#                         group_id => $group_id,
#                         extended => 1,
#                         fields   => $ENV{'USER_GET_FIELDS'},
#                         offset   => $i,
#                         count    => $count
#                     }
#                 )->{response}{items}
#             };
#             print "total: " . scalar @res . "\n";
#
#             warn eDumper $res[0];
#
#             for my $j ( 0 .. $#res ) {
#                 $db->insert_user( user_id => $res[$j]->{id} );
#                 print $i+ $j . ' | id: ' . $res[$j]->{id} . "\n";
#             }
#
#             $i = $i + $count;
#         }
#
#         }
#
# }
#
1;
