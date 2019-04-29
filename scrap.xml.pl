#!/usr/bin/env perl
# Time-stamp: <2019-04-29 15:22:30 daniel>
# Version: 1.03

# A perl script to scrap data from XML and reform it


# Examples
#
# 1. Input
#   <unitgroup name="cond_br">
#     <unitset><unit name="jeu0" primary=""/>
#     <unit name="alu2" coupled=""/></unitset>
#     <unitset><unit name="jeu1" primary=""/>
#     <unit name="alu3" coupled=""/></unitset>
#   </unitgroup>

# output:
# unitgroup=cond_br: primary=jeu0; coupled=alu2
# unitgroup=cond_br: primary=jeu1; coupled=alu3


# 2. Input
#   <unitgroup name="fpu">
#     <unitset><unit name="fpu0" primary=""/></unitset>
#     <unitset><unit name="fpu1" primary=""/></unitset>
#   </unitgroup>

# Output:
# unitgroup=fpu: primary=fpu0
# unitgroup=fpu: primary=fpu1


# Required modules
#------------------------------------------------------------------------------
use strict;  # police state
use XML::LibXML;  # parse XML data


##=============================================================================
package Unit;


# Wrap the attributes of this unit into the class object
# The type will be coupled if there is a coupled attribute.
# The type will be primary if there is no coupled attribute.
#------------------------------------------------------------------------------
sub constructor {

    my $self = shift;

    $self->{ name } = $self->{ group }->getAttribute( 'name' );
    $self->{ type } = 'primary';
    if ( $self->attribute( 'coupled' ) ) { $self->{ type } = 'coupled'; };

};  # end constructor


# Find a single attribute
#------------------------------------------------------------------------------
sub attribute {

    my ( $self, $attr ) = ( shift, shift );
    return $self->{ group }->getAttributeNode( $attr ) != undef;

};  # end attribute


# Format this object as a text string and return it
#------------------------------------------------------------------------------
sub as_string {

    my $self = shift;
    return ": $self->{ type }=$self->{ name }";

};  # end print


# unitset class constructor
#------------------------------------------------------------------------------
sub new {

    my $class = shift;
    my $self = { 'group' => shift };

    bless $self, $class;
    $self->constructor();
    return $self;

};  # end class unitset

1;  # end def of package UnitSet
#==============================================================================


# Find the name of the XML file on the command line or exit
#------------------------------------------------------------------------------
sub xml_filename {

    my $filename = join( ' ', @ARGV );
    if ( not length $filename ) {
        print "Missing filename on the command line!\n";
        exit -1;
    };  # end if $filename

    return $filename;

};  # end xml_filename


# print the data for each 'unitgroup' element
#------------------------------------------------------------------------------
sub main_sub {

    my $name = '';
    my $unit = '';
    my $output = '';

    my $dom = XML::LibXML->load_xml( location => xml_filename() );
    foreach my $group( $dom->findnodes( '/xml/unitgroups/unitgroup' ) ) {

        $name = $group->getAttribute( 'name' );
        print "unitgroup=$name";
        foreach ( $group->findnodes( 'unitset/unit' ) ) {
            $unit = new Unit( $_ );
            print $unit->as_string();
        };  # end for each unit
        print "\n";

    };  # end for each $group

};  # end main_sub


# Enter the script and start processing the data
#------------------------------------------------------------------------------
main_sub();   # start application
