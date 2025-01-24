% Disease profiles with their associated motor and non-motor symptoms along with weighted scores (symptom, probability)
disease('Parkinson s Disease', [(tremor, 0.9), (stiffness, 0.8), (bradykinesia, 0.95), (sleep_disturbance, 0.5), (depression, 0.4), (cognitive_impairment, 0.3)]).
disease('Progressive Supranuclear Palsy (PSP)', [(balance_issues, 0.9), (speech_difficulty, 0.7), (stiffness, 0.6), (dysphagia, 0.8), (vision_problems, 0.85)]).
disease('Multiple System Atrophy (MSA)', [(urinary_incontinence, 0.7), (postural_instability, 0.9), (bradykinesia, 0.8), (blood_pressure_variability, 0.75), (breathing_difficulties, 0.6)]).
disease('Corticobasal Degeneration (CBD)', [(cognitive_impairment, 0.8), (dystonia, 0.9), (asymmetric_motor_symptoms, 0.7), (apraxia, 0.85), (sensory_loss, 0.5)]).
disease('Essential Tremor', [(tremor, 1.0)]).
disease('Drug-Induced Parkinsonism', [(bradykinesia, 0.8), (tremor, 0.7), (rigidity, 0.6)]).
disease('Normal Pressure Hydrocephalus (NPH)', [(gait_disturbance, 0.7), (urinary_incontinence, 0.8), (cognitive_impairment, 0.6)]).
disease('Lewy Body Dementia', [(cognitive_impairment, 0.85), (hallucinations, 0.75), (sleep_disturbance, 0.5)]).

% Advice for each disease
advice('Parkinson s Disease', 'Engage in regular physical exercise, follow prescribed dopaminergic medication, and seek support for managing sleep disturbances and depression.').
advice('Progressive Supranuclear Palsy (PSP)', 'Consult a neurologist for tailored therapy, manage dysphagia with a speech therapist, and address vision problems with regular checkups.').
advice('Multiple System Atrophy (MSA)', 'Collaborate with specialists to manage autonomic symptoms, including urinary incontinence and blood pressure variability.').
advice('Corticobasal Degeneration (CBD)', 'Pursue occupational therapy to maintain independence and address specific symptoms like dystonia or apraxia.').
advice('Essential Tremor', 'Consider beta-blockers or anticonvulsants for tremor management; lifestyle adjustments may also help.').
advice('Drug-Induced Parkinsonism', 'Review and adjust medication under medical supervision; symptoms often resolve after stopping the triggering drug.').
advice('Normal Pressure Hydrocephalus (NPH)', 'Consult a neurologist for diagnostic imaging and consider surgical options like a shunt procedure.').
advice('Lewy Body Dementia', 'Manage cognitive symptoms with cholinesterase inhibitors and consult specialists for hallucinations and sleep disturbances.').

% Communication recommendations for each disease
communication('Parkinson s Disease', 'Communicate clearly and empathetically, allow time for responses, and involve carers in discussions.').
communication('Progressive Supranuclear Palsy (PSP)', 'Speak slowly, use simple language, and consider alternative communication methods as needed.').
communication('Multiple System Atrophy (MSA)', 'Ensure patients feel heard; address both motor and non-motor symptoms explicitly.').
communication('Corticobasal Degeneration (CBD)', 'Adopt a patient-centered approach, understanding the complexities of cognitive and motor symptoms.').
communication('Essential Tremor', 'Discuss symptom progression and treatment options openly, providing reassurance.').
communication('Drug-Induced Parkinsonism', 'Educate patients on potential medication side effects and involve them in treatment adjustments.').
communication('Normal Pressure Hydrocephalus (NPH)', 'Focus on explaining diagnostic and surgical procedures in a clear and supportive manner.').
communication('Lewy Body Dementia', 'Be sensitive to cognitive impairments, involve family in care plans, and address hallucinations calmly.').

% Parkinson's Disease Stages and Symptoms with Associated Weighted Scores
pd_stage('Stage One', [(tremor, 0.9), (posture_changes, 0.7), (walking_changes, 0.6), (facial_expression_changes, 0.5)]).
pd_stage('Stage Two', [(tremor, 0.9), (rigidity, 0.8), (bilateral_symptoms, 0.7), (walking_problems, 0.6), (poor_posture, 0.5)]).
pd_stage('Stage Three', [(loss_of_balance, 0.9), (falls, 0.8), (motor_symptom_worsening, 0.7), (moderate_disability, 0.6)]).
pd_stage('Stage Four', [(severe_disability, 0.9), (walking_with_aid, 0.8), (assistance_needed, 0.7)]).
pd_stage('Stage Five', [(bedridden, 0.9), (wheelchair_bound, 0.8), (around_the_clock_care, 0.7)]).

% Match score for diseases
match_score(Symptoms, Disease, Score) :-
    disease(Disease, DiseaseSymptoms),
    findall(Prob,
            (member((Symptom, Prob), DiseaseSymptoms), member(Symptom, Symptoms)),
            Probabilities),
    sum_list(Probabilities, Score).

% Determine the most probable disease
diagnose(Symptoms, BestDisease) :-
    findall(Score-Disease,
            (match_score(Symptoms, Disease, Score), Score > 0),
            Scores),
    (Scores == [] -> BestDisease = none; max_member(_-BestDisease, Scores)).

% Match score for PD stages
match_pd_stage(Symptoms, Stage, Score) :-
    pd_stage(Stage, StageSymptoms),
    findall(Prob,
            (member((Symptom, Prob), StageSymptoms), member(Symptom, Symptoms)),
            Probabilities),
    sum_list(Probabilities, Score).

% Determine the most probable PD stage
determine_pd_stage(Symptoms, BestStage) :-
    findall(Score-Stage,
            (match_pd_stage(Symptoms, Stage, Score), Score > 0),
            Scores),
    (Scores == [] -> BestStage = 'Unknown'; max_member(_-BestStage, Scores)).

% Get advice for a disease
get_advice(Disease, Advice) :-
    advice(Disease, Advice).

% Get communication tips for a disease
get_communication_tips(Disease, Tips) :-
    communication(Disease, Tips).

% Combine diagnosis and stage determination
diagnose_and_stage(Symptoms, Disease, Stage) :-
    diagnose(Symptoms, Disease),
    (Disease == 'Parkinson s Disease' ->
        determine_pd_stage(Symptoms, Stage);
        Stage = 'Not Applicable').
