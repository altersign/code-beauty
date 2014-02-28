#!/usr/bin/perl

use v5.18;
use FindBin;
use lib "$FindBin::Bin/lib";
use constant SECONDS_IN_MINUTE => 1;

use Dish::Potato;
use Dish::Salad;

#$Class::StateMachine::debug = 1;
my $cv = AnyEvent->condvar;

my $potato = Dish::Potato->new({ cv => $cv });
$potato->on_start_cooking;

my $salad = Dish::Salad->new({ cv => $cv });
$salad->on_start_cooking;

$cv->recv;

say 'Ужин готов, приятного аппетита!';

exit;