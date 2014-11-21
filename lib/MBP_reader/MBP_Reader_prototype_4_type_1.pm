package MBP_Reader_prototype_4_type_1;
#!/usr/bin/perl -w
#
# 20120527 
# prototype for extracting text from kindle fire 'alike' mbp files
# based on B0******UY_EBOK.mbp
#
# public methods:
# $self = new ($mbp_file)
# {0|1} = process ($mbp_file)
# $error = error()
use strict;

#
# new()
#
sub new() {

	my ($class, $mbp_file) = @_;
	
	# mbp_file is always compulsory!
	if (!defined $mbp_file) {
		return;
	}

    my $self = {
		# file path+name.
		FILE_NAME	=> $mbp_file,
		ERROR		=> undef,
		NOTES		=> undef,
	};
	bless $self, $class;	#'MBP_Reader';

    return $self;

}

#
# process()
#
sub process() {

	my ($type, $string, $STATE);
	my @notes;
	my $MARK_OF_RECORDS='"records"';
	my $MARK_OF_SUBJECT='"subject": ';
	###

	my ($self) = @_;

	open fIn, '<', $self->{FILE_NAME} || (
			$self->{ERROR}="Can't open file!",
			return 0
		);
	binmode fIn;
	###

	$STATE=0; # 0: mark of correct file type not detected; 1: mark detected!
	foreach $string ( <fIn> ) {

		if ($string=~/$MARK_OF_RECORDS/) {
			$STATE=1; # mark detected!
		}

		if ($STATE==1) {
			if ($string=~/"type": *"kindle.([^\"]+)"/) {
				$type=$1;
			} elsif ($string=~/\},/) {
				$type='';
			}

			if ( $string =~ /${MARK_OF_SUBJECT}\"([^\"]*)\"/ ) {
				push @notes, {$type => $1};
			}
		}
	}

	if ($STATE==1) {
		$self->{NOTES}=\@notes;
		return 1;
	} else {
		$self->{ERROR}='File is not a Kindle Fire mbp file!';
		return 0;
	}

}


# returns last error occurred in this object's processes (if any).
sub error {
	my ($self) = @_;
	if (defined $self->{ERROR}) {
		return $self->{ERROR};
	}
	return '';
}


1;