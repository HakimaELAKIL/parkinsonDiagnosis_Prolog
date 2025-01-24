% --- FACTEURS DE RISQUE ---
facteur_risque('mutation_alpha_synucleine', prob=0.8).
facteur_risque('mutation_LRRK2', prob=0.7).
facteur_risque('exposition_pesticides', prob=0.5).
facteur_risque('age_superieur_60', prob=0.9).
facteur_risque('historique_familial', prob=0.6).

% --- CAUSES ---
cause('perte_neurones_dopaminergiques', prob_base=0.5).
cause('formation_corps_lewy', prob_base=0.4).

% --- RELATIONS FACTEURS-CAUSES ---
relation_facteur_cause('mutation_alpha_synucleine', 'perte_neurones_dopaminergiques', effet=0.3).
relation_facteur_cause('exposition_pesticides', 'perte_neurones_dopaminergiques', effet=0.2).
relation_facteur_cause('age_superieur_60', 'perte_neurones_dopaminergiques', effet=0.4).
relation_facteur_cause('exposition_pesticides', 'formation_corps_lewy', effet=0.35).
relation_facteur_cause('mutation_alpha_synucleine', 'formation_corps_lewy', effet=0.25).

% --- SYMPTÔMES ---
symptome('perte_neurones_dopaminergiques', 'bradykinesie', poids=0.8).
symptome('formation_corps_lewy', 'trouble_sommeil_REM', poids=0.7).

% Updated predicate to only print the risk score as a plain number
diagnose_and_calculate_risk(Symptoms, Factors, RisqueGlobal) :-
    assert_observations(Symptoms),
    assert_factors(Factors),
    (   risque_maladie(parkinson, RisqueGlobal)
    ->  true
    ;   RisqueGlobal = 0  % Default risk if no diagnosis is found
    ),
    retract_observations,
    retract_factors,
    % Print only the calculated risk for easy extraction
    format('~2f~n', [RisqueGlobal]).


% Calcul des risques basé sur les facteurs et les symptômes
risque_cause(Cause, RisqueAjuste) :-
    cause(Cause, prob_base=ProbBase),
    findall(EffetFacteur, (
        relation_facteur_cause(Facteur, Cause, effet=Effet),
        facteur_risque(Facteur, prob=ProbFacteur),
        EffetFacteur is Effet * ProbFacteur
    ), EffetsFacteurs),
    sumlist(EffetsFacteurs, TotalEffet),
    RisqueAjuste is ProbBase + TotalEffet.

risque_cause_avec_symptomes(Cause, RisqueFinal) :-
    risque_cause(Cause, RisqueAjuste),
    findall(PoidsSymptome, (
        symptome(Cause, Symptome, poids=PoidsSymptome),
        observation(Symptome)
    ), PoidsSymptomes),
    sumlist(PoidsSymptomes, TotalSymptomes),
    RisqueFinal is RisqueAjuste + TotalSymptomes.

risque_maladie(Maladie, RisqueGlobal) :-
    findall(RisqueCause, (
        cause(Cause, _),
        relation_facteur_cause(_, Cause, _),
        risque_cause_avec_symptomes(Cause, RisqueCause)
    ), RisquesCauses),
    sumlist(RisquesCauses, TotalRisque),
    length(RisquesCauses, Count),
    RisqueGlobal is TotalRisque / Count.

% Gestion des observations dynamiques
assert_observations([]).
assert_observations([Symptome|Rest]) :-
    assertz(observation(Symptome)),
    assert_observations(Rest).

assert_factors([]).
assert_factors([Facteur|Rest]) :-
    assertz(facteur_risque(Facteur)),
    assert_factors(Rest).

retract_observations :-
    retractall(observation(_)).

retract_factors :-
    retractall(facteur_risque(_)).