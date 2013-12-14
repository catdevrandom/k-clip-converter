package MBP_User_Mark;
# This package models an "user mark" in a .MBP file,
# which are the files that store user added information to
# any of the file formats that "mobipocket reader" can read.
# So, a .MBP file associated to a (for example) .PRC book file,
# would contain annotations, corrections, drawings and marks
# made by the user on the .PRC content.
#
# public methods:
# $self = new ([$type])
# {$type|\%} = type_list ([$type])
# $type = type ([$type])
# $order = order ([$order])
# $index_order = index_order ([$index_order])
# {0|1} = DATA_insert (\%DATA)
# \@ = DATA_get
# BKMK_insert (\%BKMK)
# \$ = BKMK_get
#
#
# v0.2.d, 200906, by idleloop@yahoo.com
# http://www.angelfire.com/ego2/idleloop/
#
#
use strict;


#constructor
sub new {
	my ($class, $type) = @_;
	
    my $self = {
		TYPE		=> undef,	# type of object
		DATA		=> undef,	# DATA block modelling
        BKMK		=> undef,	# BKMK block modelling
		ORDER		=> undef,	# number of order of the object in the book.
								# (order in index table is reversed for DATA 
								# block groups; BKMK blocks, however, do 
								# follow book order).
		INDEX_ORDER	=> undef,	# number of order of the object in 
								# the index table
	};
	bless $self, $class;	#'MBP_User_Mark';

	if (defined $type) {
		if ( !($self->type($type)) ) {
			return; # passed type not valid!
		}
	}

    return $self;
}


# consults possible object types,
# or obtains string/number or number/string correspondence.
sub type_list {
	my ($self, $type) = @_;
	my %TYPE_LIST=(
		'BPAR'		=>1,
		'FINAL_DATA'=>2,
		#::type_list::
		'NOTE'		=>10,
		'MARK'		=>11,
		'CORRECTION'=>12,
		'DRAWING'	=>13,
		'BOOKMARK'	=>14,
		'CATEGORY'	=>15, # CATE has no BKMK associated.
		'AUTHOR'	=>16, # AUTH has no BKMK associated.
		'TITLE'		=>17, # TITL has no BKMK associated.
		'GENRE'		=>18, # GENR has no BKMK associated.
		'ABSTRACT'	=>19, # ABST has no BKMK associated.
		'COVER'		=>20, # COVE has no BKMK associated.
		'PUBLISHER'	=>21, # PUBL has no BKMK associated.
		'EMPTY_DATA'=>22, # 20090622. Empty (zero length) DATA's can exist out there...
		# (Any objetc type addition here may modify also 
		# other '#::type_list::' marked code blocks: check them!).
		#
		# As there may be lots of other object types here:
		'UNKNOWN'	=>99, # this one is a wildcard for unknown objects.
	);
	my %TYPE_LIST_INVERTED=map { $TYPE_LIST{$_} => $_ } keys %TYPE_LIST;
	if (defined $type and $type=~/^[A-Z_]+$/) {
		if (defined $TYPE_LIST{$type}) {
			return $TYPE_LIST{$type};
		}
	} elsif (defined $type and $type=~/^\d+$/) {
		if (defined $TYPE_LIST_INVERTED{$type}) {
			return $TYPE_LIST_INVERTED{$type};
		}
	} else {
		return \%TYPE_LIST;
	}
}


# returns object type, 
# or sets type.
sub type {
	my ($self, $type) = @_;
	if (defined $type && $type=~/^\d+$/) {
		#$self->{TYPE}=$type;
		#return $self->{TYPE};
		if ($self->type_list($type)=~/^\w+$/) {
			$self->{TYPE}=
				$self->type_list($type);
			return $self->{TYPE};
		}
	} elsif (defined $type && $type=~/^\w+$/) {
		#if ($self->type_list($type)=~/^\d+$/) {
		#	$self->{TYPE}=
		#		$self->type_list($type);
		#	return $self->{TYPE};
		#}
		$self->{TYPE}=$type;
		return $self->{TYPE};
	} elsif (!defined $type){
		return $self->{TYPE};
	} else {
		return 0;
	}
}


# returns order of this objet in index table,
# or sets it.
sub order {
	my ($self, $order) = @_;
	if (defined $order && $order=~/^\d+$/) {
		$self->{ORDER}=$order;
		return $self->{ORDER};
	} else {
		return $self->{ORDER};
	}
}


# returns order of this objet in index table,
# or sets it.
sub index_order {
	my ($self, $index_order) = @_;
	if (defined $index_order && $index_order=~/^\d+$/) {
		$self->{INDEX_ORDER}=$index_order;
		return $self->{INDEX_ORDER};
	} else {
		return $self->{INDEX_ORDER};
	}
}


# inserts a new DATA block associated to this object.
sub DATA_insert {
	my ($self, $DATA) = @_;
	if (defined $DATA) {
		# a pair of checks before inserting this DATA block:
		if (defined $self->{TYPE}) {
			my $number_of_DATAs=0;
			$number_of_DATAs = ($#{$self->{DATA}} + 1) 
				if (defined $self->{DATA});
			my $type=$self->type_list($self->{TYPE});
			if ($type =~ /^(NOTE|CORRECTION)$/) {
				if ($number_of_DATAs>=3) { # NOTE and CORRECTION have <3 DATA blocks
					return 0;
				}
			} elsif ($type =~ /^(MARK|DRAWING)$/) {
				if ($number_of_DATAs>=2) { # MARK and DRAWING have <2 DATA blocks
					return 0;
				}
			}
		}
		# $self->{DATA} is a reference to 
		# an array of references to DATA objects.
		push @{$self->{DATA}}, $DATA;
		return 1;
	}
}



# returns a reference to the array of 
# DATA blocks associated to this object.
sub DATA_get {
	my ($self) = @_;
	# $self->{DATA} is a reference to 
	# an array of references to DATA objects.
	return \@{$self->{DATA}};
}


# inserts a new BKMK block associated to this object.
sub BKMK_insert {
	my ($self, $BKMK) = @_;
	if (defined $BKMK) {
		# there is only one BKMK per object.
		$self->{BKMK}=$BKMK;
	}
}


# returns a reference to the BKMK block 
# associated to this object.
sub BKMK_get {
	my ($self) = @_;
	# there is only one BKMK per object.
	return $self->{BKMK};
}


1;