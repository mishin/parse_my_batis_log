#!/usr/bin/perl
use warnings;
use strict;
use feature 'say';

sub replace {
	my ( $string, $from, $to, $count ) = @_;
	my $pos = '0E0';    # plain 0 means the string begins with $from
	while ( $count-- and $pos >= 0 ) {
		$pos = index $string, $from, $pos eq '0E0' ? $pos : $pos + 1;
	}
	substr $string, $pos, 1, $to if $pos > 0;
	return $string;
}

say replace( $_, '?' => '|', 3 ) for qw( a,b,c,d
  pq?rs?tu?vw
  ,s,t,a,r,t
  ,,yuck
  1,2
);
