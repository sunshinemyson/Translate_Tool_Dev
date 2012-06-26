use Tk;
use Switch;
#use Tk::FileDialog;
use strict;

my $MainWindow = new MainWindow(-background=>'blue');
$MainWindow->minsize( qw( 800 480 ) );
####################################################################################################
# Group 1 Start:
#G1.1 Line One
my $Group_One_Frame = $MainWindow->Frame( -background =>'blue', -borderwidth =>3 );
$Group_One_Frame->pack(-fill=>'x',-side => 'top' );

$Group_One_Frame->Label(-text=>'Handle File Name',-background =>'blue',-foreground => 'white',-width => 25)->pack(-fill=>'x',-side=>'left' );

#翻译的handle档案全名
my $TxtHandleFile = "<Text Handle File Name>";
my $Group_One_Entry_TxtFileName = $Group_One_Frame->Entry( -width => 40 , -textvariable => \$TxtHandleFile, -justify => 'right' );
$Group_One_Entry_TxtFileName->pack(-side => 'left', -fill=>'x' | 'y');
#浏览按钮：打开文件浏览窗口，指定TextHandle文件的位置
$Group_One_Frame->Button(-text=>'Browse..', -command => sub{ &handleBrowseFile( "OPEN_TEXT_FILE" ); })->pack(-side => 'left');

$Group_One_Frame->Label(-text=>'Token For Un_Translated Handle',-background =>'blue',-foreground => 'white',-width => 30)->pack(-fill=>'x' ,-side=>'left' );

my $Group_One_Entry_SpecialString = $Group_One_Frame->Entry( -width =>40,-text=>'__UN_TRANS_YET__', -justify => 'right' );
$Group_One_Entry_SpecialString->pack(-side=>'left',-fill=>'x' | 'y');

# G1.2 Line Two
my $Group_Two_Frame = $MainWindow->Frame( -background =>'blue', -borderwidth =>3 );
$Group_Two_Frame->pack( -fill => 'x' , -side => 'top' );

$Group_Two_Frame->Label(-text=>'Origin Translate File:',-background =>'blue',-foreground => 'white',-width => 25)->pack(-side=>'left');

#原始翻译档案全名：必须
my $OrginFileName = "<*.glx>";
my $Group_Two_Entry_OriginTranslation = $Group_Two_Frame->Entry( -width => 40, -textvariable => \$OrginFileName, -justify => 'right' );
$Group_Two_Entry_OriginTranslation->pack(-side => 'left', -fill=>'x' | 'y');
#浏览按钮：打开文件浏览窗口，指定原始翻译文件的位置
$Group_Two_Frame->Button(-text=>'Browse..', -command => sub{ &handleBrowseFile("OPEN_ORIGIN_FILE"); })->pack(-side => 'left');

$Group_Two_Frame->Label(-text=>'Reference Translation File[Optional]',-background =>'blue',-foreground => 'white',-width => 30)->pack(-fill=>'x' ,-side=>'left' );

#参考翻译的路径全名：可选
my $RefFileName = "[Optional]<*.glx>";
my $Group_Two_Entry_RefTranslation = $Group_Two_Frame->Entry( -width =>40, -textvariable => \$RefFileName, -justify => 'right');
$Group_Two_Entry_RefTranslation->pack(-side=>'left',-fill=>'x' | 'y');
#浏览按钮：打开文件浏览窗口，指定参考翻译文件的位置
$Group_Two_Frame->Button(-text=>'Browse..', -command => sub{ &handleBrowseFile("OPEN_REF_FILE"); })->pack(-side => 'left');

#G1.3 Button line
my $Group_Three_Frame = $MainWindow->Frame( -background =>'blue', -borderwidth=>3 );
$Group_Three_Frame->pack(-fill=>'x',-side => 'top' );
my $Group_One_Translate_Button = $Group_Three_Frame->Button
			(
				-text=>'Update',
				-command => sub { handleUpdate(); },
				-width => 150,
				-background => 'gray'
			);
$Group_One_Translate_Button->pack( -fill =>'x' | 'y' );
#Group1 End;
####################################################################################################
#Group 2 Start:
my $FileToSearch = "File Path for Search";
my $HandleToSearch = "[Handle Name Or Handle Text File Name]";
#---------------------------------------------------------------------------------------------------
my $GFrame1 = $MainWindow->Frame
							( 
								-background =>'blue',
								-borderwidth => 3
							)->pack( -fill => 'x' , -side => 'top' );
$GFrame1->Label
			(
				-text=>'File To Look Up',
				-background =>'blue',
				-foreground => 'white',
				-width => 25 
			)->pack(-side => 'left');

$GFrame1->Entry
			(
				-justify => 'right',
				-width => 40,
				-textvariable => \$FileToSearch
			)->pack( -side => 'left' );
$GFrame1->Button
			(
				-text => 'Browse...',
				-command => sub{ handleBrowseFile("OPEN_FILE_SEARCH");}
			)->pack(-side => 'left');#, -ipadx => 5, -ipady => 5);
#---------------------------------------------------------------------------------------------------
my $GFrame2 = $MainWindow->Frame
				( 
					-background =>'blue',
					-borderwidth => 3
				)->pack( -fill => 'x' , -side => 'top' );
$GFrame2->Label
			(
				-text=>'Handle To Check',
				-background =>'blue',
				-foreground => 'white',
				-width => 25
			)->pack(-side => 'left');
$GFrame2->Entry
			(
				-textvariable => \$HandleToSearch,
				-justify => 'right',
				-width => 40, 
			) ->pack(-side=>'left');
$GFrame2->Button
			(
				-text => 'Browse...',
				-command => sub{ handleBrowseFile("OPEN_FILE_SEARCH_HANDLE");}
			)->pack(-side => 'left');
#---------------------------------------------------------------------------------------------------
my $GFrame3 = $MainWindow->Frame
				( 
					-background =>'blue',
					-borderwidth => 3
				)->pack( -side => 'top');
				
$GFrame3->Button
			(
				-background => 'gray',
				-width => 150,
				-text => 'Search&&Check',
				-command => sub { &handleHandleSearch(); }
			)->pack();
#---------------------------------------------------------------------------------------------------

#Group 2 End;
####################################################################################################
#Group 3 Start:

#Group 3 End;
####################################################################################################
MainLoop;

####################################################################################################
# sub 处理Update按钮事件
####################################################################################################
sub handleUpdate
{
	print "hello Button\n";
	my $TxtFileName = $Group_One_Entry_TxtFileName->get();
	my $SpecialToken = $Group_One_Entry_SpecialString->get();
	my $OrginTranslateFile = $Group_Two_Entry_OriginTranslation->get();
	my $RefTranslateFile = $Group_Two_Entry_RefTranslation->get();
	print " Text handle file is $TxtFileName\n";
	print " Special Token for Untranslate file is $SpecialToken\n" ;
	print " Orgin Translation File is $OrginTranslateFile \n";
	print " Reference Translation File is $RefTranslateFile \n ";
	
	#检查合法性
	my $prmtStr = "";
	
	#检查handle档案名称
	if( $TxtFileName ne "" && $TxtFileName =~ /(.*)\.str/ )
	{
		print "TxtHandle file name is right \n";
	}
	else
	{
		$prmtStr = $prmtStr."Text Handle File got some error!\n";		
	}
	
	if( $SpecialToken eq "" )
	{
		$prmtStr = $prmtStr."Special Token For Untranlated Handle is Empty\n";
	}
	#检查原始翻译档案名
	if( $OrginTranslateFile ne "" && $OrginTranslateFile =~ /(.*)\.glx/ )
	{
		print "Orgin Translation File is Right \n";
	}
	else
	{
		$prmtStr = $prmtStr."Orgin Translation File Error\n";
	}
	#检查参考翻译档案
	if( $RefTranslateFile ne "" && $RefTranslateFile =~ /(.*)\.glx/ && $RefTranslateFile ne $OrginTranslateFile )
	{
		print "Reference Translation File is right\n";
	}
	else
	{
		$prmtStr = $prmtStr."Reference Translation File Error,This Field is optional\n";
		if( $RefTranslateFile eq $OrginTranslateFile )
		{
			$prmtStr = $prmtStr."Reference File same as Orgin File\n";
		}
	}
	
	#检查翻译档案名是否一样
	$OrginTranslateFile =~ /(.*)\.glx/;
	my $temp_Origin = $1;
	$RefTranslateFile =~ /(.*)\.glx/;
	my $temp_Ref = $1;
	
	if( $temp_Ref ne $temp_Origin )
	{
		$prmtStr .= " You dont have two Translation File with same name \n";
	}
	
	#print $prmtStr;
	if( $prmtStr ne "" )
	{
		my $Err = $MainWindow->Toplevel(-title=>"!!!Error Message!!!");
		$Err->Label(-text => $prmtStr )->pack( -anchor => 'center');
	}
	else
	{
		#TODO: Add Update Code Here!!!!
		my $Err = $MainWindow->Toplevel(-title=>"Update Successfull");
		$Err->Label(-text => "Update $OrginTranslateFile Finished\n" )->pack();
	}

}

####################################################################################################
# sub 处理文件浏览按钮事件
####################################################################################################
sub handleBrowseFile
{
	my $WhichType = shift @_;
	#打印传入的参数
	print "*" x 59 . "\n";
	print $WhichType , "\n";
	print "*" x 59 . "\n";
	
	my $FileName = $MainWindow->getOpenFile();
	print "$FileName \n";
	switch ($WhichType)
	{
		case "OPEN_TEXT_FILE" 
		{
			print "Set TextHandle File\n";
			#${ $tempHandle } = $FileName;
			$TxtHandleFile = $FileName;
			#last;
		}
		case "OPEN_ORIGIN_FILE" 
		{
			print "Set Origin Translation File\n";
			$OrginFileName = $FileName;
		}
		case "OPEN_REF_FILE" 
		{
			$RefFileName = $FileName;
			print "Set Reference Translation File\n";
		}
		case "OPEN_FILE_SEARCH"
		{
			$FileToSearch = $FileName;
		}
		case "OPEN_FILE_SEARCH_HANDLE"
		{
			$HandleToSearch = $FileName;
		}
		else
		{
			die "Error Situation";
		}
	}
}

####################################################################################################
# sub 处理搜寻Handle的翻译搜寻工作
####################################################################################################
sub handleHandleSearch
{
	my $SrchWindow = $MainWindow->Toplevel
									(
										-title => 'Search handle',
										#-width => 800,
										#-higth => 600
									);
	#$SrchWindow->
}



