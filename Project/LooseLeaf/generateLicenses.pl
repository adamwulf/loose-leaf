#!/usr/bin/perl -w

use strict;

my $out = "Settings.bundle/en.lproj/Acknowledgements.strings";
my $plistout =  "Settings.bundle/Acknowledgements.plist";

system("rm -f $out");

open(my $outfh, '>', $out) or die $!;
open(my $plistfh, '>', $plistout) or die $!;

print $plistfh <<'EOD';
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>StringsTable</key>
<string>Acknowledgements</string>
<key>PreferenceSpecifiers</key>
<array>
EOD
for my $i (sort glob("*.license"))
{
    my $value=`cat $i`;
    $value =~ s/\r//g;
    $value =~ s/\n/\r/g;
    $value =~ s/[\t]+\r/\r/g;
    $value =~ s/\"/\'/g;
    my $key=$i;
    $key =~ s/\.license$//;
    
    my $fullstr = "";
    
    my $cnt = 1;
    my $keynum = $key;
    for my $str (split /\r\r/, $value)
    {
        if ($cnt == 1){
            print $plistfh "<dict>\n";
            print $plistfh "<key>Type</key>\n";
            print $plistfh "<string>PSGroupSpecifier</string>\n";
            print $plistfh "<key>Title</key>\n";
            print $plistfh "<string>$keynum</string>\n";
            print $outfh "\"$keynum\" = \"$str\";\n";
        }else{
            $fullstr .= "\n\n" . $str;
        }
        
        $keynum = $key.(++$cnt);
    }
    
    $fullstr =~ s/^\s+//;
    $fullstr =~ s/\s+$//;
    
    print $outfh "\"$keynum\" = \"$fullstr\";\n";
    print $plistfh "<key>FooterText</key>\n";
    print $plistfh "<string>$keynum</string>\n";
    print $plistfh "</dict>\n";


    print $plistfh "<dict>\n";
    print $plistfh "<key>Type</key>\n";
    print $plistfh "<string>PSGroupSpecifier</string>\n";
    print $plistfh "<key>FooterText</key>\n";
    print $plistfh "<string>\n</string>\n";
    print $plistfh "</dict>\n";
}

print $plistfh <<'EOD';
</array>
</dict>
</plist>
EOD
close($outfh);
close($plistfh);

