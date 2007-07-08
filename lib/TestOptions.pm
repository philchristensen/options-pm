#!/usr/bin/env perl

##################################################################
# TestOptions.pm
# 
# Tests for the Options.pm perl module
# 
# Copyright (C) 2005-2007 by Phil Christensen
##################################################################

use Options;
package TestOptions;
use base qw(Test::Unit::TestCase);

sub new {
	my $self = shift()->SUPER::new(@_);
	return $self;
}

sub set_up {
	my $self = shift;
	$self->{'options'} = new Options(params => [
							['port', 'p', undef, 'The port to connect to.'],
							['host', 'h', 'localhost', 'The host to connect to.']
							],
							flags =>  [
							['secure', 's', 'Use SSL for encryption.'],
							['quit', 'q', 'Quit after connecting.']
							]);
	
	$self->{'options'}->{'exit'} = undef;
	
	$self->{'options'}->{'err_handle_variable'} = '';
	open STRINGIO, '+>', \$self->{'options'}->{'err_handle_variable'} or die $!;
	$self->{'options'}->{'err_handle'} = \*STRINGIO;
}

sub tear_down {
	my $self = shift;
	$self->{'options'} = undef;
	close($self->{'options'}->{'err_handle'});
}

sub test_simple {
	my $self = shift;
	my @args = ('options.t', '--port', '8080');
	my %results = $self->{'options'}->get_options(@args);
	
	#$self->assert_not_null($obj);
	#$self->assert(qr/pattern/, $obj->foobar);
	$self->assert_equals('localhost', $results{'host'});
	$self->assert_equals('8080', $results{'port'});
	$self->assert_null($results{'something'}, 'Secure should not have been found.');
}

sub test_group_flags {
	my $self = shift;
	my @args = ('options.t', '--port', '8080', '-sq');
	my %results = $self->{'options'}->get_options(@args);
	
	$self->assert($results{'secure'}, "'secure' was not selected properly");
	$self->assert($results{'quit'}, "'quit' was not selected properly");
}

sub test_broken_group_flags {
	my $self = shift;
	my @args = ('options.t', '--port', '8080', '-sqh');
	
	$result = eval{
		my %results = $self->{'options'}->get_options(@args);
	};

	$self->assert_not_null($@, 'Improperly grouped parameter did not kill the script.');
	$self->assert_not_equals('', $self->{'options'}->{'err_handle_variable'},
					"No usage information found after improperly grouped parameter.");
}

sub test_broken_group_flags2 {
	my $self = shift;
	my @args = ('options.t', '--port', '8080', '-sqx');
	
	$result = eval{
		my %results = $self->{'options'}->get_options(@args);
	};

	$self->assert_not_null($@, 'Unknown grouped flag did not kill the script.');
	$self->assert_not_equals('', $self->{'options'}->{'err_handle_variable'},
					"No usage information found after unknown grouped flag.");
}

sub test_required {
	my $self = shift;
	my @args = ('options.t');
	
	$result = eval{
		my %results = $self->{'options'}->get_options(@args);
	};
	
	$self->assert_not_null($@, 'Missing required options did not kill the script.');
	$self->assert_not_equals('', $self->{'options'}->{'err_handle_variable'},
					"No usage information found after missing required argument.");
}

1;