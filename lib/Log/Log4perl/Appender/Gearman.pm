package Log::Log4perl::Appender::Gearman;

use warnings;
use strict;

use base 'Log::Log4perl::Appender';
use Gearman::Client;

=head1 NAME

Log::Log4perl::Appender::Gearman - The great new Log::Log4perl::Appender::Gearman!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Log::Log4perl::Appender::Gearman;

    my $foo = Log::Log4perl::Appender::Gearman->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 function1

=cut

sub new {
    my ($class, %opt) = @_;
    $opt{job_servers} = [ split /,/, $opt{job_servers} ];
    my $self = bless {
        %opt,
        backlog => [],
    }, $class;
    $self->{gearman_client} = Gearman::Client->new
        ( job_servers => $self->{job_servers},
          prefix => $self->{prefix} );
    return $self;
}

sub log {
    my ($self, %params) = @_;

    # process backblog
    my $defer = 0;
    for (@{$self->{backlog}}) {
        $self->{gearman_client}->dispatch_background( $_ )
            or $defer = 1, last;
    }
    my $msg = join('|', @params{qw(log4p_level log4p_category message)});
    my $task = Gearman::Task->new($self->{jobname}, \$msg );

    if ( $defer ) {
        push @{$self->{backlog}}, $task;
        return;
    }

    unless ( $self->{gearman_client}->dispatch_background( $task ) ) {
        push @{$self->{backlog}}, $task;
        # XXX: or send to some fallback logger and make sure it
        # doesn't create a loop
        warn "unable to send log";
    }
}

=head1 AUTHOR

Chia-liang Kao, C<< <clako at clkao.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-log-log4perl-appender-gearman at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Log-Log4perl-Appender-Gearman>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Log::Log4perl::Appender::Gearman


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Log-Log4perl-Appender-Gearman>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Log-Log4perl-Appender-Gearman>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Log-Log4perl-Appender-Gearman>

=item * Search CPAN

L<http://search.cpan.org/dist/Log-Log4perl-Appender-Gearman/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Chia-liang Kao, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Log::Log4perl::Appender::Gearman
