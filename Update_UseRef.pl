
#debug code
@content = cacheReference("Ref\\bh_ML.glx");
updateWithCahcedTranslation( \@content, "filesToUpdate\\bh_ML.glx");
#debug(\@content);

###############################################################################
#                            cacheReference
# 缓存参考翻译
###############################################################################
sub cacheReference
{
    my $fileName = shift @_;
    my @cache;      #缓存到内存的地方
    
    open( FILEHANDLE, "<:utf8", $fileName ) || die " can't open $fileName ";
    my $curSection = 0 ;
    my $curHandle  = 0 ; 
    my @curTranlations = qw<>;
    foreach( <FILEHANDLE> )
    {
        if( $_ =~ /<section name="(.*?)">/ )
        {
            $curSetion = $1;
        }
        if( $_ =~ /<entry handle="(.*?)"/ )
        {
            #$curSetion != 0 or die " $1 is not include by any section\n ";
            $curHandle = $1;
        }
        if( $_ =~ /<visual>(.*?)<\/visual>/ )
        {
            #!defined($curHandle) || die "$1 is not include by any handle\n";
            push @curTranlations, $1;
        }
        if( $_ =~ /<\/entry>/ )
        {
            # end of current Handle
            my @transOfCurrent;
            push @transOfCurrent, $curHandle;
            push @transOfCurrent, $curSetion;
            push @transOfCurrent, @curTranlations;
            
            @curTranlations = qw<>;
            @curHandle = 0;
            #@curSection = 0;
            push @cache, \@transOfCurrent;
            
            #debug start -->
            #print @transOfCurrent,"\n11111";
            #debug end <--
        }
    }    
    close FILEHANDLE;
   
    @cache;
}
###############################################################################
#                            updateWithCahcedTranslation
#   update transltions with cached translation 
# argument list : 
#   \@cachedTranslate : address of cached translation results;
#   $fileToUpdate 
###############################################################################
sub updateWithCahcedTranslation {
    my @cachedTranslate = @{shift @_};
    my $fileToUpdate = shift @_;
    
    open (FILEHANDLE, "<:utf8",$fileToUpdate ) || die "faild $fileToUpdate";
    
    my $sectionName = 0;
    my $handleName = 0;
    my @translation = qw<>;
    my $updatedFileContext = "";
    foreach( <FILEHANDLE> )
    {
        if( $_ =~ /<section name="(.*?)">/ ){
            $sectionName = $1;
        }
        if( $_ =~ /<entry handle="(.*?)"/ ){
            $handleName = $1;
        }
        if( $_ =~ /<visual>(.*?)<\/visual>/ ){
            push @translation, $1;
        }
        if( $_ =~ /<\/entry>/ ){
            #check out current handle 's translation 
            foreach( @cachedTranslate ){
                my $handle = shift @$_;
                my $section = shift @$_;
                if( $handle eq $handleName && $sectionName eq $section ){
                    print "<$sectionName><$handleName>need update";
                   @translation = @$_;
                }
            }
            $handleName = 0;
            @translation = qw<>;
        }
        if( $_ =~ /<\/section>/ ){
            $sectionName = 0;
        }
    }
    close FILEHANDLE;
}
sub debug {
    my @list = @{shift @_};
    foreach( @list ) {
        my $handle = shift @$_;
        my $section = shift @$_;
        my @translation = @$_;
        print $handle," -- ",$section,"\n";
        print "\t@translation\n";
    }
}

1;