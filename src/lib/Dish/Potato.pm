package Dish::Potato;

use v5.18;
use AnyEvent;

use parent 'Class::StateMachine';

use Class::StateMachine::Declarative 

    __any__ => {
        before => {
            on_water_is_boiling => sub { say '<< Вода закипела!'; },
            on_potato_cleaned => sub { say '<< Картошка почищена!'; }
        },
    },
    
    raw => {
        transitions => {
            on_start_cooking => 'cooking_started'
        }
    },

    cooking_started => {
        enter => 'start_cooking',
        transitions => {
            on_water_is_boiling => 'water_is_boiling',
            on_potato_cleaned => 'potato_cleaned',
        },
    },

    water_is_boiling => {
        transitions => {
            on_potato_cleaned => 'potato_is_boiling',
        }
    },

    potato_cleaned => {
        transitions => {
            on_water_is_boiling => 'potato_is_boiling',
        }
    },

    potato_is_boiling => {
        enter => 'drop_potatoes',
        transitions => {
            on_potato_ready => 'potato_ready'
        }
    },

    potato_ready => {
        jump => 'ready'
    },

    ready => { enter => 'send_signal' };


sub new {
    my $class = shift;
    my $self = shift;

    return Class::StateMachine::bless $self, $class, 'raw';
}


sub start_cooking {
    my $self = shift;

    $self->{cv}->begin;

    $self->boil_water;
    $self->clear_potatoes;
}


sub boil_water {
    my $self = shift;

    say '>> Кипятим воду...';

    $self->{water} = AnyEvent->timer( after => 5*::SECONDS_IN_MINUTE, cb => sub {
        undef $self->{water};
        $self->on_water_is_boiling;
    } );
}


sub clear_potatoes {
    my $self = shift;

    say '>> Чистим картошку...';

    $self->{potatoes} = AnyEvent->timer( after => rand(7)*::SECONDS_IN_MINUTE, cb => sub {
        undef $self->{potatoes};
        $self->on_potato_cleaned;
    } );
}


sub drop_potatoes {
    my $self = shift;

    say '>> Варим картошку...';

    $self->{potatoes} = AnyEvent->timer( after => 10*::SECONDS_IN_MINUTE, cb => sub {
        undef $self->{potatoes};
        $self->on_potato_ready;
    } );
}


sub send_signal {
    my $self = shift;

    say '<< Картошка сварилась!';

    $self->{cv}->end;
}

1;

