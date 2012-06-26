my $stringHandleFile = "asia.str";
my $updateFileDir = "filesToUpdate\\";
opendir( my $DIR_UPDATE, $updateFileDir) || die "can't open dir : $updateFileDir Error:$?";

while (readdir $DIR_UPDATE)
{
    if( -f $updateFileDir.$_ )
    {
        checkFile( $stringHandleFile, $updateFileDir.$_, $_."checkOutput.txt" );
        if( -z $_."checkOutput.txt" )
        {
            unlink $_."checkOutput.txt" || die "cant delete $_.checkOutput.txt";
        }
    }
    print $updateFileDir.$_ , "\n";
    #die ;
}
close $DIR_UPDATE;
#���perlֻ�������������������в�ͬ��handle����Щ��str_files�а���
#�����е�Դ����xliff_file��ʾ���գ�result.txt�н������Щ������str_files��
#��handle����������xliff_file��handle����
sub checkFile {
    @str_files = shift @_;                                           #( "asia.str" );        #<=======*.str
    $File_Want_Check = shift @_;                                     #"out.glx";     #<=======*.glx
    $result_file = shift @_;                                         #"result.txt";        #<=======���str����handleû�б�*.glx ���룬handle�ͻ����������
    
    binmode STDOUT, ":utf8";

    open( XLIFF_FILE, "<:utf8", $File_Want_Check );
    #����xliff_file�����е�handle����
    for( <XLIFF_FILE> )
    {
        #print $_;
        if( $_ =~ /handle="(.*?)"/ )
        {
            #print "$1\n";
            push @xliff_string_handles, $1;
        }
    }
    close( XLIFF_FILE );


    open( RESULT_FILE, ">:utf8", $result_file );

    for( @str_files )
    {
        #print $_;
        open( STR_FILE, "<:utf8", $_ );
        for( <STR_FILE> )
        {
            if( $_ =~ /handle="(.*?)"/ )
            {
                $string_handle = $1;
                #print "$string_handle\n";
                my $found = 0;
                for( @xliff_string_handles )
                {
                    if( $_ eq $string_handle )
                    {
                        $found = 1;
                        #print "$string_handle\n";
                        break;
                    }
                }
                if( $found == 0 )
                {
                    print "$string_handle\n";
                    print RESULT_FILE "$string_handle\n";
                }
                #my @matches = grep { $_ == $1 } ;
                #if( $#matches gt 1 )
                #{
                    #print "$1\n";
                #}
            }
        }
        close( STR_FILE );
    }

    close( RESULT_FILE );
}

