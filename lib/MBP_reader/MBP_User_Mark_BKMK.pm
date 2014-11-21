package MBP_User_Mark_BKMK;
# This package models a BKMK block associated to one particular 
# "user mark" in a .MBP file.
# which are the files that store user added information to
# any of the file formats that "mobipocket reader" can read.
# So, a .MBP file associated to a (for example) .PRC book file,
# would contain annotations, corrections, drawings and marks
# made by the user on the .PRC content.
#
# public methods:
# new ([$BKMK])
# index_pointer ([$index_pointer])
# BKMK ($BKMK)
# $color = color ([$color])
#
#
# v0.2.a, 200804, by idleloop@yahoo.com
# http://www.angelfire.com/ego2/idleloop/
#
#
use strict;


#constructor
sub new {
	my ($class) = shift;
    my $self = {
		# BKMK block modelling
		BKMK		=> shift,
		# BKMK block index table pointer
        BKMK_index	=> undef,
		# BKMK block position in MBP file
		BKMK_position			=> undef,
		# BKMK block index table position in MBP file's 
		BKMK_index_posititon	=> undef,
		# index data associated to this BKMK block, in MBP file's index table 
		BKMK_index_data			=> undef,
		# associated color, if any (background in a drawing, for example)
		BKMK_color				=> undef,

	};
    bless $self, $class;	#'MBP_User_Mark_BKMK';
    return $self;
}


# returns index of this objet in index table,
# or sets it.
sub index_pointer {
	my ($self, $index_pointer) = @_;
	if (defined $index_pointer) {
		$self->{BKMK_index}=$index_pointer;
	} else {
		return $self->{BKMK_index};
	}
}


# returns the BKMK block associated to this BKMK object,
# or sets it.
sub BKMK {
	my ($self, $BKMK) = @_;
	if (defined $BKMK) {
		$self->{BKMK}=$BKMK;
	} else {
		return $self->{BKMK};
	}
}


# returns color associated to this BKMK object,
# or sets it (does not change nor consult ->BKMK raw data!)
sub color {
	my ($self, $color) = @_;
	if (defined $color) {
		$self->{BKMK_color}=$color;
	} else {
		return $self->{BKMK_color};
	}
}

1;