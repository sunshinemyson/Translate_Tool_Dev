use warnings;
use strict;
  
#####################################MAIN######################################
my $stringHandleFile = "asia.str";
my $globalSectionName = "ASIA";
my $refFileDir = "Ref\\";
my $updateFileDir = "filesToUpdate\\";
opendir( my $DIR_UPDATE, $updateFileDir) || die "can't open dir : $updateFileDir Error:$?";

while (readdir $DIR_UPDATE)
{
    print "Update $_\n";
    my $file2Update = $_;
    opendir (my $DIR_REF,$refFileDir ) || die "Cant open dir : $refFileDir Error : $?";
    my $file2Ref;
    while ( readdir $DIR_REF )
    {
        if( $_ eq $file2Update )
        {
            $file2Ref = $_;
            last;
        }
    }
    #print "file2Update = $file2Update , file2Ref = $file2Ref\n";
    if( defined $file2Ref )
    {#如果能找到一个参考档
        print "Found reference file for $file2Update\n";
        if( -f $updateFileDir.$file2Update && -f $refFileDir.$file2Ref )
        {
            writeMergeLog($refFileDir.$file2Ref."<Ref>--<Base>".$updateFileDir.$file2Update."\n");
            ProcessOneTranslateFile( $stringHandleFile, $updateFileDir.$file2Update, $refFileDir.$file2Ref);
        }
    }
    else
    {   print "Cant Found reference file for $file2Update\n";
        if( -f $updateFileDir.$file2Update )
        {
            ProcessOneTranslateFile( $stringHandleFile, $updateFileDir.$file2Update );
        }
    }

    closedir $DIR_REF;
    print "Update $file2Update finished\n";
}

closedir $DIR_UPDATE;

sub ProcessOneTranslateFile
{
    my $asia_handle_file = shift @_;        
    my $update_file = shift @_;             
    my $ref_trans_file = shift @_;        
        
    my %handleHash = readHandleFromStrFile( $asia_handle_file );
    my %midResult;
    if ( defined $ref_trans_file && -f $ref_trans_file )
    {
        %midResult = tryTranslateStr( \%handleHash, $ref_trans_file );
    }
    else
    {
        %midResult = tryTranslateStr( \%handleHash );
    }
      
    #printStrHash(\%midResult);
    insertHandleToTranslateFile( \%midResult, $update_file );
    modifyCatalogTag( $update_file );
}

1;	# This need if This module require from Other Module
###############################################################################
sub readHandleFromStrFile
{
    my $srcFile = shift @_;
    my %contextHashTbl;
    my $hashKey;
    my $flag_NewEntry = 0;
    #debug 
    #print "$srcFile\n";
    open( srcHandle, "<:utf8", $srcFile ) || die "Can't open file:$srcFile";
    
    foreach( <srcHandle> )
    {
        #print "$_\n";
        if( !$flag_NewEntry && $_ =~ /handle="(.*?)"/ )
        {
            $hashKey = $1;
            #print "$1\n";
            $flag_NewEntry = 1;
        }
        if( $flag_NewEntry && $_ =~ /<string>(.*?)<\/string>/ )
        {
            #print "$1\n";
            my @strList;
            push @strList,$1;
            #$contextHashTbl{$hashKey} = $1;
            $contextHashTbl{$hashKey} = \@strList;
            $flag_NewEntry = 0;
        }
    }
    
    close srcHandle;
    #we need check $flag_NewEntry==0
    die "Error occour when read $srcFile" unless $flag_NewEntry == 0;
    
    return %contextHashTbl;
}

###############################################################################
#                            !tryTranslateStr!
# Input : [0]handle的hash表，[1]：用来翻译handle的翻译档列表
# 增加处理没有参考档案的情况:缺失时，全部使用我们的格式来存翻译
###############################################################################
sub tryTranslateStr
{
    my %strHashWantToTranslate = %{ shift @_ };
    my @refTranslationFiles;
    my $specilIndicate = "_NOT_Trans_YET_";

    foreach (@_)
    {
        print "translation File is $_\n";
        push @refTranslationFiles, $_;
    }
    my $fileCnt = @refTranslationFiles;

    if( $fileCnt != 0 )
    {#给了参考翻译
        while( (my $handleToTranslate,my $items) = (each %strHashWantToTranslate) )
        {
            #尝试着翻译
            #print "begin Translate $handleToTranslate-->@$items\n";        
            my $result = $specilIndicate;            
            foreach (@refTranslationFiles)
            {
                my $flag_Find = 0;
                #print "Current File is: ",$_,"\n";
                open (FILEHANLE, "<:utf8", $_) || die "Cant open $_ for translate string handle";
                foreach ( <FILEHANLE> )
                {                
                    if( $_ =~ /<entry handle="(.*?)"/ && $1 eq $handleToTranslate )
                    {
                        $flag_Find = 1;
                    }
                    if( $flag_Find == 1 && $_ =~ /<visual>(.*?)<\/visual>/ )
                    {
                        #print "$handleToTranslate-->$1\n";
                        $result = $1;
                        last;
                    }
                    #print "Continue search\n";
                }
                close (FILEHANLE);
               
                if( $flag_Find == 1)
                {
                    last;
                }
            }
            
            #无论有没有找到翻译，都要给这个handle一个翻译，没有就是默认字
            #print $result,"\n";
            writeMergeLog( $handleToTranslate."-->".$result."\n" );
            push @$items, $result;
            #print "End Translate $handleToTranslate\n";
        }#end - while
    }
    else
    {#没给参考翻译
        while( (my $handleToTranslate,my $items) = (each %strHashWantToTranslate) )
        {
            push @$items, $specilIndicate;
        }
    }
    #printStrHash (\%strHashWantToTranslate);
    %strHashWantToTranslate;
}
###############################################################################
#                            !write new handle!
# 目前的规则：
#   如果一个handle没有找到对应的handle：section+handlename，那么它将被加入到
#   ASIA节中
#   翻译档中可以存在两个相同节，重复出现的handle以第一个handle的翻译为准
#   不同section中的handle名称可以相同，不会互相影响
#   这意味着：两个handle等价《=》必须保证位于同一section，具备同样的handle名
###############################################################################
sub insertHandleToTranslateFile {
    
    my %translatedHandleHash = %{ shift @_ };
    my $fileToInsert = shift @_;
    #print "will save Translate to $fileToInsert\n";
    my $specilIndicate = "_NOT_Trans_YET_";
    my $Tab = " "x 4;
    
    #1. scan file to find out which handle need to append to the file
    my %appendHandles;
    
    #print "Begin Scan for Append !\n";
    
    foreach my $handleName (keys %translatedHandleHash)
    {
        #print "Check $handleName need append or not!\n";
        my $Flag = 0;
        open (HANDLE_SCAN, "<:utf8", $fileToInsert) || die "can't open $fileToInsert : $?";
        
        my $sectionName;
        foreach (<HANDLE_SCAN>)
        {
            if( $_ =~ /<section name="(.*?)"/ )
            {
                $sectionName = $1;
            }
            if( $_ =~ /<entry handle="(.*?)"/ && $1 eq $handleName && $sectionName eq $globalSectionName )
            {#当且仅当该handle在同一section下被翻译过，该handle才不会被追加到末尾
                #print " $handleName has a translation in $fileToInsert !\n";

                my $logStr;
                $logStr = "[$handleName] : has a translation in $fileToInsert-->[$sectionName]!\n";
                writeMergeLog($logStr);

                $Flag = 1;
                last;
            }
        }
        if( $Flag == 0)
        {
            #print "$handleName need to append in $fileToInsert !\n";
            $appendHandles{$handleName} = 1;
        }
        close HANDLE_SCAN;
    }
   
    #print "End Scan for Append !\n";
    
    #2. append handle at the end of the fileToInsert
    open (HANDLE_APPEND, ">>:utf8", $fileToInsert) ||die "can't open $fileToInsert : $?";
    
    #3. 先写翻译过的，再写没有翻译的
    my %handleTranslated;
    my %handleNotTranslated;

    while ((my $srchHandle,my $items ) =  (each %translatedHandleHash ))    
    {
        if( exists $appendHandles{$srchHandle} && $$items[1] ne $specilIndicate )
        {            
            $handleTranslated{$srchHandle} = 1;
        }
        if( exists $appendHandles{$srchHandle} && $$items[1] eq $specilIndicate )
        {
            $handleNotTranslated{$srchHandle} = 1;
        }
    }
    
    my $cnt_Translate = keys %handleTranslated;
    my @TransHandleList = keys %handleTranslated;
    @TransHandleList = sort @TransHandleList;
    
    if( $cnt_Translate > 0)
    {
        print HANDLE_APPEND "$Tab<section name=\"$globalSectionName\">\n";
    }
        
    foreach (@TransHandleList)
    {
        my $dataPointer = $translatedHandleHash{$_};
        #print "$_ |  need append to $fileToInsert\n";
        print HANDLE_APPEND "$Tab$Tab<entry handle=\"$_\">\n";
        print HANDLE_APPEND "$Tab$Tab$Tab<strings>\n";
        print HANDLE_APPEND "$Tab$Tab$Tab$Tab<string default=\"true\">\n";
        print HANDLE_APPEND "$Tab$Tab$Tab$Tab$Tab<visual>@$dataPointer[1]</visual>\n";
        print HANDLE_APPEND "$Tab$Tab$Tab$Tab</string>\n";
        print HANDLE_APPEND "$Tab$Tab$Tab</strings>\n";
        print HANDLE_APPEND "$Tab$Tab$Tab<usage visual=\"true\"/>\n";
        print HANDLE_APPEND "$Tab$Tab</entry>\n";        
    }
    
    if( $cnt_Translate > 0)
    {
        print HANDLE_APPEND "$Tab</section>\n";
    }
    
    my $cnt_un_Translate = keys %handleNotTranslated;
    my @unTransHandleList = keys %handleNotTranslated;
    @unTransHandleList = sort @unTransHandleList;

    if( $cnt_un_Translate > 0)
    {
        #print "new SEction\n";
        print HANDLE_APPEND "$Tab<section name=\"$globalSectionName\">\n";
    }
    foreach (@unTransHandleList)
    {
        my $dataPointer = $translatedHandleHash{$_};
        #print "--$_ need append to $fileToInsert\n";
        print HANDLE_APPEND "$Tab$Tab<entry handle=\"$_\">\n";
        print HANDLE_APPEND "$Tab$Tab$Tab<strings>\n";
        print HANDLE_APPEND "$Tab$Tab$Tab$Tab<string default=\"true\">\n"; 
        print HANDLE_APPEND "$Tab$Tab$Tab$Tab$Tab<visual>@$dataPointer[1]:@$dataPointer[0]</visual>\n";
        print HANDLE_APPEND "$Tab$Tab$Tab$Tab</string>\n";
        print HANDLE_APPEND "$Tab$Tab$Tab</strings>\n";
        print HANDLE_APPEND "$Tab$Tab$Tab<usage visual=\"true\"/>\n";
        print HANDLE_APPEND "$Tab$Tab</entry>\n";        
    }

    if( $cnt_un_Translate > 0)
    {
        print HANDLE_APPEND "$Tab</section>\n";
    }
    close HANDLE_APPEND;
    print "Save Translate Result to $fileToInsert\n";
}
###############################################################################
#                     !Funtions For modify </catalog>Tag!
###############################################################################
sub modifyCatalogTag
{
    my $fileName = shift @_;
    #print $fileName, "\n";
    my $newFile = $fileName."new";
    #print $newFile, "\n";
    
    open (Old_File, "<:utf8",$fileName) || die;
    open (New_File, ">:utf8",$newFile)  || die;
    
    foreach (<Old_File>)
    {
        if( $_ =~ /<\/catalog>(.*)/ )
        {
            print New_File $1."\n";
        }
        else
        {
            print New_File $_;
        }
    }
    
    print New_File "\n</catalog>";
    
    close (New_File);
    close (Old_File);
    unlink $fileName;
    rename $newFile,$fileName;
}
###############################################################################
#                            !Funtions For log!
###############################################################################
sub writeMergeLog
{
    my $line = shift @_;
    my $logFile = "merge.log";
    open (LOGFILEHANDLE, ">>:utf8", $logFile) || die "can't Open $logFile For write";
    print LOGFILEHANDLE $line;
    close(LOGFILEHANDLE);
}
###############################################################################
#                            !Funtions For test!
###############################################################################
sub printStrHash
{
    my %strHash = %{ shift @_ };
    while( (my $key,my $value) = (each %strHash) )
    {
        my $cnt = @$value;
        die "$cnt != 2" unless $cnt == 2;
        print "cnt = $cnt #$key-->@$value\n";
    }   
 
}