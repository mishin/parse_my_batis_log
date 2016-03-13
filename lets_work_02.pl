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
			if ( defined $sql_body && $sql_body ne '' ) {
				$loc_sql{sql}       = $sql_body;
				$loc_sql{parameter} = $parameter_body;
				push @big_sql, \%loc_sql;
			}
		}
		if ( $line =~ $PREPARE_RX ) {
			$sql_body = $+{sql};
		}
	}

	for my $sql (@big_sql) {

		if ( defined $sql->{parameter} && $sql->{parameter} ne '' ) {
			my @values = split /\s*,\s*/, $sql->{parameter};
			for (@values) {
				s/(.*?)\(\w+\)/$1/;
s/(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})[.]\d{1}/to_date('$1','YYYY-MM-DD HH24:MI:SS')/;
			}
			my $full_sql = get_sql_and_param( $sql->{sql}, \@values );
			say get_sql_with_comma($full_sql);
		}
		else {
			say get_sql_with_comma( $sql->{sql} );
		}
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
[AspLink-2.00-SNAPSHOT] [INFO] Loaded default TestExecutionListener class names from location [META-INF/spring.factories]: [org.springframework.test.context.web.ServletTestExecutionListener, org.springframework.test.context.support.DependencyInjectionTestExecutionListener, org.springframework.test.context.support.DirtiesContextTestExecutionListener, org.springframework.test.context.transaction.TransactionalTestExecutionListener, org.springframework.test.context.jdbc.SqlScriptsTestExecutionListener] [AbstractTestContextBootstrapper.java:256] [org.springframework.test.context.support.DefaultTestContextBootstrapper]
[AspLink-2.00-SNAPSHOT] [INFO] Using TestExecutionListeners: [org.springframework.test.context.web.ServletTestExecutionListener@27d415d9, org.springframework.test.context.support.DependencyInjectionTestExecutionListener@5c18298f, org.springframework.test.context.support.DirtiesContextTestExecutionListener@31f924f5, org.springframework.test.context.transaction.TransactionalTestExecutionListener@5579bb86, org.springframework.test.context.jdbc.SqlScriptsTestExecutionListener@5204062d] [AbstractTestContextBootstrapper.java:182] [org.springframework.test.context.support.DefaultTestContextBootstrapper]
[AspLink-2.00-SNAPSHOT] [INFO] Loading XML bean definitions from class path resource [META-INF/spring-asplink-overall-test-config.xml] [XmlBeanDefinitionReader.java:317] [org.springframework.beans.factory.xml.XmlBeanDefinitionReader]
[AspLink-2.00-SNAPSHOT] [INFO] Loading XML bean definitions from class path resource [META-INF/spring-asplink-core-config.xml] [XmlBeanDefinitionReader.java:317] [org.springframework.beans.factory.xml.XmlBeanDefinitionReader]
[AspLink-2.00-SNAPSHOT] [INFO] Loading XML bean definitions from class path resource [META-INF/spring-asplink-datasource-test-config.xml] [XmlBeanDefinitionReader.java:317] [org.springframework.beans.factory.xml.XmlBeanDefinitionReader]
[AspLink-2.00-SNAPSHOT] [INFO] Loading XML bean definitions from class path resource [META-INF/spring-asplink-kie-config.xml] [XmlBeanDefinitionReader.java:317] [org.springframework.beans.factory.xml.XmlBeanDefinitionReader]
[AspLink-2.00-SNAPSHOT] [INFO] Refreshing org.springframework.context.support.GenericApplicationContext@77a57272: startup date [Mon Mar 14 02:02:00 MSK 2016]; root of context hierarchy [AbstractApplicationContext.java:511] [org.springframework.context.support.GenericApplicationContext]
[AspLink-2.00-SNAPSHOT] [INFO] Loading properties file from class path resource [kie.properties] [PropertiesLoaderSupport.java:172] [org.springframework.beans.factory.config.PropertyPlaceholderConfigurer]
[AspLink-2.00-SNAPSHOT] [INFO] Loading properties file from class path resource [sftp.properties] [PropertiesLoaderSupport.java:172] [org.springframework.beans.factory.config.PropertyPlaceholderConfigurer]
[AspLink-2.00-SNAPSHOT] [INFO] JSR-330 'javax.inject.Inject' annotation found and supported for autowiring [AutowiredAnnotationBeanPostProcessor.java:153] [org.springframework.beans.factory.annotation.AutowiredAnnotationBeanPostProcessor]
[AspLink-2.00-SNAPSHOT] [INFO] Loading properties file from class path resource [messages.properties] [PropertiesLoaderSupport.java:172] [org.springframework.beans.factory.config.PropertiesFactoryBean]
[AspLink-2.00-SNAPSHOT] [INFO] Loading properties file from class path resource [testdata.properties] [PropertiesLoaderSupport.java:172] [org.springframework.beans.factory.config.PropertiesFactoryBean]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from SYS_DATA_LOAD_LOG  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 2 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from ASPL_EXPORT_SETTING  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from ASPL_MERGE_STATUS  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from ASPL_DICTIONARY_FILE  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from DWH_CLIENT  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 3 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from DWH_CLIENT_PORTFOLIO_HOLDING  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 3 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from DWH_SECURITY_SUB_ASSET_CLASS  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 0 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from DWH_OPERATION_TYPE  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 3 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from DWH_MODEL_PORTFOLIO_STRUCTURE  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 0 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from DWH_MODEL_PORTFOLIO  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 0 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from XLS_CLIENT  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 0 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from XLS_CLIENT_PORTFOLIO_HOLDING  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 0 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from XLS_SECURITY_SUB_ASSET_CLASS  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 0 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from XLS_OPERATION_TYPE  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 2 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from XLS_MODEL_PORTFOLIO_STRUCTURE  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 0 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from XLS_MODEL_PORTFOLIO  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 0 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from ASPL_CLIENT  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 0 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from ASPL_CLIENT_PORTFOLIO_HOLDING  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 0 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from ASPL_SECURITY_SUB_ASSET_CLASS  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 0 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from ASPL_OPERATION_TYPE  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 5 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from ASPL_MODEL_PORTFOLIO_STRUCTURE  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 0 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from ASPL_MODEL_PORTFOLIO  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 0 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from XLS_OPERATION_TYPE  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 0 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: insert into XLS_OPERATION_TYPE ( "OPERATIONTYPEID" , "CODE" , "name" , "DESCRIPTION" , "DIRECTION" , "LOAD_DATE" ) values ( 1 , 'a1' , 'Buy' , 'Buy transaction on secondary market' , 'CREDIT' , to_date('13.01.2016', 'dd.mm.yyyy') )  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: insert into XLS_OPERATION_TYPE ( "OPERATIONTYPEID" , "CODE" , "name" , "DESCRIPTION" , "DIRECTION" , "LOAD_DATE" ) values ( 2 , 'b1' , 'Cancel' , 'Cancellation of earlier transaction' , 'NO CHANGE' , to_date('13.01.2016', 'dd.mm.yyyy') )  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: insert into XLS_OPERATION_TYPE ( "OPERATIONTYPEID" , "CODE" , "name" , "DESCRIPTION" , "DIRECTION" , "LOAD_DATE" ) values ( 3 , 'c1' , 'Cancel' , 'Cancellation of earlier transaction' , 'NO CHANGE' , to_date('13.01.2016', 'dd.mm.yyyy') )  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from ASPL_DICTIONARY_FILE  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 0 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: insert into ASPL_DICTIONARY_FILE ( "ID" , "DICTIONARY_ID" , "FILENAME" , "STATUS_ID" , "FILE_DATA" , "LOAD_DATE" ) values ( 2 , 23 , '23. Operation types1.xlsx' , 4 , EMPTY_BLOB() , to_date('13.01.2016', 'dd.mm.yyyy') )  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: declare l_aspl_export_setting_cnt number; begin select count (*) into l_aspl_export_setting_cnt from aspl_export_setting; if l_aspl_export_setting_cnt = 1 then update aspl_export_setting set export_date = trunc(?); else insert into aspl_export_setting (export_date, load_flg) values (trunc(?), 'Y'); end if; end;  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.setAsplActualDate]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters: 2016-01-15 00:00:00.0(Timestamp), 2016-01-15 00:00:00.0(Timestamp) [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.setAsplActualDate]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: select column_name from user_tab_cols where upper(table_name) = upper(?) and upper(column_name) not in ( upper(?) , upper(?) )  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getTableColumns]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters: XLS_OPERATION_TYPE(String), OPERATIONTYPEID(String), LOAD_DATE(String) [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getTableColumns]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==      Total: 4 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getTableColumns]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: declare l_report_dttm sys_data_load_log.report_dttm%type; l_load_type sys_data_load_log.load_type%type; l_status_cd sys_data_load_log.status_cd%type; l_max_log_id sys_data_load_log.log_id%type; l_dwh_table_cnt number; l_aspl_export_setting_cnt number; l_aspl_merge_status_cnt number; l_table_name varchar2 (30 byte) := 'DWH_OPERATION_TYPE'; l_table_code varchar2(30 byte); l_table_id varchar2(30 byte) := '2'; begin l_table_name := upper(l_table_name); select count (*) into l_aspl_export_setting_cnt from aspl_export_setting; if l_aspl_export_setting_cnt = 1 then select count(*) into l_aspl_merge_status_cnt from aspl_merge_status where table_name = l_table_name; if l_aspl_merge_status_cnt = 0 then merge into (select cl."CODE", cl."name", cl."DESCRIPTION", cl."DIRECTION", cl."OPERATIONTYPEID", cl."LOAD_DATE", cl."SRC_ID" from aspl_OPERATION_TYPE cl where cl.load_date = (select trunc(export_date) from aspl_export_setting)) trg using (select cl2."CODE", cl2."name", cl2."DESCRIPTION", cl2."DIRECTION", cl2."OPERATIONTYPEID", cl2."LOAD_DATE", cl2."SRC_ID" from aspl_OPERATION_TYPE cl2 where trunc(cl2.load_date) = (select trunc(export_date) - 1 as prev_date from aspl_export_setting)) src on ( trg."OPERATIONTYPEID" = src."OPERATIONTYPEID" and trg.load_date = (select trunc(export_date) from aspl_export_setting)) when not matched then insert ( trg."CODE", trg."name", trg."DESCRIPTION", trg."DIRECTION", trg."OPERATIONTYPEID", trg."LOAD_DATE", trg."SRC_ID") values ( src."CODE", src."name", src."DESCRIPTION", src."DIRECTION", src."OPERATIONTYPEID", (select trunc(export_date) from aspl_export_setting), src."SRC_ID"); insert into aspl_merge_status (table_name, load_flg) values (l_table_name, 'Y'); end if; select max (log_id) into l_max_log_id from sys_data_load_log l; if l_max_log_id is not null then select report_dttm, load_type, status_cd into l_report_dttm, l_load_type, l_status_cd from sys_data_load_log where log_id = l_max_log_id; if l_load_type = 'ASPLINK' and l_status_cd = 'L' then select count (*) into l_dwh_table_cnt from dwh_OPERATION_TYPE; if l_dwh_table_cnt = 0 then insert into aspl_system_log (id, load_date, message) values (aspl_system_log_seq.nextval, sysdate, '������� dwh_OPERATION_TYPE ������ �� dwh ������'); end if; merge into aspl_OPERATION_TYPE trg using dwh_OPERATION_TYPE src on ( trg."OPERATIONTYPEID" = src."OPERATIONTYPEID" and trunc(trg.load_date) = (select trunc(export_date) from aspl_export_setting)) when matched then update set trg."CODE" = src."CODE" , trg."name" = src."name" , trg."DESCRIPTION" = src."DESCRIPTION" , trg."DIRECTION" = src."DIRECTION" ,trg.src_id = 1 when not matched then insert ( trg."CODE", trg."name", trg."DESCRIPTION", trg."DIRECTION", trg."OPERATIONTYPEID", trg."LOAD_DATE", trg."SRC_ID") values ( src."CODE", src."name", src."DESCRIPTION", src."DIRECTION", src."OPERATIONTYPEID", (select trunc(export_date) from aspl_export_setting), 1); begin for rec in (select aspl."OPERATIONTYPEID", trunc(aspl.load_date) load_date from aspl_OPERATION_TYPE aspl left join dwh_OPERATION_TYPE dwh on ( aspl."OPERATIONTYPEID" = dwh."OPERATIONTYPEID" and trunc(aspl.load_date) = (select trunc(export_date) from aspl_export_setting)) where aspl.src_id = 1 and coalesce ( null, dwh."OPERATIONTYPEID" ) is null ) loop begin insert into aspl_system_log (id, load_date, message) values (aspl_system_log_seq.nextval, sysdate, '� ������� operation_type aspl_OPERATION_TYPE c aspl."OPERATIONTYPEID" = '|| rec."OPERATIONTYPEID"||' ' || rec.operationtypeid || ' �������� ������ �� �������������'); update aspl_OPERATION_TYPE aspl set aspl.src_id = 0 where aspl."OPERATIONTYPEID" = rec."OPERATIONTYPEID" ; end; end loop; end; end if; end if; if l_table_id is not null and not length(l_table_id) = 0 then select ad.code into l_table_code from aspl_dictionary_file af join aspl_dictionary ad on (af.dictionary_id = ad.id) where af.id = l_table_id; if l_table_code is not null and UPPER(l_table_code) = UPPER('OPERATION_TYPE') then merge into aspl_OPERATION_TYPE trg using xls_OPERATION_TYPE src on ( trg."OPERATIONTYPEID" = src."OPERATIONTYPEID" and trunc(trg.load_date) = trunc(src.load_date)) when matched then update set trg."CODE" = src."CODE" , trg."name" = src."name" , trg."DESCRIPTION" = src."DESCRIPTION" , trg."DIRECTION" = src."DIRECTION" where trg.src_id = 0 when not matched then insert ( trg."CODE", trg."name", trg."DESCRIPTION", trg."DIRECTION", trg."OPERATIONTYPEID", trg."LOAD_DATE", trg."SRC_ID") values ( src."CODE", src."name", src."DESCRIPTION", src."DIRECTION", src."OPERATIONTYPEID", src."LOAD_DATE", 0); end if; end if; end if; end;  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.dwhAndExcelMerge]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.dwhAndExcelMerge]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from DWH_OPERATION_TYPE  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 0 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: insert into DWH_OPERATION_TYPE ( "OPERATIONTYPEID" , "CODE" , "name" , "DESCRIPTION" , "DIRECTION" ) values ( 1 , 'a2' , 'Buy' , 'Buy transaction on secondary market' , 'CREDIT' )  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: insert into DWH_OPERATION_TYPE ( "OPERATIONTYPEID" , "CODE" , "name" , "DESCRIPTION" , "DIRECTION" ) values ( 4 , 'f1' , 'Cancel' , 'Cancellation of earlier transaction' , 'NO CHANGE' )  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: declare l_aspl_export_setting_cnt number; begin select count (*) into l_aspl_export_setting_cnt from aspl_export_setting; if l_aspl_export_setting_cnt = 1 then update aspl_export_setting set export_date = trunc(?); else insert into aspl_export_setting (export_date, load_flg) values (trunc(?), 'Y'); end if; end;  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.setAsplActualDate]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters: 2016-01-13 00:00:00.0(Timestamp), 2016-01-13 00:00:00.0(Timestamp) [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.setAsplActualDate]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from aspl_merge_status  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: select export_date from aspl_export_setting  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getAsplActualDate]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getAsplActualDate]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==      Total: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getAsplActualDate]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: declare l_report_dttm sys_data_load_log.report_dttm%type; l_load_type sys_data_load_log.load_type%type; l_status_cd sys_data_load_log.status_cd%type; l_max_log_id sys_data_load_log.log_id%type; l_next_log_id sys_data_load_log.log_id%type; begin select max(log_id) into l_max_log_id from sys_data_load_log l; if l_max_log_id is not null then select report_dttm, load_type, status_cd into l_report_dttm, l_load_type, l_status_cd from sys_data_load_log where log_id = l_max_log_id; end if; if not (l_load_type = 'ASPLINK' and l_status_cd = 'L') or l_max_log_id is null then select sys_data_load_log_seq.nextval into l_next_log_id from dual; insert into sys_data_load_log (log_id, load_type, report_dttm, status_cd, loading_start_dttm, loading_end_dttm) values (l_next_log_id, 'DWH', trunc(?), 'D', sysdate, null); end if; end;  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.addStatusDwhDone]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters: 2016-01-13 00:00:00.0(Timestamp) [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.addStatusDwhDone]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: declare l_report_dttm sys_data_load_log.report_dttm%type; l_load_type sys_data_load_log.load_type%type; l_status_cd sys_data_load_log.status_cd%type; l_max_log_id sys_data_load_log.log_id%type; l_next_log_id sys_data_load_log.log_id%type; c_status_cd constant sys_data_load_log.status_cd%type := ?; begin select max(log_id) into l_max_log_id from sys_data_load_log l; if l_max_log_id is not null then select report_dttm, load_type, status_cd into l_report_dttm, l_load_type, l_status_cd from sys_data_load_log where log_id = l_max_log_id; if l_load_type = 'DWH' and l_status_cd = 'D' then select sys_data_load_log_seq.nextval into l_next_log_id from dual; insert into sys_data_load_log (log_id, load_type, report_dttm, status_cd, loading_start_dttm, loading_end_dttm) values (l_next_log_id, 'ASPLINK', l_report_dttm, c_status_cd, sysdate, null); elsif l_load_type = 'ASPLINK' and l_status_cd = 'L' then update sys_data_load_log set status_cd = c_status_cd, loading_end_dttm = sysdate where log_id = l_max_log_id; end if; end if; end;  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.updateDwhSysLog]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters: L(String) [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.updateDwhSysLog]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: select column_name from user_tab_cols where upper(table_name) = upper(?) and upper(column_name) not in ( upper(?) , upper(?) )  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getTableColumns]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters: XLS_OPERATION_TYPE(String), OPERATIONTYPEID(String), LOAD_DATE(String) [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getTableColumns]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==      Total: 4 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getTableColumns]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: declare l_report_dttm sys_data_load_log.report_dttm%type; l_load_type sys_data_load_log.load_type%type; l_status_cd sys_data_load_log.status_cd%type; l_max_log_id sys_data_load_log.log_id%type; l_dwh_table_cnt number; l_aspl_export_setting_cnt number; l_aspl_merge_status_cnt number; l_table_name varchar2 (30 byte) := 'DWH_OPERATION_TYPE'; l_table_code varchar2(30 byte); l_table_id varchar2(30 byte) := ''; begin l_table_name := upper(l_table_name); select count (*) into l_aspl_export_setting_cnt from aspl_export_setting; if l_aspl_export_setting_cnt = 1 then select count(*) into l_aspl_merge_status_cnt from aspl_merge_status where table_name = l_table_name; if l_aspl_merge_status_cnt = 0 then merge into (select cl."CODE", cl."name", cl."DESCRIPTION", cl."DIRECTION", cl."OPERATIONTYPEID", cl."LOAD_DATE", cl."SRC_ID" from aspl_OPERATION_TYPE cl where cl.load_date = (select trunc(export_date) from aspl_export_setting)) trg using (select cl2."CODE", cl2."name", cl2."DESCRIPTION", cl2."DIRECTION", cl2."OPERATIONTYPEID", cl2."LOAD_DATE", cl2."SRC_ID" from aspl_OPERATION_TYPE cl2 where trunc(cl2.load_date) = (select trunc(export_date) - 1 as prev_date from aspl_export_setting)) src on ( trg."OPERATIONTYPEID" = src."OPERATIONTYPEID" and trg.load_date = (select trunc(export_date) from aspl_export_setting)) when not matched then insert ( trg."CODE", trg."name", trg."DESCRIPTION", trg."DIRECTION", trg."OPERATIONTYPEID", trg."LOAD_DATE", trg."SRC_ID") values ( src."CODE", src."name", src."DESCRIPTION", src."DIRECTION", src."OPERATIONTYPEID", (select trunc(export_date) from aspl_export_setting), src."SRC_ID"); insert into aspl_merge_status (table_name, load_flg) values (l_table_name, 'Y'); end if; select max (log_id) into l_max_log_id from sys_data_load_log l; if l_max_log_id is not null then select report_dttm, load_type, status_cd into l_report_dttm, l_load_type, l_status_cd from sys_data_load_log where log_id = l_max_log_id; if l_load_type = 'ASPLINK' and l_status_cd = 'L' then select count (*) into l_dwh_table_cnt from dwh_OPERATION_TYPE; if l_dwh_table_cnt = 0 then insert into aspl_system_log (id, load_date, message) values (aspl_system_log_seq.nextval, sysdate, '������� dwh_OPERATION_TYPE ������ �� dwh ������'); end if; merge into aspl_OPERATION_TYPE trg using dwh_OPERATION_TYPE src on ( trg."OPERATIONTYPEID" = src."OPERATIONTYPEID" and trunc(trg.load_date) = (select trunc(export_date) from aspl_export_setting)) when matched then update set trg."CODE" = src."CODE" , trg."name" = src."name" , trg."DESCRIPTION" = src."DESCRIPTION" , trg."DIRECTION" = src."DIRECTION" ,trg.src_id = 1 when not matched then insert ( trg."CODE", trg."name", trg."DESCRIPTION", trg."DIRECTION", trg."OPERATIONTYPEID", trg."LOAD_DATE", trg."SRC_ID") values ( src."CODE", src."name", src."DESCRIPTION", src."DIRECTION", src."OPERATIONTYPEID", (select trunc(export_date) from aspl_export_setting), 1); begin for rec in (select aspl."OPERATIONTYPEID", trunc(aspl.load_date) load_date from aspl_OPERATION_TYPE aspl left join dwh_OPERATION_TYPE dwh on ( aspl."OPERATIONTYPEID" = dwh."OPERATIONTYPEID" and trunc(aspl.load_date) = (select trunc(export_date) from aspl_export_setting)) where aspl.src_id = 1 and coalesce ( null, dwh."OPERATIONTYPEID" ) is null ) loop begin insert into aspl_system_log (id, load_date, message) values (aspl_system_log_seq.nextval, sysdate, '� ������� operation_type aspl_OPERATION_TYPE c aspl."OPERATIONTYPEID" = '|| rec."OPERATIONTYPEID"||' ' || rec.operationtypeid || ' �������� ������ �� �������������'); update aspl_OPERATION_TYPE aspl set aspl.src_id = 0 where aspl."OPERATIONTYPEID" = rec."OPERATIONTYPEID" ; end; end loop; end; end if; end if; if l_table_id is not null and not length(l_table_id) = 0 then select ad.code into l_table_code from aspl_dictionary_file af join aspl_dictionary ad on (af.dictionary_id = ad.id) where af.id = l_table_id; if l_table_code is not null and UPPER(l_table_code) = UPPER('OPERATION_TYPE') then merge into aspl_OPERATION_TYPE trg using xls_OPERATION_TYPE src on ( trg."OPERATIONTYPEID" = src."OPERATIONTYPEID" and trunc(trg.load_date) = trunc(src.load_date)) when matched then update set trg."CODE" = src."CODE" , trg."name" = src."name" , trg."DESCRIPTION" = src."DESCRIPTION" , trg."DIRECTION" = src."DIRECTION" where trg.src_id = 0 when not matched then insert ( trg."CODE", trg."name", trg."DESCRIPTION", trg."DIRECTION", trg."OPERATIONTYPEID", trg."LOAD_DATE", trg."SRC_ID") values ( src."CODE", src."name", src."DESCRIPTION", src."DIRECTION", src."OPERATIONTYPEID", src."LOAD_DATE", 0); end if; end if; end if; end;  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.dwhAndExcelMerge]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.dwhAndExcelMerge]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: select count(*) cnt from (( select 1, 'a2', 1 from dual union all select 2, 'b1', 0 from dual union all select 3, 'c1', 0 from dual union all select 4, 'f1', 1 from dual ) minus select "OPERATIONTYPEID" , "CODE" , "SRC_ID" from ASPL_OPERATION_TYPE)  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.compareDataSet]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.compareDataSet]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==      Total: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.compareDataSet]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from DWH_OPERATION_TYPE  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 2 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: insert into DWH_OPERATION_TYPE ( "OPERATIONTYPEID" , "CODE" , "name" , "DESCRIPTION" , "DIRECTION" ) values ( 1 , 'a3' , 'Buy' , 'Buy transaction on secondary market' , 'CREDIT' )  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: declare l_aspl_export_setting_cnt number; begin select count (*) into l_aspl_export_setting_cnt from aspl_export_setting; if l_aspl_export_setting_cnt = 1 then update aspl_export_setting set export_date = trunc(?); else insert into aspl_export_setting (export_date, load_flg) values (trunc(?), 'Y'); end if; end;  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.setAsplActualDate]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters: 2016-01-13 00:00:00.0(Timestamp), 2016-01-13 00:00:00.0(Timestamp) [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.setAsplActualDate]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from aspl_merge_status  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: select export_date from aspl_export_setting  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getAsplActualDate]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getAsplActualDate]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==      Total: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getAsplActualDate]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: declare l_report_dttm sys_data_load_log.report_dttm%type; l_load_type sys_data_load_log.load_type%type; l_status_cd sys_data_load_log.status_cd%type; l_max_log_id sys_data_load_log.log_id%type; l_next_log_id sys_data_load_log.log_id%type; begin select max(log_id) into l_max_log_id from sys_data_load_log l; if l_max_log_id is not null then select report_dttm, load_type, status_cd into l_report_dttm, l_load_type, l_status_cd from sys_data_load_log where log_id = l_max_log_id; end if; if not (l_load_type = 'ASPLINK' and l_status_cd = 'L') or l_max_log_id is null then select sys_data_load_log_seq.nextval into l_next_log_id from dual; insert into sys_data_load_log (log_id, load_type, report_dttm, status_cd, loading_start_dttm, loading_end_dttm) values (l_next_log_id, 'DWH', trunc(?), 'D', sysdate, null); end if; end;  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.addStatusDwhDone]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters: 2016-01-13 00:00:00.0(Timestamp) [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.addStatusDwhDone]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: declare l_report_dttm sys_data_load_log.report_dttm%type; l_load_type sys_data_load_log.load_type%type; l_status_cd sys_data_load_log.status_cd%type; l_max_log_id sys_data_load_log.log_id%type; l_next_log_id sys_data_load_log.log_id%type; c_status_cd constant sys_data_load_log.status_cd%type := ?; begin select max(log_id) into l_max_log_id from sys_data_load_log l; if l_max_log_id is not null then select report_dttm, load_type, status_cd into l_report_dttm, l_load_type, l_status_cd from sys_data_load_log where log_id = l_max_log_id; if l_load_type = 'DWH' and l_status_cd = 'D' then select sys_data_load_log_seq.nextval into l_next_log_id from dual; insert into sys_data_load_log (log_id, load_type, report_dttm, status_cd, loading_start_dttm, loading_end_dttm) values (l_next_log_id, 'ASPLINK', l_report_dttm, c_status_cd, sysdate, null); elsif l_load_type = 'ASPLINK' and l_status_cd = 'L' then update sys_data_load_log set status_cd = c_status_cd, loading_end_dttm = sysdate where log_id = l_max_log_id; end if; end if; end;  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.updateDwhSysLog]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters: L(String) [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.updateDwhSysLog]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: select column_name from user_tab_cols where upper(table_name) = upper(?) and upper(column_name) not in ( upper(?) , upper(?) )  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getTableColumns]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters: XLS_OPERATION_TYPE(String), OPERATIONTYPEID(String), LOAD_DATE(String) [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getTableColumns]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==      Total: 4 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getTableColumns]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: declare l_report_dttm sys_data_load_log.report_dttm%type; l_load_type sys_data_load_log.load_type%type; l_status_cd sys_data_load_log.status_cd%type; l_max_log_id sys_data_load_log.log_id%type; l_dwh_table_cnt number; l_aspl_export_setting_cnt number; l_aspl_merge_status_cnt number; l_table_name varchar2 (30 byte) := 'DWH_OPERATION_TYPE'; l_table_code varchar2(30 byte); l_table_id varchar2(30 byte) := ''; begin l_table_name := upper(l_table_name); select count (*) into l_aspl_export_setting_cnt from aspl_export_setting; if l_aspl_export_setting_cnt = 1 then select count(*) into l_aspl_merge_status_cnt from aspl_merge_status where table_name = l_table_name; if l_aspl_merge_status_cnt = 0 then merge into (select cl."CODE", cl."name", cl."DESCRIPTION", cl."DIRECTION", cl."OPERATIONTYPEID", cl."LOAD_DATE", cl."SRC_ID" from aspl_OPERATION_TYPE cl where cl.load_date = (select trunc(export_date) from aspl_export_setting)) trg using (select cl2."CODE", cl2."name", cl2."DESCRIPTION", cl2."DIRECTION", cl2."OPERATIONTYPEID", cl2."LOAD_DATE", cl2."SRC_ID" from aspl_OPERATION_TYPE cl2 where trunc(cl2.load_date) = (select trunc(export_date) - 1 as prev_date from aspl_export_setting)) src on ( trg."OPERATIONTYPEID" = src."OPERATIONTYPEID" and trg.load_date = (select trunc(export_date) from aspl_export_setting)) when not matched then insert ( trg."CODE", trg."name", trg."DESCRIPTION", trg."DIRECTION", trg."OPERATIONTYPEID", trg."LOAD_DATE", trg."SRC_ID") values ( src."CODE", src."name", src."DESCRIPTION", src."DIRECTION", src."OPERATIONTYPEID", (select trunc(export_date) from aspl_export_setting), src."SRC_ID"); insert into aspl_merge_status (table_name, load_flg) values (l_table_name, 'Y'); end if; select max (log_id) into l_max_log_id from sys_data_load_log l; if l_max_log_id is not null then select report_dttm, load_type, status_cd into l_report_dttm, l_load_type, l_status_cd from sys_data_load_log where log_id = l_max_log_id; if l_load_type = 'ASPLINK' and l_status_cd = 'L' then select count (*) into l_dwh_table_cnt from dwh_OPERATION_TYPE; if l_dwh_table_cnt = 0 then insert into aspl_system_log (id, load_date, message) values (aspl_system_log_seq.nextval, sysdate, '������� dwh_OPERATION_TYPE ������ �� dwh ������'); end if; merge into aspl_OPERATION_TYPE trg using dwh_OPERATION_TYPE src on ( trg."OPERATIONTYPEID" = src."OPERATIONTYPEID" and trunc(trg.load_date) = (select trunc(export_date) from aspl_export_setting)) when matched then update set trg."CODE" = src."CODE" , trg."name" = src."name" , trg."DESCRIPTION" = src."DESCRIPTION" , trg."DIRECTION" = src."DIRECTION" ,trg.src_id = 1 when not matched then insert ( trg."CODE", trg."name", trg."DESCRIPTION", trg."DIRECTION", trg."OPERATIONTYPEID", trg."LOAD_DATE", trg."SRC_ID") values ( src."CODE", src."name", src."DESCRIPTION", src."DIRECTION", src."OPERATIONTYPEID", (select trunc(export_date) from aspl_export_setting), 1); begin for rec in (select aspl."OPERATIONTYPEID", trunc(aspl.load_date) load_date from aspl_OPERATION_TYPE aspl left join dwh_OPERATION_TYPE dwh on ( aspl."OPERATIONTYPEID" = dwh."OPERATIONTYPEID" and trunc(aspl.load_date) = (select trunc(export_date) from aspl_export_setting)) where aspl.src_id = 1 and coalesce ( null, dwh."OPERATIONTYPEID" ) is null ) loop begin insert into aspl_system_log (id, load_date, message) values (aspl_system_log_seq.nextval, sysdate, '� ������� operation_type aspl_OPERATION_TYPE c aspl."OPERATIONTYPEID" = '|| rec."OPERATIONTYPEID"||' ' || rec.operationtypeid || ' �������� ������ �� �������������'); update aspl_OPERATION_TYPE aspl set aspl.src_id = 0 where aspl."OPERATIONTYPEID" = rec."OPERATIONTYPEID" ; end; end loop; end; end if; end if; if l_table_id is not null and not length(l_table_id) = 0 then select ad.code into l_table_code from aspl_dictionary_file af join aspl_dictionary ad on (af.dictionary_id = ad.id) where af.id = l_table_id; if l_table_code is not null and UPPER(l_table_code) = UPPER('OPERATION_TYPE') then merge into aspl_OPERATION_TYPE trg using xls_OPERATION_TYPE src on ( trg."OPERATIONTYPEID" = src."OPERATIONTYPEID" and trunc(trg.load_date) = trunc(src.load_date)) when matched then update set trg."CODE" = src."CODE" , trg."name" = src."name" , trg."DESCRIPTION" = src."DESCRIPTION" , trg."DIRECTION" = src."DIRECTION" where trg.src_id = 0 when not matched then insert ( trg."CODE", trg."name", trg."DESCRIPTION", trg."DIRECTION", trg."OPERATIONTYPEID", trg."LOAD_DATE", trg."SRC_ID") values ( src."CODE", src."name", src."DESCRIPTION", src."DIRECTION", src."OPERATIONTYPEID", src."LOAD_DATE", 0); end if; end if; end if; end;  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.dwhAndExcelMerge]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.dwhAndExcelMerge]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: select count(*) cnt from (( select 1, 'a3', 1 from dual union all select 2, 'b1', 0 from dual union all select 3, 'c1', 0 from dual union all select 4, 'f1', 0 from dual ) minus select "OPERATIONTYPEID" , "CODE" , "SRC_ID" from ASPL_OPERATION_TYPE)  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.compareDataSet]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.compareDataSet]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==      Total: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.compareDataSet]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from XLS_OPERATION_TYPE  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 3 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: insert into XLS_OPERATION_TYPE ( "OPERATIONTYPEID" , "CODE" , "name" , "DESCRIPTION" , "DIRECTION" , "LOAD_DATE" ) values ( 1 , 'a4' , 'Buy' , 'Buy transaction on secondary market' , 'CREDIT' , to_date('13.01.2016', 'dd.mm.yyyy') )  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: insert into XLS_OPERATION_TYPE ( "OPERATIONTYPEID" , "CODE" , "name" , "DESCRIPTION" , "DIRECTION" , "LOAD_DATE" ) values ( 2 , 'b2' , 'Cancel' , 'Cancellation of earlier transaction' , 'NO CHANGE' , to_date('13.01.2016', 'dd.mm.yyyy') )  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: delete from ASPL_DICTIONARY_FILE  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.clearTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: insert into ASPL_DICTIONARY_FILE ( "ID" , "DICTIONARY_ID" , "FILENAME" , "STATUS_ID" , "FILE_DATA" , "LOAD_DATE" ) values ( 2 , 23 , '23. Operation types1.xlsx' , 4 , EMPTY_BLOB() , to_date('13.01.2016', 'dd.mm.yyyy') )  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==    Updates: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.insertTable]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: declare l_aspl_export_setting_cnt number; begin select count (*) into l_aspl_export_setting_cnt from aspl_export_setting; if l_aspl_export_setting_cnt = 1 then update aspl_export_setting set export_date = trunc(?); else insert into aspl_export_setting (export_date, load_flg) values (trunc(?), 'Y'); end if; end;  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.setAsplActualDate]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters: 2016-01-15 00:00:00.0(Timestamp), 2016-01-15 00:00:00.0(Timestamp) [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.setAsplActualDate]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: select column_name from user_tab_cols where upper(table_name) = upper(?) and upper(column_name) not in ( upper(?) , upper(?) )  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getTableColumns]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters: XLS_OPERATION_TYPE(String), OPERATIONTYPEID(String), LOAD_DATE(String) [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getTableColumns]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==      Total: 4 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.getTableColumns]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: declare l_report_dttm sys_data_load_log.report_dttm%type; l_load_type sys_data_load_log.load_type%type; l_status_cd sys_data_load_log.status_cd%type; l_max_log_id sys_data_load_log.log_id%type; l_dwh_table_cnt number; l_aspl_export_setting_cnt number; l_aspl_merge_status_cnt number; l_table_name varchar2 (30 byte) := 'DWH_OPERATION_TYPE'; l_table_code varchar2(30 byte); l_table_id varchar2(30 byte) := '2'; begin l_table_name := upper(l_table_name); select count (*) into l_aspl_export_setting_cnt from aspl_export_setting; if l_aspl_export_setting_cnt = 1 then select count(*) into l_aspl_merge_status_cnt from aspl_merge_status where table_name = l_table_name; if l_aspl_merge_status_cnt = 0 then merge into (select cl."CODE", cl."name", cl."DESCRIPTION", cl."DIRECTION", cl."OPERATIONTYPEID", cl."LOAD_DATE", cl."SRC_ID" from aspl_OPERATION_TYPE cl where cl.load_date = (select trunc(export_date) from aspl_export_setting)) trg using (select cl2."CODE", cl2."name", cl2."DESCRIPTION", cl2."DIRECTION", cl2."OPERATIONTYPEID", cl2."LOAD_DATE", cl2."SRC_ID" from aspl_OPERATION_TYPE cl2 where trunc(cl2.load_date) = (select trunc(export_date) - 1 as prev_date from aspl_export_setting)) src on ( trg."OPERATIONTYPEID" = src."OPERATIONTYPEID" and trg.load_date = (select trunc(export_date) from aspl_export_setting)) when not matched then insert ( trg."CODE", trg."name", trg."DESCRIPTION", trg."DIRECTION", trg."OPERATIONTYPEID", trg."LOAD_DATE", trg."SRC_ID") values ( src."CODE", src."name", src."DESCRIPTION", src."DIRECTION", src."OPERATIONTYPEID", (select trunc(export_date) from aspl_export_setting), src."SRC_ID"); insert into aspl_merge_status (table_name, load_flg) values (l_table_name, 'Y'); end if; select max (log_id) into l_max_log_id from sys_data_load_log l; if l_max_log_id is not null then select report_dttm, load_type, status_cd into l_report_dttm, l_load_type, l_status_cd from sys_data_load_log where log_id = l_max_log_id; if l_load_type = 'ASPLINK' and l_status_cd = 'L' then select count (*) into l_dwh_table_cnt from dwh_OPERATION_TYPE; if l_dwh_table_cnt = 0 then insert into aspl_system_log (id, load_date, message) values (aspl_system_log_seq.nextval, sysdate, '������� dwh_OPERATION_TYPE ������ �� dwh ������'); end if; merge into aspl_OPERATION_TYPE trg using dwh_OPERATION_TYPE src on ( trg."OPERATIONTYPEID" = src."OPERATIONTYPEID" and trunc(trg.load_date) = (select trunc(export_date) from aspl_export_setting)) when matched then update set trg."CODE" = src."CODE" , trg."name" = src."name" , trg."DESCRIPTION" = src."DESCRIPTION" , trg."DIRECTION" = src."DIRECTION" ,trg.src_id = 1 when not matched then insert ( trg."CODE", trg."name", trg."DESCRIPTION", trg."DIRECTION", trg."OPERATIONTYPEID", trg."LOAD_DATE", trg."SRC_ID") values ( src."CODE", src."name", src."DESCRIPTION", src."DIRECTION", src."OPERATIONTYPEID", (select trunc(export_date) from aspl_export_setting), 1); begin for rec in (select aspl."OPERATIONTYPEID", trunc(aspl.load_date) load_date from aspl_OPERATION_TYPE aspl left join dwh_OPERATION_TYPE dwh on ( aspl."OPERATIONTYPEID" = dwh."OPERATIONTYPEID" and trunc(aspl.load_date) = (select trunc(export_date) from aspl_export_setting)) where aspl.src_id = 1 and coalesce ( null, dwh."OPERATIONTYPEID" ) is null ) loop begin insert into aspl_system_log (id, load_date, message) values (aspl_system_log_seq.nextval, sysdate, '� ������� operation_type aspl_OPERATION_TYPE c aspl."OPERATIONTYPEID" = '|| rec."OPERATIONTYPEID"||' ' || rec.operationtypeid || ' �������� ������ �� �������������'); update aspl_OPERATION_TYPE aspl set aspl.src_id = 0 where aspl."OPERATIONTYPEID" = rec."OPERATIONTYPEID" ; end; end loop; end; end if; end if; if l_table_id is not null and not length(l_table_id) = 0 then select ad.code into l_table_code from aspl_dictionary_file af join aspl_dictionary ad on (af.dictionary_id = ad.id) where af.id = l_table_id; if l_table_code is not null and UPPER(l_table_code) = UPPER('OPERATION_TYPE') then merge into aspl_OPERATION_TYPE trg using xls_OPERATION_TYPE src on ( trg."OPERATIONTYPEID" = src."OPERATIONTYPEID" and trunc(trg.load_date) = trunc(src.load_date)) when matched then update set trg."CODE" = src."CODE" , trg."name" = src."name" , trg."DESCRIPTION" = src."DESCRIPTION" , trg."DIRECTION" = src."DIRECTION" where trg.src_id = 0 when not matched then insert ( trg."CODE", trg."name", trg."DESCRIPTION", trg."DIRECTION", trg."OPERATIONTYPEID", trg."LOAD_DATE", trg."SRC_ID") values ( src."CODE", src."name", src."DESCRIPTION", src."DIRECTION", src."OPERATIONTYPEID", src."LOAD_DATE", 0); end if; end if; end if; end;  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.dwhAndExcelMerge]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.AsplinkDao.dwhAndExcelMerge]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==>  Preparing: select count(*) cnt from (( select 1, 'a3', 1 from dual union all select 2, 'b2', 0 from dual union all select 3, 'c1', 0 from dual union all select 4, 'f1', 0 from dual ) minus select "OPERATIONTYPEID" , "CODE" , "SRC_ID" from ASPL_OPERATION_TYPE)  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.compareDataSet]
[AspLink-2.00-SNAPSHOT] [DEBUG] ==> Parameters:  [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.compareDataSet]
[AspLink-2.00-SNAPSHOT] [DEBUG] <==      Total: 1 [BaseJdbcLogger.java:142] [ru.masterdm.asplink.dao.TestDao.compareDataSet]
[AspLink-2.00-SNAPSHOT] [INFO] Closing org.springframework.context.support.GenericApplicationContext@77a57272: startup date [Mon Mar 14 02:02:00 MSK 2016]; root of context hierarchy [AbstractApplicationContext.java:866] [org.springframework.context.support.GenericApplicationContext]
