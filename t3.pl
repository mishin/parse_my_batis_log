my $nth = 4;
my $str = 'a=>bb=>ccc=>dddd=>eeeee=>ffffff';

while ($str =~ /=>/g) {
    if (--$nth == 0) {
        substr($str, $-[0], $+[0] - $-[0], '~~|~~');
        last;
    }
}
print "$str\n";