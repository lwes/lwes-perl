package LWES::Listener;

#############################################################
# Base Class for listeners
#############################################################
use strict;

# Constructor for all
sub new {
  my $class = shift;
  $class = ref ( $class ) || $class;
  my $self = bless ({}, $class);
  $self -> {'class_def'} = $class."(".join(",",@_).")";
  $self -> initialize (@_);
  return $self;
}

#############################################################
# Fill out this method if you need to initialize things
#############################################################
sub initialize { }

#############################################################
# Fill out this method to do stuff with each event
#############################################################
sub processEvent  {}

1;
