use warnings;
use strict;

my $Dir_Old = "filesToUpdate\\";
my $Dir_New = "Ref\\";

opendir ( my $OLD_DIR, $Dir_Old )||die "can't open $Dir_Old";
while( readdir $OLD_DIR )
{
    if( -f $Dir_Old.$_ )
    {
        my $oldFileName = $_;
        
        opendir( my $NEW_DIR, $Dir_New ) || die "Can't open $Dir_Old";
        while( readdir $NEW_DIR )
        {          
            if( -f $Dir_New.$_ && $_ eq $oldFileName )
            {
                compare( $Dir_New.$_, $Dir_Old.$oldFileName );
            }
        }
        closedir $NEW_DIR;
    }
}
closedir $OLD_DIR;

1;
sub compare
{
    my $fileA = shift @_;
    my $fileB = shift @_;
    writeMergeLog("compare $fileA and $fileB \n");
    
    open (HANDLE_A, "<:utf8", $fileA);
    my $handle_A_Finish = 0;
    my $setionName_A;
    my $handleName_A;
    my $tranlate_A;
    foreach( <HANDLE_A> )
    {
        if( $_ =~ /section name="(.*?)"/ )
        {
            $setionName_A = $1;
        }
        if( $_ =~ /handle="(.*?)"/ )
        {
            $handleName_A = $1;
        }
        if( $_ =~ /<visual>(.*?)<\/visual>/ )
        {
            $tranlate_A = $1;
            # Current we Get SecName HandleName Translation
            # we need to check it in fileB
            open (HANDLE_B, "<:utf8", $fileB)||die "can't open $fileB";
            my $sectionName_B;
            my $handleName_B;
            my $tranlate_B;
            foreach (<HANDLE_B>)
            {
                if( $_ =~ /section name="(.*?)"/ )
                {
                    $sectionName_B = $1;
                }
                elsif( defined $sectionName_B && $sectionName_B eq $setionName_A && $_ =~ /handle="(.*?)"/)
                {
                    $handleName_B = $1;
                }
                elsif( defined $sectionName_B && defined $handleName_B &&$sectionName_B eq $setionName_A && $handleName_B eq $handleName_A && $_ =~ /<visual>(.*?)<\/visual>/ )
                {
                    $tranlate_B = $1;
                    if( $tranlate_B ne $tranlate_A )
                    {
                        $handle_A_Finish = 1;                        
                        # print "<$setionName_A><$handleName_A><$tranlate_A><$tranlate_B>\n";
                        # print "compare $fileA and $fileB \n";
                        # die;
                        last;
                    }
                }
            }
            close (HANDLE_B);
            
            if( 1 == $handle_A_Finish )
            {
                writeMergeLog("<$setionName_A><$handleName_A><$tranlate_A><$tranlate_B>\n");
                $handle_A_Finish = 0;
            }
        }
    }
    close (HANDLE_A);
}
################################################################################
#                            !Funtions For log!
################################################################################
sub writeMergeLog
{
    my $line = shift @_;
    my $logFile = "compare.log";
    open (LOGFILEHANDLE, ">>:utf8", $logFile) || die "can't Open $logFile For write";
    print LOGFILEHANDLE $line;
    close(LOGFILEHANDLE);
}