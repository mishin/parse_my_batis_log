use warnings;
use strict;
use feature 'say';

#use v5.10;
use Data::Printer;

main();

sub main {

	# open my $file, '<', '8882099' or die $!;
	my @file = <DATA>;
	my @sql_for_execute;
	my $line;
	my $PREPARE_RX =
	  qr{\[DEBUG\] ==>  Preparing:\s*(?<sql>.*?)\s*\[BaseJdbcLogger.java:\d+\]};
	my $PARAMETERS_RX =
qr{\[DEBUG\] ==> Parameters:\s*(?<parameters>.*?)\s*\[BaseJdbcLogger.java:\d+\]};
	my $sql_body;
	my $parameter_body;
	my @big_sql;

	for $line (@file) {
		my %loc_sql;
		if ( $line =~ $PARAMETERS_RX ) {
			$parameter_body = $+{parameters};
			if ( defined $parameter_body && $parameter_body ne '' ) {

				#			print "parameter found: $+{parameters}\n";
			}
			if ( defined $sql_body && $sql_body ne '' ) {
				$loc_sql{sql}       = $sql_body;
				$loc_sql{parameter} = $parameter_body;
				push @big_sql, \%loc_sql;
			}
		}
		if ( $line =~ $PREPARE_RX ) {

			#		print "sql found: " . get_sql_with_comma( $+{sql} ) . "\n";
			$sql_body = $+{sql};
		}
	}

	for my $sql (@big_sql) {

		#	p $sql;
		if ( defined $sql->{parameter} && $sql->{parameter} ne '' ) {
			my @values = split /\s*,\s*/, $sql->{parameter};
			s /(.*?)\(\w+\)/$1/ for @values;

			#            p @values;
			say $sql->{sql};
			my $full_sql = get_sql_and_param( $sql->{sql}, \@values );

			say $full_sql;
		}
		else {
			#            say get_sql_with_comma( $sql->{sql} );
		}
	}
}

#p @big_sql;

sub get_sql_and_param {
	my ( $sql, $param ) = @_;
	my $loc_sql    = $sql;
	my @parameters = @{$param};
	my $len        = scalar @parameters;
	for ( my $i = 1 ; $i <= $len ; $i++ ) {
		my $replace_string = "'" . $parameters[$i-1] . "'";
		my $number         = find_nth( $loc_sql, '?', $i );
		substr( $loc_sql, $number, 1 ) = $replace_string;
	}

	return $loc_sql;
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
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: declare l_aspl_export_setting_cnt number; begin select count (*) into l_aspl_export_setting_cnt from aspl_export_setting; if l_aspl_export_setting_cnt = 1 then update aspl_export_setting set export_date = trunc(?); else insert into aspl_export_setting (export_date, load_flg) values (trunc(?), 'Y'); end if; end;  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.setAsplActualDate]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters: 2016-01-15 00:00:00.0(Timestamp), 2016-01-15 00:00:00.0(Timestamp) [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.setAsplActualDate]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: select column_name from user_tab_cols where upper(table_name) = upper(?) and upper(column_name) not in ( upper(?) , upper(?) )  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getTableColumns]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters: XLS_OPERATION_TYPE(String), OPERATIONTYPEID(String), LOAD_DATE(String) [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getTableColumns]