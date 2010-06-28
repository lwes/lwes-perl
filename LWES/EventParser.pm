package LWES::EventParser;

use strict;
use Encode;
use Math::BigInt;

require Exporter;
@LWES::EventParser::ISA = qw(Exporter);

our @EXPORT = qw(bytesToEvent bytesToHeader getProcessEventFunc);

# This package will take a string which a raw event off the wire, or the
# payload of an event out of a journal, and turn it into a Perl hash.
#
# Note this is much slower than the listener in the C library, and that
# is recommended if you are concerned about performance.
#
# Typically this can be used if you want to quickly inspect some of the
# events on the network with a simple script.

# modules need to be alphanumeric segments separated by ::, if we don't
# see that we will assume its code to be run
sub is_module_name
{
  my $module = shift;
  if ($module =~ m/::$/)
    {
      return 0;
    }
  foreach my $s (split /::/, $module)
    {
      return 0 if ($s !~ m/^(\w+)$/ );
    }
  return 1;
}

# either instantiate a listener object given the module name, and return
# its processEvent function, or create a processEvent function from a code
# snippet and return it
sub getProcessEventFunc
{
  my $listener_or_code = shift;
  my $func = undef;
  if (is_module_name ($listener_or_code))
    {
      # Load the module and create an instance
      eval "use $listener_or_code;";
      if ($@)
        {
          $listener_or_code = "LWES::Listeners::$listener_or_code";
          eval "use $listener_or_code;";
          if ($@)
            {
              die "can't find $listener_or_code ($@)";
            }
        }

      my $listener_object = $listener_or_code->new(@_);
      $func = sub { $listener_object->processEvent (@_) };
    }
  else
    {
      my $func_str = "\$func = sub { my \$event = shift; $listener_or_code }";
      eval $func_str;
      if ($@)
        {
          die "can't create function '$func_str' ($@)";
        }
    }
  return $func;
}
# LWES returns 64 bit values as 2's complement hex which Math::BigInt
# then is treating as an unsigned value, so I first check the sign
# then if its positive I don't need to do anything, otherwise I mask
# off the sign bit, then subtract from the maximum and subtract one
# this seems to work out although isn't exactly what wikipedia describes
# but seemed to make sense when I played with it.
sub int64FromHex
{
  my $hex = shift;
  my $in           = Math::BigInt->new ($hex);
  my $signed_max   = Math::BigInt->new ("0x7FFFFFFFFFFFFFFF");
  my $sign_mask    = Math::BigInt->new ("0x8000000000000000");
  my $value;
  if ($in->copy()->band ($sign_mask) <= 0)
    {
      $value = $in;
    }
  else
    {
      $value = $in->copy()->band($signed_max)->bsub($signed_max) - 1;
    }
  return $value;
}

# grab slice of length 8 starting at offset 'o' and return as hex string
sub parse8ByteHex
{
  my $o = shift;
  return "0x". sprintf ("%02X"x8, @_[$o..$o + 8]);
}

# this function will parse journal headers into a hash structure
sub bytesToHeader {
  my $blob = shift;
  my $header = {};

  my @a = unpack ("C*", $blob);
  $header->{'PayloadLength'} = ($a[0] << 8) | $a[1];
  my $receipt_time = Math::BigInt->new (parse8ByteHex (2, @a));
  my ($secs, $mill) = $receipt_time->copy()->bdiv (1000);
  $header->{'ReceiptTime'}       = $receipt_time;
  $header->{'ReceiptTimeSecs'}   = $secs;
  $header->{'ReceiptTimeMillis'} = $mill;
  $header->{'SenderIP'}   = "$a[13].$a[12].$a[11].$a[10]";
  $header->{'SenderPort'} = ($a[14] << 8 ) | $a[15];
  $header->{'SiteID'}     = ($a[16] << 8 ) | $a[17];

  return $header;
}

sub bytesToEvent {
  my $blob = shift;

  my $event={};
  my @a=unpack('C*',$blob);
  my $i=0;

  my $length=($a[$i] & 0xff);
  $i+=1;
  my $event_type=substr($blob,$i,$length);
  $event->{'EventType'} = $event_type;

  $i+=$length;
  my $elements=($a[$i]<<8)|$a[$i+1];
  $i+=2;

  my $key;
  my $value;
  for (my $j=0;$j<$elements;++$j) {
    $length=($a[$i] & 0xff);
    $i+=1;
    $key=substr($blob,$i,$length);
    $i+=$length;

    my$type=($a[$i] & 0xff);
    $i+=1;
    if (($type == 1) || ($type == 2)) {
      # int16
      $value=(($a[$i]<<8)|$a[$i+1])&0xffff;
      $i+=2;
    } elsif (($type == 3) || ($type == 4)) {
      # int32
      $value=($a[$i]<<24)|($a[$i+1]<<16)|($a[$i+2]<<8)|$a[$i+3];
      $i+=4;
    } elsif ($type == 5) {
      # String
      $length=(($a[$i]<<8)|$a[$i+1])&0xffff;
      $i+=2;
      if ( exists($event->{'enc'}) && $event->{'enc'} == 1 ) {
        $value=Encode::decode_utf8(substr($blob,$i,$length));
      } else {
        $value=substr($blob,$i,$length);
      }
      $i+=$length;
    } elsif ($type == 6) {
      $value=sprintf("%d.%d.%d.%d",$a[$i+3],$a[$i+2],$a[$i+1],$a[$i]);
      $i+=4;
    } elsif ($type == 7) {
      # easiest way to parse 64 bit int is using Math::BigInt, but
      # for int64 we need to do something special so have a special
      # function
      $value = int64FromHex (parse8ByteHex ($i,@a));
      $i+=8;
    } elsif ($type == 8) {
      # uint64 from hex string
      $value = Math::BigInt->new (parse8ByteHex ($i, @a));
      $i+=8;
    } elsif ($type == 9) {
      $value=($a[$i])?1:0;
      $i+=1;
    }
    $event->{$key}=$value;
  }
  return $event;
}

1;

