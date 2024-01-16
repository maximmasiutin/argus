# Scans history.txt and reports Contributors Top List
# Only people with at least two contributions are displayed

# usage:
# perl contrib.pl history.txt


while ($a=<>)
{
 if ($a=~/\(([a-zA-Z]{2,} [a-zA-Z]{2,})\)/) {$a{$1}++};
}

$i = 0;

while (($key,$value) = each %a) {if ($value>1) {$L[$i++]=sprintf("%3u %s",$value,$key);};};
foreach $L (sort {$b cmp $a} @L) {print "$L\n";}
