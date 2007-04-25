package Catalyst::Plugin::Log::Handler;
use strict;
use warnings;

=head1 NAME

Catalyst::Plugin::Log::Handler - Catalyst Plugin for Log::Handler

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';

use NEXT;

sub setup {
    my $c = shift;

    my $config = $c->config->{'Log::Handler'} || {};

    $c->log((__PACKAGE__ . '::Backend')->new($config));

    return $c->NEXT::setup(@_);
}


package Catalyst::Plugin::Log::Handler::Backend;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use Log::Handler 0.11;

__PACKAGE__->mk_accessors(qw(_handler));

my %cat_to_handler_level = (
    debug => 'debug',
    info  => 'info',
    warn  => 'warning',
    error => 'error',
    fatal => 'emergency',
);

{

    while (my ($catlevel, $handlerlevel) = each %cat_to_handler_level) {

	no strict 'refs';

	*{$catlevel} = sub {
	    use strict;
            my $self = shift;

	    $self->_handler->$handlerlevel(@_);
        };

	my $handlerfunc = "would_log_$handlerlevel";
        *{"is_$catlevel"} = sub {
	    use strict;
            my $self = shift;

	    $self->_handler->$handlerfunc();
        };
    }
}

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new;

    my ($config) = @_;

    unless (exists $config->{filename}) {
	warn "There's no Log::Handler->filename in your Catalyst ".
	"app configuration.\n";
    }

    # Log::Handler->new will fail if there's no filename in the conf.  But let's
    # try it anyway to convince the user.

    $self->_handler(Log::Handler->new(
	minlevel => 0,
	maxlevel => 7,
	%$config,
    ));
    return $self;
}

*levels = *enable = *disable = sub { return 0; };

1;
__END__

=head1 SYNOPSIS

    use Catalyst qw(Log::Handler);

Catalyst configuration (e. g. in YAML format):

    Log::Handler:
        filename: /var/log/myapp.log
        fileopen: 1
        mode: append
        newline: 1

=head1 DESCRIPTION

If your L<Catalyst> project logs many messages, logging via standard error to
Apache's error log is not very clean: The log messages are mixed with other web
applications' noise; and especially if you use mod_fastcgi, every line will be
prepended with a long prefix.

An alternative is logging to a file.  But then you have to make sure that
multiple processes won't corrupt the log file.  The module L<Log::Handler> by
Jonny Schulz does exactly this, because it supports message-wise flocking.

This module is a wrapper for said L<Log::Handler>.

=head1 METHODS

=head2 debug, info, warn, error, fatal

These methods map to the L<Log::Handler> methods with the same name, except
for fatal, which maps to emergency, and warn, which maps to warning.  This is
because L<Catalyst> and L<Log::Handler> don't use the same names for log
levels.

=head2 is_debug, is_info, ...

These methods map to the L<Log::Handler> methods would_log_debug,
would_log_info, ...

=head1 CONFIGURATION

All configuration options are passed verbatim to Log::Handler::new.  See
L<Log::Handler> for explanation of the options.  I think that the example
configuration at the beginning of this document is very well-suited for a
Catalyst application.  (Except for the file name, of course.)

To be consistent with L<Catalyst::Log>, the options minlevel and maxlevel
default to 0 and 7, respectively.  The other defaults are not touched.

If you use L<Catalyst::Plugin::ConfigLoader>,
please load this module after L<Catalyst::Plugin::ConfigLoader>.

=head1 AUTHOR

Christoph Bussenius <pepe(at)cpan.org>.

=head1 COPYRIGHT

Copyright (C) 2007 Christoph Bussenius.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
