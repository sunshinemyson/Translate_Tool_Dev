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
#这个perl只是用来查找两个档案中不同的handle有哪些：str_files中包含
#了所有的源，而xliff_file表示参照，result.txt中将存放那些存在于str_files中
#的handle但不存在于xliff_file的handle名称
sub checkFile {
    @str_files = shift @_;                                           #( "asia.str" );        #<=======*.str
    $File_Want_Check = shift @_;                                     #"out.glx";     #<=======*.glx
    $result_file = shift @_;                                         #"result.txt";        #<=======如果str中有handle没有被*.glx 翻译，handle就会出现在这里
    
    binmode STDOUT, ":utf8";

    open( XLIFF_FILE, "<:utf8", $File_Want_Check );
    #查找xliff_file中所有的handle名称
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

