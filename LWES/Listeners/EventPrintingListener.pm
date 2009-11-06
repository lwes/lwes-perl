package LWES::Listeners::EventPrintingListener;

use strict;

use LWES::Listener;

@LWES::Listeners::EventPrintingListener::ISA =
  qw(LWES::Listener);

sub processEvent {
  my $self  = shift;
  my $event = shift;

  print("$event->{'EventType'}\n{");
  foreach my $key (sort(keys(%{$event}))) {
    next if $key eq "EventType";
    my $value = $event->{$key};
    print("\t",$key," = ",$value,";\n");
  }
  print("}\n");
}

1;
