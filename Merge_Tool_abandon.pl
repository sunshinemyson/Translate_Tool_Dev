use warnings;
use strict;

################################################################################
#  Step 1�� ����һ�������뵵��
#           __2xx5__���뵵��__     __2565__���뵵��__      asia.str
#                   \                     |                   /
#                    \                    |                  /
#                     \                   |                 /
#                      \                  |                /
#                       ----------                ---------
#                                 |              |
#                                 ����ȥ����ĵ���������asia.str��δ�ܱ��Զ�����Ķ������<setion name="ASIA">��
# Step 2�� �õ������µķ��뵵����ֻ��ִ��һ���ļ��滻��Ȼ��ִ�иĳ��򼴿ɣ�ʾ�����£�
#           __2xx5__���뵵��__     __���µķ��뵵��__      asia.str
#                   \                     |                   /
#                    \                    |                  /
#                     \                   |                 /
#                      \                  |                /
#                       ----------                ---------
#                                 |              |
#                                  �ϲ�����Ľ�������б�����__2xx5__���뵵�е�handle˳����ʱͨ���ļ��ȽϿ��Կ������Դ�
# Ҫ��������⣺
#       1. ��handle���ֵ�˳�򲻱� �� hash ���� List����  -->ͨ����������ֵ�����Ӧ���и��õķ�ʽ
#       2. ��ʱֻ�����asia.str�������룬�����������Ҳ�ǹ̶��ģ��д�����
################################################################################
#debug code

# if(0){#singl file combine      
    # my $strFile = "asia.str";
    # my %src_hash = Src2Hash($strFile);
    # my $transFile = "ja_JP_base.glx";
    # my %trans_hash = translate2Hash( $transFile );
    # #printTranslateHash(\%trans_hash);
    # my $transFile2 = "ja_JP_ref.glx";
    # my %trans_hash2 = translate2Hash( $transFile2 );
    # #printTranslateHash(\%trans_hash2);
    # #my %trans_merge = Mergehash_Translates( \%trans_hash, \%trans_hash2 );
    # my $trans_merge_file = "result.glx";
    # my %result_hash;
    # %result_hash = mergeAll( \%trans_hash,\%trans_hash2,\%src_hash );
    # Hash2Src(\%result_hash, $trans_merge_file );
# }
#if(1)
#{
    #1.1 read Base file s
    my @baseFileName;
    my $baseDir = "Base\\";
    opendir( my $BaseDirHandle, $baseDir) || die "can't open dir : $baseDir Error:$?";
    while( readdir $BaseDirHandle )
    {
        print $_,"\n";
        push @baseFileName, $_;
    }
    closedir $BaseDirHandle;
    #1.2 get all the Base hash
    my %baseHashS;
    foreach my $_ ( @baseFileName )
    {
        if( -f $baseDir.$_ )
        {
            print $_,"\n";
            my %FileContent = translate2Hash( $baseDir.$_ );
            #printTranslateHash ( \%FileContent );
            $baseHashS{ $_ } = \%FileContent;
        }
    }
    #2.1 read Ref files
    my @refFileName;
    my $refDir = "Ref\\";
    opendir (my $RefDirHandle, $refDir) || die "can't open dir : $refDir : Error :$?";
    while( readdir $RefDirHandle )
    {
        print $_,"\n";
        push @refFileName, $_;
    }
    closedir $RefDirHandle;
    #2.2 get add the ref hash
    my %refHashS;
    foreach my $_ ( @refFileName )
    {
        if( -f $refDir.$_ )
        {
            my %FileContent0 = translate2Hash( $refDir.$_ );
            $refHashS{$_} = \%FileContent0;
        }
    }
    #3.1 read str File
    my @strFiles;
    my $strDir = "str\\";
    opendir (my $StrDirHandle, $strDir) || die "can't open dir : $strDir ��Error ��$?";
    while( readdir $StrDirHandle )
    {
        push @strFiles, $_;
    }
    closedir $StrDirHandle;
    #3.2 get str hash
    my %strHashs;
    foreach my $_ ( @strFiles )
    {
        if( -f $strDir.$_ )
        {
            print $_,"\n";
            my %FileContent1 = Src2Hash( $strDir.$_ );
            printStrHash(\%FileContent1);
            $strHashs{ $_ } = \%FileContent1;
        }
    }
    #4. begin build new glx files
    #4.1 Check Base and Ref is same or not !
    foreach my $tempBaseName (keys %baseHashS)
    {
        if( exists $refHashS{$tempBaseName} )
        {
            print "file both in Base and Ref OK!";
        }
        else
        {
            die "miss $tempBaseName in Ref\n";
        }
    }
    #4.2 merge add write to files
    my $destDir = "TranslateResult\\";
    my $DestFileDir;
    if( -d $destDir )
    {
        
    }
    else
    {
        mkdir $destDir || die "cant' mkdir ";
    }
    
    foreach my $CountryName (keys %baseHashS)
    {
        foreach my $strFileName ( keys %strHashs )
        {
            my %mergedHash = mergeAll( $baseHashS{$CountryName},$refHashS{$CountryName},$strHashs{$strFileName});
            print $destDir.$CountryName,"\n";
            Hash2Src( \%mergedHash, $destDir.$CountryName );
        }
        #my %mergedHash = mergeAll( $baseHashS{$CountryName},$refHashS{$CountryName},$strHashs{$strFiles[0]});
        print $destDir.$CountryName,"\n";
        #die;
    }
        
#}

#-----------------------���Դ��룺Ϊ˳��д�ض���--------------------------------
# my $transFile = "1.glx";
# my $strFile = "asia.str";
# my %handles = Src2Hash( $strFile );
# my %hash = translate2Hash($transFile);
# my %midResult_hash = MergeHash_Str_Translate( \%handles,\%hash );
# my $result_file = "2.glx";
# my $mid_file = "mid.glx";
# Hash2Src( \%midResult_hash, $mid_file );
# #printTranslateHash(\%result_hash);
# my %result_hash = Mergehash_Translates(\%hash, \%midResult_hash);
# printTranslateHash (\%result_hash );
# Hash2Src( \%result_hash, $result_file );
#-------------------------------------------------------------------------------
################################################################################

1;
################################################################################
# function : mergeAll
# discription : ����base hash��ref hash ��str hash�ϳ����յķ���hash��
# Input    : base,ref,str
# Output   : mergedHash
################################################################################
sub mergeAll
{
    my %baseHash = %{ shift @_ };           #from 2xx5
    my %refHash  = %{ shift @_ };            #from 2565
    my %strHash  = %{ shift @_ };             #from asia.str
    
    #1. ��2565����asia.str,�������ŵ�%midHash
    my %midHash = MergeHash_Str_Translate( \%strHash, \%refHash );
    #print "midHash\n";
    #printTranslateHash(\%midHash);
    #2. �ϲ�%midhash��%baseHash
    %baseHash = Mergehash_Translates( \%baseHash, \%midHash );    
    #printTranslateHash(\%baseHash);
    %baseHash;
}

################################################################################
# function : Src2Hash
# discription : ��ȡXML����������Լ���õĸ�ʽ����Hash��
# Input    : ���뵵������
# Output   : hash��ÿһ���ʽΪ HANDLE_NAME => {p1,p2...}
# Discription:
#    Asia.str�еĸ�ʽ
#  <entry handle="FIND_RESTROOM" translate="true" fixed_width="true">
#    <string>Restroom</string>
#    <description>Restroom button label</description>
#    <output-file>GUI_HandleFindPOI.hpp</output-file>
#  </entry>
################################################################################
sub Src2Hash
{
    my $srcFile = shift @_;
    my %contextHashTbl;
    my $hashKey;
    my $flag_NewEntry = 0;
    #debug 
    print "$srcFile\n";
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
            $contextHashTbl{$hashKey} = $1;
            $flag_NewEntry = 0;
        }
    }
    
    close srcHandle;
    #we need check $flag_NewEntry==0
    die "Error occour when read $srcFile" unless $flag_NewEntry == 0;
    
    return %contextHashTbl;
}

################################################################################
# function : translate2Hash
# discription : ��ȡXML��ʽ�ķ��뵵��������Լ���õĸ�ʽ����Hash��
# Input    : ���뵵������
# Output   : section��hash��
# Discription:
# XML�л����section�ĸ���
# hash Ŀǰ��ȡ�����Ľṹ���£�
#   %hash = (
#           SECTION_NAME_1 => {
#                               Index => value ,
#                               HANDLE_NAME => �����б�����indexValue visual��pronuciation[option],
#                               HANDLE_NAME => �����б�����indexValue visual��pronuciation[option],
#                               },
#           SECTION_NAME_2 => {},
#           );
# [update log]
# 1. ��hash��������һЩ�ֶ�����¼��˳���Ա�д���ļ�ʱ����˳��д�� ��<====TODO
################################################################################
sub translate2Hash
{
    my $fileName = shift @_;
    #print $fileName,"\n";
    my %sectionHash;
    my $secFlag = 0;
    my $entryFlag = 0;
    my $sectionName;
    my $strHandle = "__ERROR__";
    my $strVisual;
    my $strPronunc;
    my $sectionIndex = 0;
    my $preDefIndexName = "INDEX";
    my $handleIndex = 0;
    
    open( TRAN_FILE_HANDLE, "<:utf8", $fileName ) or die "$strHandle";
    
    foreach( <TRAN_FILE_HANDLE> )
    {
        if( !$secFlag && $_ =~ /<section name="(.*?)"/ )
        {
            # Section Start I need Clear $handleIndex
            $handleIndex = 0;
            $secFlag = 1;
            
            $sectionHash{$1}{$preDefIndexName} = $sectionIndex;
            $sectionIndex += 1;
            #print "begin section $1\n";
            $sectionName = $1;
        }
        if( $secFlag != 0 )
        {
            #print "debug $_ \n";
            if( $_ =~ /<entry handle="(.*?)"/ )
            {
                #print "$1\n";
                $strHandle = $1;
                $entryFlag = 1;
            }
            if( $_ =~ /<visual>(.*?)<\/visual>/ )
            {
                #print "      $1\n";
                $strVisual = $1;
                $entryFlag = 2;
            }
            if( $_ =~ /<pronunciation>(.*?)<\/pronunciation>/ )
            {
                #print "$1\n";
                $strPronunc = $1;
                $entryFlag = 3;
            }
        }
        if( $_ =~ /<\/entry>/ )
        {
            if( 0 != $entryFlag )
            {
                #Current Handle End
                #print "$strHandle end \n";
                $entryFlag = 0;
                my @plist;
                push @plist, $handleIndex;
                push @plist, $strVisual;
                if( $entryFlag == 3 )
                {
                    push @plist, $strPronunc;# unless $entryFlag == 3;
                }            
                $sectionHash{$sectionName}{$strHandle} = \@plist ;
                $handleIndex += 1;
            }
        }
        if( $secFlag && $_ =~ /<\/section>/ )
        {
            #section finished
            #print "section end $sectionName !\n";
            $secFlag = 0;
        }
    }
    
    close( TRAN_FILE_HANDLE );
    #we need check $flag_NewEntry==0
    die "Error occour when read" unless $secFlag == 0;
    
    return %sectionHash;
}
################################################################################
# function : Hash2Src ==> Hash2Translate д�ط��뵵
# discription : ��hash�����ָ���ĵ����У�������xml�������,����Hash�ĸ�ʽ�ο�
#               translate2Hash
# Input    : hash��,��ʽ��translate2Hash
# Input    : ���뵵����
# [log]    : ��section��handle����index˳��д��
################################################################################
sub Hash2Src
{
    
    my %inputHash = % { shift @_ };
    my $saveFileName = shift @_;
    
    open( SAVE_HANDLE, ">:utf8",$saveFileName) || die "cant open $saveFileName Error $?";
    my $sectionName;
    my $handleName;
    my $lineString;
    my $tabString = "    ";     #4���ո�for tab
    my $preDefIndexName = "INDEX";
     
    my $sectionCnt = keys %inputHash;
    print "\$sectionCnt = $sectionCnt\n";   
    for( my $indexForSection = 0;$indexForSection < $sectionCnt; $indexForSection++ )
    {
        my $secIdxFound = 0;
        foreach ( keys %inputHash )
        {
            if( $indexForSection == $inputHash{$_}{$preDefIndexName} )
            {
                #print "Found\n";
                $secIdxFound = 1;
                $sectionName = $_;
                last;
            }
        }
        print $sectionName,"\n";
        
        $lineString="<section name=\"$sectionName\">\n";
        print SAVE_HANDLE  $lineString;
        
        my $handleCnt = keys %{$inputHash{$sectionName}};
        #����˳��д��handles: Note there is INDEX for each $sectionName
        for( my $indexForHandle = 0; $indexForHandle < $handleCnt - 1; $indexForHandle++)
        {
            my $handleFound = 0;
            foreach $_ ( keys %{ $inputHash{$sectionName} } )
            {               
                if( $_ ne $preDefIndexName && $indexForHandle == scalar( $inputHash{$sectionName}{$_}[0] ) )
                {
                    $handleFound = 1;
                    $handleName = $_;
                    last;
                }
            }
            #die "Can't find $indexForHandle in $sectionName\n" || $handleFound == 1;
            
            #Now I need write $handleName 's information of $sectionName
            #write Entry start token
            #print "Writing[$indexForSection][$indexForHandle] $sectionName-----> $handleName\n";
            $lineString = "$tabString<entry handle=\"$handleName\">\n";
            print SAVE_HANDLE $lineString;
            
            #write othre informations
            print SAVE_HANDLE  "$tabString$tabString<strings>\n";
            print SAVE_HANDLE  "$tabString$tabString$tabString<string default=\"true\">\n";
            print SAVE_HANDLE  "$tabString$tabString$tabString$tabString<visual>$inputHash{$sectionName}{$handleName}[1]</visual>\n" ;
            if( defined ($inputHash{$sectionName}{$handleName}[2]) )
            {
                print SAVE_HANDLE  "$tabString$tabString$tabString$tabString<pronunciation>$inputHash{$sectionName}{$handleName}[2]</pronunciation>\n";
                #check SectionName should be ASR
            }
            print SAVE_HANDLE  "$tabString$tabString$tabString</string>\n";
            print SAVE_HANDLE  "$tabString$tabString</strings>\n";
            my $temp1 = "$tabString$tabString<usage ";
            if( defined $inputHash{$sectionName}{$handleName}[2] )
            {
                $temp1 .= "speechrec=\"true\" tts=\"true\"";
                                
            }
            if( $inputHash{$sectionName}{$handleName}[1] )
            {
                $temp1 .= " visual=\"true\"";
            }
            $temp1 .= "/>\n";
            print SAVE_HANDLE  $temp1;
            
            #write Entry end token
            $lineString = "$tabString</entry>\n";
            print SAVE_HANDLE  $lineString;
        }
        
        #write Section END token
        $lineString = "</section>\n";
        print SAVE_HANDLE  $lineString;
    }
    ##########old Code for Write####################################
    # foreach $sectionName ( keys %inputHash )
    # {
        # #write SectionName to file
        # $lineString="<section name=\"$sectionName\">\n";
        # print SAVE_HANDLE  $lineString;
        # foreach $handleName ( keys %{ $inputHash{$sectionName} } )
        # {
            # #write Entry start token
            # $lineString = "$tabString<entry handle=\"$handleName\">\n";
            # print SAVE_HANDLE $lineString;
            # 
            # #write othre informations
            # print SAVE_HANDLE  "$tabString$tabString<strings>\n";
            # print SAVE_HANDLE  "$tabString$tabString$tabString<string default=\"true\">\n";
            # print SAVE_HANDLE  "$tabString$tabString$tabString$tabString<visual>$inputHash{$sectionName}{$handleName}[0]</visual>\n" ;#unless defined $inputHash{$sectionName}{$handleName}[0];
            # if( defined ($inputHash{$sectionName}{$handleName}[1]) )
            # {
                # print SAVE_HANDLE  "$tabString$tabString$tabString$tabString<pronunciation>$inputHash{$sectionName}{$handleName}[1]</pronunciation>\n";# unless defined $inputHash{$sectionName}{$handleName}[1];
                # #check SectionName should be ASR
            # }
            # print SAVE_HANDLE  "$tabString$tabString$tabString</string>\n";
            # print SAVE_HANDLE  "$tabString$tabString</strings>\n";
            # my $temp1 = "$tabString$tabString<usage ";
            # if( defined $inputHash{$sectionName}{$handleName}[1] )
            # {
                # $temp1 .= "speechrec=\"true\" tts=\"true\"";
                                # 
            # }
            # if( $inputHash{$sectionName}{$handleName}[0] )
            # {
                # $temp1 .= " visual=\"true\"";
            # }
            # $temp1 .= "/>\n";
            # print SAVE_HANDLE  $temp1;
            # 
            # #write Entry end token
            # $lineString = "$tabString</entry>\n";
            # print SAVE_HANDLE  $lineString;
        # }
        # #write Section end token
        # $lineString = "</section>\n";
        # print SAVE_HANDLE  $lineString;
    # }
    close( SAVE_HANDLE );    
    1;
}

################################################################################
# function : MergeHash_Str_Translate
# discription : ��HANDLE_NAME��Ϊ�������Ƚϲ��ϲ�����Hash��һ����str�е����ݣ�
#               һ����translate��������translate��������str�е�handle��Ĭ������
#               �ڣ�ASIA
# Input    : �������ϲ���Hash��
# Output   : �ϲ����Hash��:������str��handle�ķ���
# [LOG]
# Becasue the Format of TranslateHash changed , need modify
################################################################################
sub MergeHash_Str_Translate
{
    my %strHandleHash = %{ shift @_ };
    my %translateHash = %{ shift @_ };
    #printTranslateHash(\%translateHash);
    my %resultHash;
    my $Translate_Flag = shift @_;

    my $preDefSecName = "ASIA"; ##��ǰ����û�з����handle�������ŵ�ASIA ������
    #TODO: merge
    if( ! exists $translateHash{$preDefSecName})
    {
        #print "No Asia Section \n";
    }
    my $unTranslate_visual = "__UnTranslate__:Origin Text is {";
    my $unTranslate_pronunciation = "__UnTranslate__";  
    my $preDefIndexName = "INDEX";
    
    my $handleFromStr;
    my $cnt_handleFromStr = 0;
    foreach $handleFromStr (keys %strHandleHash)
    {
        #print "check", $handleFromStr,"in : ";
        my $sectionName ;
        my $handleName;
        my $flag_Translated = 0;
        foreach $sectionName (keys %translateHash)
        {
            #print $sectionName, "\n";
            foreach $handleName (keys %{ $translateHash{$sectionName}} )
            {
                #print "\t$handleName","\n";
                #check translate contain pronunciation or not
                if( $handleName ne $preDefIndexName && $translateHash{$sectionName}{$handleName}[2] )
                {
                    $Translate_Flag = "true";
                }
                else
                {
                    $Translate_Flag = "false";
                }
                if( $handleName ne $preDefIndexName && $handleName eq $handleFromStr )
                {#���ҵ���str�ķ���ʱ��ֱ��ʹ���������Ƿ������ĸ�section��
                    #print $handleName,"\n";
                    $flag_Translated = 1;
                    $resultHash{$preDefSecName}{$handleName}[0] = $cnt_handleFromStr;
                    $cnt_handleFromStr++;
                    $resultHash{$preDefSecName}{$handleName}[1] = $translateHash{$sectionName}{$handleName}[1];  
                    if( $Translate_Flag eq "true")
                    {   
                        $resultHash{$preDefSecName}{$handleName}[2] = $translateHash{$sectionName}{$handleName}[2];
                    }                  
                }
                else
                {
                    #TODO
                }
            }
        }
        if( $flag_Translated == 0 )        
        {#û���ҵ�����
            #print "not found : $handleFromStr\n";
            $resultHash{$preDefSecName}{$handleFromStr}[0] = $cnt_handleFromStr;
            $cnt_handleFromStr++; 
            $resultHash{$preDefSecName}{$handleFromStr}[1] = $unTranslate_visual.$strHandleHash{$handleFromStr}."}";
            #In default situation : I wont give pronunciation for unTranslated stringhandle.
        }      
    }
    $resultHash{$preDefSecName}{$preDefIndexName} = 0;
        
    %resultHash;
}
################################################################################
# function : Mergehash_Translates
# discription : ��HANDLE_NAME��Ϊ�������Ƚϲ��ϲ�����Hash��:ӵ��ͬ����
# Input    : �������ϲ���Hash��
# Output   : �ϲ����Hash��
# TODO: ������HANDLE_NAME��ͬʱ�����������Բ�ͬ�������δ���:����취����base�е�Ϊ��׼
################################################################################
sub Mergehash_Translates
{
    my %translateBase = %{ shift @_ };
    my %translateRef = %{ shift @_ };
    # printTranslateHash(\%translateBase);
    print "======\n";
    #printTranslateHash(\%translateRef);
    print "======\n";
    #if we get the same handle with different translate, we use Base's translate
    my $secBase;
    my $handleBase;
    my $secRef;
    my $handleRef;
    my $preDefIndexName = "INDEX";
    foreach $secRef ( keys %translateRef )
    {
        foreach $handleRef ( keys %{ $translateRef{$secRef} } )
        {
            #���ڲο������е�$secRef{$handleRef}
            my $isFound = 0;
            if( $handleRef eq $preDefIndexName )
            {
                next;
            }
            #$handleRef ��һ����Ч��handle ���ƣ��������base���Ƿ񱻷����
            print "find out $handleRef in Base \n";
            foreach $secBase ( keys %translateBase )
            {
                foreach $handleBase ( keys %{ $translateBase{$secBase} } )
                {
                    if( $handleBase ne $preDefIndexName && $handleRef eq $handleBase )
                    {
                        print "$handleRef found in base hash \n";
                        if( $secRef eq $secBase )
                        {
                            $isFound = 1;
                        }
                        else
                        {
                            #TODO same handle found different section
                            #print "Base:",$secBase,"=>",$handleBase," _|_ Ref:",$secRef,"=>",$handleBase,"\n"; 
                            #die "error";
                            $isFound = 2;
                        }                        
                    }
                }#end foreach $handleBase
            }#end foreach $secBase

            if( $isFound == 0 )
            {#Ref �е�handle��base��û�з��룬����
                #handle from Ref not found in Base Hash
                #print "8****8",$secRef,$handleRef,"\n";
                my $newHandleIndex = 0;
                if( exists $translateBase{$secRef} )
                {
                 #���Base����$secRef���Section����,����ԭ��û�У��ڲ����Ҳ����ڣ�
                 #����ͳ��һ������handle�ĸ���
                    $newHandleIndex = keys %{$translateBase{$secRef}};
                    #print "In Base translate Hash : Section $secRef has $newHandleIndex handles\n";
                }
                $translateBase{$secRef}{$handleRef}[0] = $newHandleIndex - 1;
                $translateBase{$secRef}{$handleRef}[1] = $translateRef{$secRef}{$handleRef}[1];
                if( defined $translateRef{$secRef}{$handleRef}[2] )
                {
                    $translateBase{$secRef}{$handleRef}[2] = $translateRef{$secRef}{$handleRef}[2];                   
                }
            }
            else
            {
                #print "debugline \n";
                next;
            }
            
        }#end foreach $handleRef
    }#end foreach $secRef
    return %translateBase;
}
################################################################################
#Function ��updateWithNew
#in Param : srcHash
#in Param : newHash
#out Param: updatedHash
################################################################################
sub updateWithNew
{
    my %srcHash = %{shift @_};
    my %newHash = %{shift @_};
    my %resultHash;
    
    my $logFile = "UpdateError.log";
    open( LOGFILEHANDLE, ">:utf8",$logFile );
    
    my $section;
    my $handle;
        
    close LOGFILEHANDLE;
    return %resultHash;
}

################################################################################
#debug fucntion
################################################################################
sub printTranslateHash
{
    my %hash = %{ shift @_ };
    my $sec;
    my $handle;
    my $preDefIndexName = "INDEX";
    print "*"x79,"\n";
    foreach $sec (keys %hash)
    {
        my $handleCnt = %{ $hash{$sec} };

        foreach $handle (keys %{ $hash{$sec} })
        {
            if( $preDefIndexName eq $handle )
            {
                print "\t","Section",$preDefIndexName,"=",$hash{$sec}{$preDefIndexName},"\n";
            }
            else
            {
                print "\t",$handle,"\n";                
                print "\t"x 2,"KeyIndex = ",$hash{$sec}{$handle}[0],"\n";
                print "\t"x 2,$hash{$sec}{$handle}[1],"\n";
                if ( defined $hash{$sec}{$handle}[2] )
                {
                    print "\t"x 2,$hash{$sec}{$handle}[1],"\n";
                }
            }
        }
    }
    print "*"x79,"\n";
}
sub printStrHash
{
    my %strHash = %{ shift @_ };
    while( (my $key,my $value) = (each %strHash) )
    {
        print "$key-->$value\n";
    }   
}