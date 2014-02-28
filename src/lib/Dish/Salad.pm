package Dish::Salad;

use v5.18;
use AnyEvent;

use parent 'Class::StateMachine';

use Class::StateMachine::Declarative 

    __any__ => {
        before => {
            on_salad_sliced => sub { say '<< Салат нарезан!' },
            on_sause_ready => sub { say '<< Соус готов!' }
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
            on_salad_sliced => 'salad_sliced',
        },
    },

    salad_sliced => {
        enter => 'make_sause',
        transitions => {
            on_sause_ready => 'sause_ready',
        }
    },

    sause_ready => {
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

    $self->slice_salad;
}


sub slice_salad {
    my $self = shift;

    say '>> Нарезаем салат...';

    $self->{salad} = AnyEvent->timer( after => 6*::SECONDS_IN_MINUTE, cb => sub {
        undef $self->{salad};
        $self->on_salad_sliced;
    } );
}


sub make_sause {
    my $self = shift;

    say '>> Готовим соус...';

    $self->{sause} = AnyEvent->timer( after => 10*::SECONDS_IN_MINUTE, cb => sub {
        undef $self->{sause};
        $self->on_sause_ready;
    } );
}


sub send_signal {
    my $self = shift;

    say '<< Салат готов!';

    $self->{cv}->end;
}

1;

