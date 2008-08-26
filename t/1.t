#!perl

use strict;
use warnings;

use Test::More tests => 3;

use_ok( 'LWES' );

my $emitter = LWES::create_emitter("224.1.1.1",0,9999,0,60);
isnt($emitter, undef, "Emitter created");

my $event = LWES::create_event(undef, "TestEvent");
isnt($event, undef, "Event created");

LWES::set_string($event, "Test1", "Test1");
LWES::set_uint64($event, "Test2", 11111111111111);
LWES::set_int64($event, "Test3", 22222222222222);
LWES::emit(undef, undef);
LWES::emit($emitter, $event);

LWES::destroy_event($event);
LWES::destroy_emitter($emitter);


1;

