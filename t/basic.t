#!/usr/bin/perl -w
use strict;
use Log::Log4perl;

my $conf = q(

log4perl.category.test          = DEBUG, Screen, GM

log4perl.appender.GM          = Log::Log4perl::Appender::Gearman
log4perl.appender.GM.job_servers = 127.0.0.1, 10.0.1.1
#log4perl.appender.GM.prefix = moose
log4perl.appender.GM.jobname = logme
log4perl.appender.GM.layout = Log::Log4perl::Layout::SimpleLayout

log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
log4perl.appender.Screen.stderr  = 0
#log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout
log4perl.appender.Screen.layout   = Log::Log4perl::Layout::PatternLayout
log4perl.appender.Screen.layout.ConversionPattern = [%r] %F %L %m%n

      );

         # ... passed as a reference to init()
Log::Log4perl::init( \$conf );
warn "WTF?";
my $logger = Log::Log4perl->get_logger('test');
$logger->warn("hate 1");
$logger->warn("hate 2");
sleep 5;
$logger->debug('mmmm');
