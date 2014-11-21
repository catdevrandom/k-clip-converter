#!/usr/local/bin/perl
# test use of MBP_Reader.pm
#
# This package reads a .MBP file,
# which are the files that store user added information to
# any of the file formats that "mobipocket reader" can read.
# So, a .MBP file associated to a (for example) .PRC book file,
# would contain annotations, corrections, drawings and marks
# made by the user on the .PRC content.
#
# This script test the Perl class MBP_Reader, which reads
# and parses the contents of the file passed as first argument.
# This script generates three files (see below):
# $FILE_TEST_OUT			this file should be identical to the original.
# $FILE_TEST_STATISTICS_OUT	this file will contain detailed descriptions.
# $FILE_TEST_USER_MARKS_OUT	this file will contain user marks, in text format.
# $FILE_ERROR_OUT			this file will contain error descriptions, if any.
#
#
# v0.5.c, 201311, by idleloop@yahoo.com
# http://www.angelfire.com/ego2/idleloop/
#
#
use strict;

use lib '.';
use MBP_Reader;
use MBP_Reader_prototype_4_unknown_file_types;
use MBP_Reader_prototype_4_type_1;

# ------------------------------------------------
my $BEHAVIOUR='unix'; # unix | windows

my $FILE_TEST_OUT='mbp.test.out';
my $FILE_TEST_STATISTICS_OUT='mbp.statistics.txt';
my $FILE_TEST_USER_MARKS_OUT='mbp.user_marks.txt';
my $FILE_ERROR_OUT='mbp.errors.txt';
my $FILE_PARAMETERS='mbp.parameters.txt'; # this file can contain parameters. It'll be created if it doesn't exist.

my $DRAWING_COUNTER='000';
my $DRAWING_FILE_PREFIX='';

my $MBP_AUTHORING_LINE=MBP_Reader->authoring;

my ($MODULE_GD,@mbp_files,$mbp_file,$PREVIOUS_NEWLINE);

my $MBP_TYPE=0; # 0: 'normal' mbp file; 1: kindle fire mbp; 2: raw binary with text inclusions

my $BKMK_PAGE_FACTOR=0; # this value will be read from $FILE_PARAMETERS txt file, if it exists.
my $SHOW_MARK_TYPE=1;	# this value will be read from $FILE_PARAMETERS txt file, if it exists.

sub print_info;
sub page_in_book;
# ------------------------------------------------

print $MBP_AUTHORING_LINE;

if ($BEHAVIOUR eq 'windows' || !defined $ARGV[0]) {

	opendir fDir, '.' || die "Can't open directory (?)\n";
	@mbp_files=grep { /.mbp$/i && -f $_ } readdir (fDir);
	close fDir;

	if ($#mbp_files==-1) {
		die "Put your mobipocket .mbp files in this directory\n";
	}

} else {

	if (!defined $ARGV[0] or $ARGV[0]=~/^ *$/) {
		die "Usage:\nperl MBP_Reader.pl \[mbp_file_name.mbp\]\n\n";
	}
	push @mbp_files, $ARGV[0];

}

open fError, '>', $FILE_ERROR_OUT;

eval
q{
use GD;
use MBP_Reader_Drawing;
$MODULE_GD=1;
}
or do {
$MODULE_GD=0;
print fError "WARNING:\nModule GD is not installed in this system:\n".
			"Images won't be exported.\n\n";
};

# ------------------------------------------------
# $FILE_PARAMETERS file can contain parameters. It'll be created if it doesn't exist.
if (!-e $FILE_PARAMETERS) {
	open fParameters, '>', $FILE_PARAMETERS;
	print fParameters <<PARAMETERS_FILE_CONTENT;
# --- MBP_reader parameters file --- 
# v0.5.b
# Uncomment desired values (that is, delete first "#" character on that line),
#
# BKMK_PAGE_FACTOR: used to calculate page locations: 
# 	the greater the value, the lesser the page.
# if you find a value that fits to your device, send me it and 
#	I'll include it here! (idleloop\@yahoo.com)
# SHOW_MARK_TYPE: if 0, does not show "[MARK]" before marks...
#
# for Kindle devices ("David Friedman" <david.kit.friedman\@gmail.com>) :
#BKMK_PAGE_FACTOR=150 
#SHOW_MARK_TYPE=0
PARAMETERS_FILE_CONTENT
	close fParameters;
} else {
	open fParameters, '<', $FILE_PARAMETERS;
	# $BKMK_PAGE_FACTOR value will be read from $BKMK_PAGE_FACTOR_FILE txt file, if it exists.
	foreach (<fParameters>) {
		if (/^ *BKMK_PAGE_FACTOR=([0-9.]+)/) {
			$BKMK_PAGE_FACTOR=$1;
		}
		if (/^ *SHOW_MARK_TYPE=([01])/) {
			$SHOW_MARK_TYPE=$1;
		}
	}
	close fParameters;
}

# ------------------------------------------------
foreach $mbp_file (@mbp_files) {

  print "--\n\nmbp file: '$mbp_file'\n";

  $MBP_TYPE=0; # start by default as if all they were 'good' mbp files

  my $DRAWING_COUNTER='000';

  # form the drawing file prefix:
  $DRAWING_FILE_PREFIX=$mbp_file; # in case MBP file name has no dot.
  if ( $mbp_file=~/^(.+)\./ ) {
  	$DRAWING_FILE_PREFIX=$1;
  }
  
  ($FILE_TEST_USER_MARKS_OUT)=$mbp_file=~/(.+).mbp$/i;
  $FILE_TEST_USER_MARKS_OUT=$FILE_TEST_USER_MARKS_OUT.'.mbp_notes.txt';
  
  my $MBP_reader=MBP_Reader->new($mbp_file);
  
  $MBP_reader->process;

  if ($MBP_reader->error || $#{$MBP_reader->{MBP_USER_MARKS}}<0) {
    #print $MBP_reader->error."\n\n".$#{$MBP_reader->{MBP_USER_MARKS}}."\n\n";
	$MBP_reader=new MBP_Reader_prototype_4_type_1($mbp_file);
	if ($MBP_reader->process) {
		$MBP_TYPE=1;
	} else {
		# try last method!
		$MBP_reader=new MBP_Reader_prototype_4_unknown_file_types($mbp_file);
		$MBP_reader->process;
		$MBP_TYPE=2;
	}
  }
  
  if ($MBP_reader->error) {
  	my $error_string="$mbp_file : \nERROR:".$MBP_reader->error."\n!!!\n";
  	print_info $error_string;
  	print fError $error_string;
  	next;
  }
  
  
  # test file in order to assure that all has been correctly processed
  # (just binary compare $FILE_TEST_OUT and the original mbp)
  if ($BEHAVIOUR eq 'unix' && $MBP_TYPE==0) {
  	open fOut, '>', $FILE_TEST_OUT;
  	binmode fOut;
  	#print fOut $MBP_reader->{FILE};
  	print fOut $MBP_reader->{HEADER};
  	print fOut $MBP_reader->{BPARMOBI};
  	print fOut $MBP_reader->{INDEX_TABLE};
  	#print fOut $MBP_reader->{BPAR_MARK};
  	print fOut $MBP_reader->{USER_MARKS_DATA};
  	print fOut $MBP_reader->{USER_MARKS_BKMK};
  	close fOut;
  }
  
  if ($BEHAVIOUR eq 'unix' && $MBP_TYPE==0) {
  	close STDOUT;
    # 201203 UTF-16BE:
    open (STDOUT, '>:utf8', $FILE_TEST_STATISTICS_OUT);
  }
  if ($MBP_TYPE==0) {
	# 201203 UTF-16BE:
	open (fUserMarks, '>:utf8', $FILE_TEST_USER_MARKS_OUT);
  } else {
	# kindle fire files (or binaries with text inclusions?) do not need utf8 conversion:
	open (fUserMarks, '>', $FILE_TEST_USER_MARKS_OUT);
  }
  #	(hope BOM would b always compatible... if not, at least it'd be mostly readable)
  #print fUserMarks, "\xEF\xBB\xBF";
  
  $PREVIOUS_NEWLINE=$\;
  # make line jumps a little more clean:
  $\="\n";
  
  print_info $MBP_AUTHORING_LINE;
  print fUserMarks $MBP_AUTHORING_LINE;
  
  print_info "MBP file: ", $mbp_file;
  if ($MBP_TYPE==0) {
	print_info "next free pointer: ", $MBP_reader->{BPARMOBI_NEXT_FREE_POINTER};
	print_info "number of index table entries: ", $MBP_reader->{BPARMOBI_NUMBER_INDEX_ENTRIES};
	print_info "number of marks: ", $#{$MBP_reader->{MBP_USER_MARKS}};
	print_info "(internals:\nshould be ARRAY: ", ref $MBP_reader->{MBP_USER_MARKS};
	print_info "should be MBP_User_Mark: ", ref ${$MBP_reader->{MBP_USER_MARKS}}[0];
	print_info ")\n----------";
  }
  print fUserMarks "MBP file: ", $mbp_file, "\n";
  if ($MBP_TYPE==0) {
	  print fUserMarks "number of marks: ", $#{$MBP_reader->{MBP_USER_MARKS}}, "\n";
  } elsif ($MBP_TYPE==1 || $MBP_TYPE==2) {
	  print fUserMarks "number of marks: ", $#{$MBP_reader->{NOTES}}, "\n";
  }
  
  my ($user_mark, $temp, $i, $j);

  if ($MBP_TYPE==0) {

	foreach $user_mark (@{$MBP_reader->{MBP_USER_MARKS}}) {
		print_info "-"x50;
		print_info "ref $user_mark";
		print_info "type: ",$user_mark->type;
		print_info "order in book: ",$user_mark->order;
		print_info "order of DATA blocks in index table: ",$user_mark->index_order;
		print_info "ref: ",ref $user_mark->DATA_get;
		print_info '$# of DATA blocks ',$#{$user_mark->DATA_get};
		print_info "---DATA blocks:";
		$i=$j=0;
		foreach (@{$user_mark->DATA_get}) {
			print_info "ref: ",ref $_;
			print_info "index id: ",$_->index_pointer;
			print_info "text: ", $_->text_get;
			if ($user_mark->type !~ /^BPAR$/ && $_->text_get ne '') {
				print fUserMarks "\n--" if ($i % 2 == 0);
				if ($user_mark->type !~ /^NOTE$/) {
					if ($user_mark->type !~ /^CORRECTION$/) {
						#print fUserMarks '['.$user_mark->type.']', page_in_book($user_mark);	
						userMarks('['.$user_mark->type.']', page_in_book($user_mark));						
					} else {
						if ($j % 2 == 0) {
							#print fUserMarks '['.$user_mark->type.']', page_in_book($user_mark);					
							userMarks('['.$user_mark->type.']', page_in_book($user_mark));						
							$j++;
						} else {
							print fUserMarks ':';
							$j=0;
						}
					}
				}
				if (++$i % 2 == 1 && 
					$user_mark->type =~ /^NOTE$/) {
					print fUserMarks page_in_book($user_mark);
					print fUserMarks $_->text_get;
					print fUserMarks ':';
				} else {
					print fUserMarks $_->text_get;
				}
			}
			if ($MODULE_GD==1 &&
				$user_mark->type =~ /^DRAWING$/ && 
				$_->DATA =~ /^DATA....ADQM/s ) {
				$DRAWING_COUNTER++;
				my $image=new MBP_Reader_Drawing($_->DATA,
							$DRAWING_FILE_PREFIX.'.mbp.'.$DRAWING_COUNTER);
				if ($BEHAVIOUR eq 'unix') {
					$image->log_file_descriptor(\*STDOUT);
					$image->log_file_newline('');
				}
				$image->background_color($user_mark->BKMK_get->color);
				print_info 'BGCOLOR: '.$user_mark->BKMK_get->color;
				$image->generate_MBP_image;
				if ($image->error ne '') {
					print_info "$mbp_file : \nERROR: ".$image->error;
					print fError "$mbp_file : \nERROR: ".$image->error;
				} else {
					print fUserMarks ":\n<image file: ".$image->file_name.'>';
				}
			}
			print_info "DATA: ",unpack('H*',$_->DATA);
		}
		print_info "---BKMK block:";
		print_info "ref: ",ref $user_mark->BKMK_get;
		$temp=$user_mark->BKMK_get;
		if (defined $temp) {
			print_info "index id: ",$temp->index_pointer;
			print_info "BKMK: ",unpack('H*',$temp->BKMK);
		}
	}

  } elsif ($MBP_TYPE==1) {

	foreach $user_mark (@{$MBP_reader->{NOTES}}) {
		foreach (keys %$user_mark) {
			print fUserMarks "\n--\n$_:\n\n$$user_mark{$_}";
		}
	}

  } elsif ($MBP_TYPE==2) {

	foreach $user_mark (@{$MBP_reader->{NOTES}}) {
		#print fUserMarks "[NOTE]:\n".$user_mark."\n--\n";
		print fUserMarks "\n--\n\n".$user_mark;
	}

  }
  
  if ($BEHAVIOUR eq 'unix') {
  	close STDOUT;
  	open (STDOUT, '>&2'); # as normal.
  }
  close fUserMarks;
  
  if ($MBP_TYPE==0) {
	print "Number of user marks: ", $#{$MBP_reader->{MBP_USER_MARKS}};
  } elsif ($MBP_TYPE==1 || $MBP_TYPE==2) {
	print "Number of user marks: ", $#{$MBP_reader->{NOTES}};
  }
  print "User marks exported to file: ", $FILE_TEST_USER_MARKS_OUT;
  print '';

  $\='';

} #(foreach $mbp_file)
# ------------------------------------------------


$\=$PREVIOUS_NEWLINE;

close fError;

# process end.

# ------------------------------------------------

# prints as 'print' does, but only if BEHAVIOUR is 'unix'.
sub print_info {
	my @strings=@_;
	if ($BEHAVIOUR ne 'unix') {
		return;
	}
	my $string;
	foreach (@strings) {
		$string.=$_;
	}
	print $string;
}

# returns a value to be printed as bookmark page location.
sub page_in_book {
	my $mark=shift;
	if (defined $mark->BKMK_get && $BKMK_PAGE_FACTOR>0) {
		return ' (p '. int(unpack( "N", substr($mark->BKMK_get->BKMK, 16, 4) ) / $BKMK_PAGE_FACTOR) .')';
	}
}

# prints infos before note content.
sub userMarks {
	my $type=shift;
	my $page=shift;
	if ($SHOW_MARK_TYPE==1) {
		print fUserMarks '['.$type.']', $page;	
	} elsif ($page ne '') {
		print fUserMarks $page;
	}
}