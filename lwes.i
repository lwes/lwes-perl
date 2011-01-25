%module LWES

%{
#include "lwes.h"
%}

%include lwes.h

%inline %{

struct lwes_event_type_db *
create_db(char *filename)
{
  return lwes_event_type_db_create(filename);
}

int
destroy_db(struct lwes_event_type_db* db)
{
  return lwes_event_type_db_destroy(db);
}

struct lwes_emitter *
create_emitter(char *address, char *iface, int port,
               int emit_heartbeat, short freq)
{
  return lwes_emitter_create(address, iface, port, emit_heartbeat, freq);
}

struct lwes_emitter *
create_emitter_with_ttl(char *address, char *iface, int port,
                        int emit_heartbeat, short freq, int ttl)
{
  return lwes_emitter_create_with_ttl(address, iface, port, emit_heartbeat,
                                      freq, ttl);
}

int
emit(struct lwes_emitter *emitter, struct lwes_event *event)
{
  return lwes_emitter_emit(emitter, event);
}

int
emitto(char *address, char *iface, int port, struct lwes_emitter *emitter,
       struct lwes_event *event)
{
  return lwes_emitter_emitto(address, iface, port, emitter, event);
}

int
destroy_emitter(struct lwes_emitter *emitter)
{
  return lwes_emitter_destroy(emitter);
}

struct lwes_event *
create_event(struct lwes_event_type_db* db, char *event_name)
{
  return lwes_event_create(db, event_name);
}

struct lwes_event *
create_event_with_encoding(struct lwes_event_type_db *db, char *event_name,
                           short encoding)
{
  return lwes_event_create_with_encoding(db, event_name, encoding);
}

int
set_uint16(struct lwes_event *event, char *attribute_name,
           unsigned short a_uint16)
{
  return lwes_event_set_U_INT_16(event, attribute_name, a_uint16);
}

int
get_uint16(struct lwes_event* event, char* attribute_name,
           unsigned short *a_uint16)
{
  return lwes_event_get_U_INT_16(event, attribute_name, a_uint16);
}

int
set_int16(struct lwes_event* event, char* attribute_name,
          short an_int16)
{
  return lwes_event_set_INT_16(event, attribute_name, an_int16);
}

int
get_int16(struct lwes_event* event, char* attribute_name,
          short* an_int16)
{
  return lwes_event_get_INT_16(event, attribute_name, an_int16);
}

int
set_uint32(struct lwes_event* event, char* attribute_name,
           unsigned int a_uint32)
{
  return lwes_event_set_U_INT_32(event, attribute_name, a_uint32);
}

int
get_uint32(struct lwes_event* event, char* attribute_name,
           unsigned int * a_uint32)
{
  return lwes_event_get_U_INT_32(event, attribute_name, a_uint32);
}

int
set_int32(struct lwes_event* event, char* attribute_name,
          int an_int32)
{
  return lwes_event_set_INT_32(event, attribute_name, an_int32);
}

int
get_int32(struct lwes_event* event, char* attribute_name,
          int* an_int32)
{
  return lwes_event_get_INT_32(event, attribute_name, an_int32);
}

int
set_uint64(struct lwes_event* event, char* attribute_name,
           char* a_uint64)
{
  return lwes_event_set_U_INT_64_w_string(event, attribute_name, a_uint64);
}

int
get_uint64(struct lwes_event* event, char* attribute_name,
           unsigned long long * a_uint64)
{
  return lwes_event_get_U_INT_64(event, attribute_name, a_uint64);
}

int
set_int64(struct lwes_event* event, char* attribute_name,
          char* an_int64)
{
  return lwes_event_set_INT_64_w_string(event, attribute_name, an_int64);
}

int
get_int64(struct lwes_event* event, char* attribute_name,
          long long* an_int64)
{
  return lwes_event_get_INT_64(event, attribute_name, an_int64);
}

int
set_string(struct lwes_event* event, char* attribute_name,
           char* a_string)
{
  return lwes_event_set_STRING(event, attribute_name, a_string);
}

int
get_string(struct lwes_event* event, char* attribute_name,
           char** a_string)
{
  return lwes_event_get_STRING(event, attribute_name, a_string);
}

int
set_ip_addr(struct lwes_event* event, char* attribute_name,
            char* an_ip_addr)
{
  return lwes_event_set_IP_ADDR_w_string(event, attribute_name, an_ip_addr);
}

int
get_ip_addr(struct lwes_event *event, char *attribute_name,
            struct in_addr *an_ip_addr)
{
  return lwes_event_get_IP_ADDR(event, attribute_name, an_ip_addr);
}

int
set_boolean(struct lwes_event* event, char* attribute_name,
            int a_boolean)
{
  return lwes_event_set_BOOLEAN(event, attribute_name, a_boolean);
}

int
get_boolean(struct lwes_event *event, char *attribute_name,
            int *a_boolean)
{
  return lwes_event_get_BOOLEAN(event, attribute_name, a_boolean);
}

int
destroy_event(struct lwes_event *event)
{
  return lwes_event_destroy(event);
}

void
current_time_millis(char *buffer)
{
  LWES_INT_64 current_time = 0LL;
  current_time = currentTimeMillisLongLong();
  snprintf(buffer,17,"%016llX",current_time);
}

%}

%perlcode %{

=head1 NAME

LWES - Perl extension for the Light Weight Event System

=head1 SYNOPSIS

  use LWES;
  use LWES::EventParser;
  use IO::Socket::Multicast;

  my $LWES_ADDRESS = "224.1.1.1";
  my $LWES_PORT = 9000;

  # load an event schema from a file to validate events
  my $event_db = LWES::create_db("eventTypes.esf");

  # create an emitter for sending events
  my $emitter = LWES::create_emitter($LWES_ADDRESS, 0, $LWES_PORT, 0, 60);

  # create an event and validate it against the DB
  my $event = LWES::create_event($event_db, "MyEvent");

  # or create an unvalidated event
  my $event2 = LWES::create_event(undef, "MyOtherEvent");

  # set some fields
  LWES::set_string($event, "MyField", "MyValue");
  LWES::set_int32($event2, "MyNumber", 123);

  # emit the events
  LWES::emit($emitter, $event);
  LWES::emit($emitter, $event2);

  # listen to some events on the network
  my $socket = IO::Socket::Multicast->new(LocalPort => $LWES_PORT,
                                          Reuse     => 1);
  $socket->mcast_add($LWES_ADDRESS);
  my ($message, $peer);
  $peer = recv($socket, $message, 65535, 0);
  my ($port, $peeraddr) = sockaddr_in($peer);

  # deserialize the event into a perl hash
  my $event = bytesToEvent($message);

  # access the various event fields
  my $data = $event->{'MyField'}; 

  # cleanup
  LWES::destroy_event($event);
  LWES::destroy_emitter($emitter);
  LWES::destroy_db($event_db);

=head1 DESCRIPTION

This is the Perl interface to the Light Weight Event System.  The
Light Weight Event System is a UDP-based communication toolkit with
built-in serialization, formatting, and type-checking.

=head1 EXPORT

None by default.

=head1 AUTHOR

Anthony Molinaro, E<lt>molinaro@users.sourceforge.netE<gt>
Michael P. Lum, E<lt>mlum@users.sourceforge.netE<gt>

=head1 COPYRIGHT AND LICENSE

Portions Copyright (c) 2008, Yahoo! Inc. All rights reserved.
Portions Copyright (c) 2010, OpenX Inc. All rights reserved.

Licensed under the New BSD License (the "License"); you may not use
this file except in compliance with the License.  Unless required
by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. See accompanying LICENSE file.

=cut

%}

