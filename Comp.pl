% Declare the symptoms predicate as dynamic
:- dynamic symptoms/2.

% Parkinson's Disease Staging in Prolog

% Stage 1: Mild symptoms affecting only one side
stage(1, person) :- symptoms(person, [tremor_left_side, mild_symptoms]).

% Stage 2: Symptoms affecting both sides or midline, daily tasks more difficult
stage(2, person) :- symptoms(person, [tremor_both_sides, rigidity, walking_problems]),
                    daily_tasks(person, difficult).

% Stage 3: Loss of balance, falls more common, independent life but restricted
stage(3, person) :- symptoms(person, [balance_loss, falls, worsening_motor_symptoms]),
                    able_to_live_independently(person).

% Stage 4: Severe disability, requires help for daily activities
stage(4, person) :- symptoms(person, [severe_disability, can_walk_with_aid]),
                    needs_help_for_activities(person).

% Stage 5: Most advanced, bedridden, requires constant care
stage(5, person) :- symptoms(person, [bedridden, requires_24hr_care]).

% Example facts (these might be given dynamically from the frontend or another source)
symptoms(person, [tremor_left_side, bedridden]).
daily_tasks(person, difficult).
