#!/usr/bin/perl 

use v5.18;
use AnyEvent;
use constant SECONDS_IN_MINUTE => 1;

my $cv = AnyEvent->condvar;

say '>> Кипятим воду...';
$cv->begin;
my $water = AnyEvent->timer( after => 5*SECONDS_IN_MINUTE, cb => sub {
    say '<< Вода закипела!';
    try_to_boil_potatoes();
} );

say '>> Чистим картошку...';
my $water = AnyEvent->timer( after => rand(7)*SECONDS_IN_MINUTE, cb => sub {
    say '<< Картошка почищена!';
    try_to_boil_potatoes();
} );

say '>> Нарезаем салат...';
$cv->begin;
my $salad = AnyEvent->timer( after => 6*SECONDS_IN_MINUTE, cb => sub {
    say '<< Салат нарезан!';
    say '>> Готовим соус...';
    my $sause; $sause = AnyEvent->timer( after => 12*SECONDS_IN_MINUTE,  cb => sub {
        undef $sause;
        say '<< Соус готов!';
        $cv->end;
    } );
} );

$cv->recv;

say 'Ужин готов, приятного аппетита!';

exit;

my $action_count = 0;
sub try_to_boil_potatoes {

    $action_count++;
    return if ($action_count < 2);

    say '>> Варим картошку...';
    my $potatoes; $potatoes = AnyEvent->timer( after => 10*SECONDS_IN_MINUTE, cb => sub {
        undef $potatoes;
        say '<< Картошка сварилась!';
        $cv->end;
    } );
}