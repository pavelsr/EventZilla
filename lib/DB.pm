package DB;

use DBI;
use VK;
use DBI::Log;
use DBD::MariaDB;
use Data::Dumper;
use Data::Dumper::AutoEncode;

# set of methods for working with database (DBI wrappers)

sub new {
  my $class = shift;
  my $dsn = "DBI:MariaDB:database=".$ENV{'DATABASE'}.";host=".$ENV{'DB_HOST'}.";port=".$ENV{'DB_PORT'};
  my $dbh = DBI->connect( $dsn, $ENV{'DB_USER'}, $ENV{'DB_PASSWORD'}, { PrintError => 1, RaiseError => 1 } );
  return bless { vk => VK->new(), dbh => $dbh }, $class;
}

sub dbh {
  shift->{dbh};
}

sub vk {
  shift->{vk};
}

# Insert user and list of all his groups

sub insert_user {
  my ($self, %params) = @_;

  die "No user_data or user_id provided" if ( !defined $params{user_id} && !defined $params{user_data} );
  my $row = $params{user_data};

  if ( !defined $params{user_data} && defined $params{user_id} ) {
    $row = $self->vk->query( 'users.get', {
        user_id => $params{user_id},
        extended => 1,
        fields => $ENV{'USER_GET_FIELDS'}
    } )->{response}->[0];
  }

  # print eDumper $row if $params{v};

  $row->{sex} = 'f' if ( $row->{sex} == 1 );
  $row->{sex} = 'm' if ( $row->{sex} == 2 );

  $self->dbh->begin_work;

  $self->dbh->do(
    qq/
      INSERT
        INTO users
        (vk_id, bdate, age, sex, city, faculty, cathedra, vk_interests, status, vk_all_group_names, vk_all_posts, vk_all_group_descr)
        VALUES
        (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE vk_id = VALUES(vk_id)
    /,
    undef,
    $row->{id}, $row->{bdate}, $row->{age}, $row->{sex}, $row->{city}{title}, '', '', $row->{interests}, $row->{status}, '', '', '' );

   $rv = $self->dbh->last_insert_id();
   warn $rv;

   # write user posts

   my $user_posts = $self->vk->query( 'wall.get', {
       owner_id => $params{user_id},
       count => $ENV{'USER_GET_WALL_LIMIT'}
   } )->{response}{items};

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

   my $subscriptions = $self->vk->query( 'users.getSubscriptions', {
       user_id => $params{user_id},
       extended => 1,
       count => $ENV{'USER_GET_SUBSCRIPTIONS_LIMIT'},   # max: 200
       fields => 'city,description'
   } )->{response}{items};

   for my $s (@$subscriptions) {

     # groups must be before subscriptions to make FOREIGN KEY WORK
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
       $s->{id}, $s->{name}, $s->{description}
     );

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

     my $wall_posts = $self->vk->query( 'wall.get', {
         owner_id => $s->{id},
         count => $ENV{'GROUP_GET_WALL_POSTS_LIMIT'}
     } )->{response}{items};

     for my $p (@$wall_posts) {

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
        $p->{owner_id}, $p->{id}, $p->{date}, $p->{text}  # from_id ?
     );

    }

   }

   $self->dbh->commit;
}

# http://127.0.0.1:3100/?user_id=4485606

sub export_user {
  my ($self, %params) = @_;

  my $user_id = $params{user_id};

  # interests, city, about, status, description
  my $row = $self->dbh->selectrow_hashref( "SELECT vk_id, vk_interests FROM users WHERE vk_id = $user_id" );

  my $fav_groups = $self->dbh->selectall_arrayref(qq/
    SELECT vk_name, vk_description FROM groups
    WHERE vk_id
    IN ( SELECT group_id FROM subscriptions WHERE user_id = $user_id )
  /, { Slice => {} } );

  my $fav_group_posts_list = $self->dbh->selectall_arrayref(qq/
    SELECT owner_id,vk_post_id,text FROM posts
    WHERE owner_id
    IN ( SELECT group_id FROM subscriptions WHERE user_id = $user_id )
  /, { Slice => {} } );

  my $user_posts = $self->dbh->selectall_arrayref(qq/
    SELECT owner_id,vk_post_id,text FROM posts
    WHERE owner_id = $user_id/, { Slice => {} }
    );

  return {
    vk_id => $row->{vk_id},
    vk_interests => $row->{vk_interests},
    vk_all_group_names => join(" ", map { $_->{vk_name} } @$fav_groups ),
    vk_all_group_descr => join(" ", map { $_->{vk_description} } @$fav_groups ),
    vk_fav_group_posts_list => join(" ", map { $_->{text} } @$fav_group_posts_list ),
    vk_own_posts => join(" ", map { $_->{text} } @$user_posts )
  }

}

1;
