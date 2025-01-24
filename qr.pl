:- dynamic user_response/3.
:- dynamic symptom_count/1.
:- dynamic last_asked/1.

% Initialize
last_asked(0).
symptom_count(0).

% Questions
question(1, "Have you been getting slower in your usual daily activities?", movement_symptom, slowness_in_daily_activities).
question(2, "Is your handwriting smaller?", movement_symptom, small_handwriting).
question(3, "Is your speech slurred or softer?", non_movement_symptom, slurred_speech).
question(4, "Do you have trouble rising from a chair?", movement_symptom, difficulty_rising_from_chair).
question(5, "Do your lips, hands, arms and/or legs shake?", movement_symptom, tremors).
question(6, "Have you noticed more stiffness in your body?", movement_symptom, stiffness).
question(7, "Do you have trouble fastening buttons or dressing?", movement_symptom, difficulty_dressing).
question(8, "Do you shuffle your feet and/or take smaller steps when you walk?", movement_symptom, shuffling_feet).
question(9, "Do your feet seem to get stuck to the floor when walking or turning?", movement_symptom, freezing_gait).
question(10, "Have you or others noticed that you don't swing one arm when walking?", movement_symptom, reduced_arm_swing).
question(11, "Do you have more trouble with your balance?", movement_symptom, balance_trouble).
question(12, "Have you or others noticed that you stoop or have abnormal posture?", movement_symptom, abnormal_posture).

% Update symptom count
update_symptom_count(Response) :-
    (   Response == yes
    ->  symptom_count(Count),
        NewCount is Count + 1,
        retractall(symptom_count(Count)),
        assert(symptom_count(NewCount))
    ;   true).

% Diagnosis based on symptom count
diagnose(Diagnosis) :-
    symptom_count(Count),
    determine_risk(Count, Diagnosis).

determine_risk(0, "Low risk. Consult a doctor if your symptoms persist or worsen.").
determine_risk(1, "Low risk. Talk to a doctor if you notice changes in your quality of life.").
determine_risk(2, "Moderate risk. Consider seeing a movement disorder specialist.").
determine_risk(3, "High risk. A medical evaluation is strongly recommended.").
determine_risk(Count, "Very high risk. Consult a specialist as soon as possible.") :- Count > 3.

% Get next question or diagnosis
next_question(QuestionText) :-
    last_asked(LastQuestion),
    NextQuestion is LastQuestion + 1,
    (   question(NextQuestion, QuestionText, _, _)
    ->  retractall(last_asked(_)),
        assert(last_asked(NextQuestion))
    ;   QuestionText = "No more questions. Please proceed with the diagnosis.").

% Record user response
record_response(QuestionID, Response) :-
    question(QuestionID, _, _, Symptom),
    (   Response == yes
    ->  retractall(user_response(QuestionID, _, _)),
        assert(user_response(QuestionID, yes, Symptom)),
        update_symptom_count(yes)
    ;   true).

% Reset the questionnaire
reset_questionnaire :-
    retractall(user_response(_, _, _)),
    retractall(last_asked(_)),
    retractall(symptom_count(_)),
    assert(last_asked(0)),
    assert(symptom_count(0)).