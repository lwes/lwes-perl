package LWES::Listeners::EventPrintingListener;

use strict;

use LWES::Listener;

@LWES::Listeners::EventPrintingListener::ISA =
  qw(LWES::Listener);

sub processEvent {
  my $self  = shift;
  my $event = shift;

  my $key_count = 0;
  foreach my $key (keys %{$event})
    {
      $key_count++ if $key ne "EventType";
    }

  print ($event->{'EventType'}."[$key_count]\n{\n");
  foreach my $key (sort(keys(%{$event})))
    {
      next if $key eq "EventType";
      my $value = $event->{$key};
      print("\t",$key," = ",$value,";\n");
    }
  print("}\n");
}

1;
