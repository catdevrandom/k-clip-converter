package MBP_Reader_prototype_4_unknown_file_types;
#!/usr/bin/perl -w
#
# 20100721, 20120527 
# prototype for extracting text from 'unknown' mbp files
# based on B0******HU_EBOK.mbp
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

	my ($byte, $i, $counter, $buffer, $read, $STATE, $string, $previous_string);
	my @notes;
	my $LEGIBLE_LIMIT=5;
	my $BLOCK=1024;
	###

	my ($self) = @_;

	open fIn, '<', $self->{FILE_NAME} || (
			$self->{ERROR}="Can't open file!",
			return 0
		);
	binmode fIn;
	###

	$counter=$STATE=0;
	$string=$previous_string='';
	# STATE: 0 (binary) -> 1 (legible text) -> 2 (end of text) -> 0
	while ( $read=read (fIn, $buffer, $BLOCK) ) {
		$i=0;
		while ( $i<$read ) {

			$byte=substr($buffer,$i,1);
			$i++;

			if ( $STATE<2 && (ord($byte)>=32 && ord($byte)<255) ) {
				$counter++;
				$string.=$byte;
			} elsif ( ord($byte)<32 || ord($byte)>=255 ) {
				if ($STATE==1) {
					$counter=-1;
				} else {
					$counter=0;
					$previous_string=$string;
					$string='';
				}
			}

			if ( $counter>=$LEGIBLE_LIMIT ) {
				$STATE=1;
			} elsif ( $counter<0 && $STATE==1) {
				$STATE=2;
			}

			if ( $STATE==2 ) {
				if (length($previous_string)==1 && $previous_string eq substr($string,0,1)) {
					$string=substr($string,1);
				}
				if (length($string)>=$LEGIBLE_LIMIT) {
					push @notes, $string;
				}
				$STATE=0;
				$counter=0;
				$string='';
			}

		}
	}

	$self->{NOTES}=\@notes;
	return 1;
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