package Cobalt::Plugin::Calc;
our $VERSION = '0.01';

use Cobalt::Common;
use Cobalt::Plugin::Calc::Parser::MGC;

sub new { bless {}, shift }

sub Cobalt_register {
  my ($self, $core) = splice @_, 0, 2;
  
  $core->plugin_register( $self, 'SERVER',
    [
      'public_cmd_calc',
      'public_cmd_rpn',
    ],
  );
  
  return PLUGIN_EAT_NONE
}

sub Cobalt_unregister {
  my ($self, $core) = splice @_, 0, 2;
  
  return PLUGIN_EAT_NONE
}

sub Bot_public_cmd_calc {
  my ($self, $core) = splice @_, 0, 2;
  my $context = ${ $_[0] };
  my $msg     = ${ $_[1] };
  
  my $nick = $msg->{src_nick};
  
  my $calc = Cobalt::Plugin::Calc::Parser::MGC->new;
  
  my $calcstr = join '', @{ $msg->{message_array} };
  my $result;

  eval { $result = $calc->from_string($calcstr) };
  $result = "Parse failure." if $@;

  $core->send_event( 'send_message',
    $context, $msg->{channel},
    "${nick}: $result"
  );
  
  return PLUGIN_EAT_ALL
}

sub Bot_public_cmd_rpn {

}

1;
