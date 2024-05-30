use 5.38.0;
use warnings;

use experimental qw(builtin);

use Object::Pad;

# A quest Q = 〈T, ≤, R〉is a partially ordered set of tasks T that the player
# must complete to get one or more rewards from a set R.

class Quest {
    has $name :param;
    has $description :param;

    has $tasks :param = [];

    method tasks () { @$tasks }

    method rewards() {
        map { $_->rewards() } @$tasks;
    }
}

# A reward r ∈ R is an in-game item, narrative elements, or progression
# elements.

class Reward {
    method award($player) {...}
}

# A task t ∈ T is a 4-tuple 〈C, M, I, Rt〉, where C is the condition that must
# be made true in order to complete the task, M is the system that monitors the
# sub-section of the game state that is required to make C true, I is the
# presentation of the quest, and Rt ⊆ R is the set of rewards that is given to
# the player when C is true

class Task {
    # C is the condition that must be made true in order to complete the task
    field $goal :param

    # M is the system that montiors the sub-section of the gamestate that is
    # required to make C true
    has $monitor :param;
    method add_monitor($callback) { $callback->($goal($self)) }

    # I is the presentation of the quest
    field $description :param;
    method description() { $description }

    field $rewards :param = [];
    method rewards() { @$rewards }
}

my $marked_for_death = Quest->new(
    name => 'Marked for Death',
    description => "someone wants a character dead, you must save them",
    tasks => [
        Task->new(
            name       => 'prevent someone from dying',
            descrption => 'save {{target}} from {{opponent}}',
            goal       => sub {
                state $target   = lookup_on_who_table();
                state $opponent = lookup_on_opposition_table();

                return builtin::true if $target->not_dead && $opponent->dead;
            }
        ),
    ],
);

my $blackmail = Quest->new(
    name => 'Black Mail',
    description => 'A character is blackmailed by an enemy'
    tasks => [
        Task->new(
            name => 'do what the blackmailer wants',
            description => '{{employer}} wants you to {{job}}'
            goal => sub {
                state $job = lookup_on_opposition_table();
                state $employer = lookup_on_opposition_table();

                return builtin::true if $job->done;
        )
    ]
);
