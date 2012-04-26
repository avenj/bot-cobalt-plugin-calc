package Bot::Cobalt::Plugin::Calc;
our $VERSION = '0.04';

use 5.10.1;
use Bot::Cobalt::Common;
use Bot::Cobalt::Plugin::Calc::Parser::MGC;

sub new { bless {}, shift }

sub Cobalt_register {
  my ($self, $core) = splice @_, 0, 2;
  
  $core->plugin_register( $self, 'SERVER',
    [
      'public_cmd_calc',
      'public_cmd_rpn',
    ],
  );
  
  $core->log->info("Loaded");
  return PLUGIN_EAT_NONE
}

sub Cobalt_unregister {
  my ($self, $core) = splice @_, 0, 2;
  $core->unloader_cleanup('Bot::Cobalt::Plugin::Calc::Parser::MGC');
  $core->log->info("Unloaded");  
  return PLUGIN_EAT_NONE
}

sub Bot_public_cmd_calc {
  my ($self, $core) = splice @_, 0, 2;
  my $msg     = ${ $_[0] };
  my $context = $msg->context;
  
  my $nick = $msg->src_nick;
  
  my $calc = Bot::Cobalt::Plugin::Calc::Parser::MGC->new;
  
  my $msgarr  = $msg->message_array;
  my $calcstr = join '', @$msgarr;
  my $result;

  eval { $result = $calc->from_string($calcstr) };
  $result = "Parser said: $@" if $@;

  $core->send_event( 'send_message',
    $context, $msg->channel,
    "${nick}: $result"
  );
  
  return PLUGIN_EAT_ALL
}


1;
__END__

=pod

=head1 NAME

Bot::Cobalt::Plugin::Calc - Simple calculator for Cobalt

=head1 SYNOPSIS

  !calc (2+2)*(2+4)
  !calc 0xff
  !calc 0644

=head1 DESCRIPTION

Simple calculator.

Understands - + * / operations.

Also understands hex and octal.

A RPN-style calculator with a stack is planned.

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

L<http://www.cobaltirc.org>

=cut