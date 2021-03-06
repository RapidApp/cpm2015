use Plack::Builder;
use Plack::App::File;

use Path::Class 'file'; my $Bin = file($0)->parent; # Like FindBin
my $app = Plack::App::File->new( root => "$Bin" )->to_app; 

builder {
  enable 'Headers', set => [ 'Cache-Control' => 'no-cache' ];
  enable Plack::Util::load_psgi("$Bin/mw.psgi"); # custom middleware
  sub {
    my $env = shift;
    $env->{PATH_INFO} = '/index.html' if ($env->{PATH_INFO} eq '/');
    $env->{PATH_INFO} eq '' # i.e. redirect /foo to /foo/
      ? [ 302 => ['Location' => "$env->{SCRIPT_NAME}/"], [] ] 
      : $app->($env)
  };
}
