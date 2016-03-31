use strict;
use feature 'say';
use warnings FATAL => 'all';
use utf8;
use open qw(:std :utf8);

#use v5.10;
use Data::Printer;

my $filename = shift or die "Usage: $0 name_of_my_batis.log name_of_my_batis.sql\n";
my $write_filename = shift;

main($filename, $write_filename);

sub main {
	my ($filename, $write_filename) = @_;
	my $PREPARE_RX =
	  qr{\[DEBUG\] ==>  Preparing:\s*(?<sql>.*?)\s*\[BaseJdbcLogger.java:\d+\]};
	my $PARAMETERS_RX =
qr{\[DEBUG\] ==> Parameters:\s*(?<parameters>.*?)\s*\[BaseJdbcLogger.java:\d+\]};
	my $sql_body;
	my $parameter_body;

	open( my $fh, '<:encoding(UTF-8)', $filename )
	  or die "Could not open file '$filename' $!";
    open(my $fho, '>:encoding(UTF-8)', $write_filename)
	  or die "Could not open file '$write_filename'";
	for my $line (<$fh>) {
		my %loc_sql;
		if ( $line =~ $PARAMETERS_RX ) {
			$parameter_body = $+{parameters};
			if ( defined $sql_body && $sql_body ne '' ) {
				print $fho get_full_sql( $sql_body, $parameter_body ). "\n";
			}
		}
		if ( $line =~ $PREPARE_RX ) {
			$sql_body = $+{sql};
		}
	}
	close $fho;
	close $fh;
}

sub get_full_sql {
	my ( $sql, $parameter ) = @_;
	if ( defined $parameter && $parameter ne '' ) {
		my @values = split /\s*,\s*/, $parameter;
		for (@values) {
			s/(.*?)\(\w+\)/$1/;
s/(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})[.]\d{1}/to_date('$1','YYYY-MM-DD HH24:MI:SS')/;
		}
		my $full_sql = get_sql_and_param( $sql, \@values );
		return get_sql_with_comma($full_sql);
	}
	else {
		return get_sql_with_comma($sql);
	}
}

sub get_sql_and_param {
	my ( $sql, $param ) = @_;
	my $loc_sql    = $sql;
	my @parameters = @{$param};
	my $len        = scalar @parameters;

	my $i      = 1;
	my $string = $sql;
	my $find   = '?';

	my $pos = index( $string, $find );
	while ( $pos > -1 ) {
		substr( $string, $pos, length($find),
			make_quote( $parameters[ $i - 1 ] ) );
		$pos = index( $string, $find,
			$pos + length( make_quote( $parameters[ $i - 1 ] ) ) );
		$i++;
	}

	return $string;
}

sub make_quote {
	my ($string) = @_;
	if ( $string =~ /to_date/ ) {
		return $string;
	}
	else {
		return "'" . $string . "'";
	}
}

sub find_nth {
	my ( $s, $c, $n ) = @_;
	my $pos = -1;
	while ( $n-- ) {
		$pos = index( $s, $c, $pos + 1 );
		return -1 if $pos == -1;
	}
	return $pos;
}

sub get_sql_with_comma {
	my ($sql) = @_;
	my $comma = '';
	if ( substr( $sql, -1 ) ne ';' ) {
		$comma = ';';
	}
	return $sql . $comma;
}

__DATA__
