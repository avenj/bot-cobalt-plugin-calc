package Bot::Cobalt::Plugin::Calc;
our $VERSION = '0.002_01';

use 5.12.1;
use strictures 1;

use Bot::Cobalt;
use Bot::Cobalt::Common;

use Bot::Cobalt::Plugin::Calc::Parser;

sub new { bless {}, shift }

sub Cobalt_register {
  my ($self, $core) = splice @_, 0, 2;
  
  register( $self, 'SERVER',

    'public_cmd_calc',

  );
  
  logger->info("Loaded ($VERSION)");
  
  return PLUGIN_EAT_NONE
}

sub Cobalt_unregister {
  my ($self, $core) = splice @_, 0, 2;
  
  $core->unloader_cleanup('Bot::Cobalt::Plugin::Calc::Parser');
  
  logger->info("Unloaded");  
  
  return PLUGIN_EAT_NONE
}

sub Bot_public_cmd_calc {
  my ($self, $core) = splice @_, 0, 2;
  my $msg     = ${ $_[0] };
  
  my $calc = Bot::Cobalt::Plugin::Calc::Parser->new;
  
  my $msgarr  = $msg->message_array;
  my $calcstr = join '', @$msgarr;
  
  my $result;
  eval { $result = $calc->from_string($calcstr) };
  $result = "Parser said: $@" if $@;

  broadcast( 'message', $msg->context, $msg->channel,
    $msg->src_nick.": $result"
  );
  
  return PLUGIN_EAT_ALL
}


1;
__END__

=pod

=head1 NAME

Bot::Cobalt::Plugin::Calc - Simple calculator for Bot::Cobalt

=head1 SYNOPSIS

  !calc (2+2)*(2+4)
  !calc 0xff
  !calc 0644

=head1 DESCRIPTION

Simple L<Bot::Cobalt> calculator plugin using L<Parser::MGC>.

Understands - + * / ^ operations.

Also understands hex and octal.

=head1 TODO

A RPN-style calculator with a persistent per-user stack is planned as 
sort of an IRC C<dc> ... eventually.

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

L<http://www.cobaltirc.org>

=cut
