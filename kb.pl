% Parkinson's Disease Knowledge Base

% 1. Symptoms of Parkinson's Disease
% Motor Symptoms
symptom(tremors, "Rhythmic shaking of hands, arms, legs, or head").
symptom(rigidity, "Muscle stiffness that limits smooth movements").
symptom(bradykinesia, "Slowness of movement, difficulty initiating movement").
symptom(balance_problems, "Difficulty maintaining balance and walking").
symptom(slow_movement, "Slower and less fluid movements").
symptom(difficulty_writing, "Difficulty writing legibly, small handwriting (micrographia)").
symptom(speech_difficulties, "Speech problems, soft voice, rapid or slow speech").
symptom(facial_expressions_flattened, "Lack of facial expressions, mask-like face").

% Non-Motor Symptoms
symptom(constipation, "Frequent bowel problems, difficulty passing stool").
symptom(sleep_disorders, "Sleep disturbances, excessive daytime sleepiness, insomnia").
symptom(depression, "Feelings of sadness, anxiety, loss of interest in activities").
symptom(cognitive_decline, "Memory loss, difficulty concentrating, cognitive problems").
symptom(urinary_trouble, "Urinary problems, such as incontinence or frequent urination").
symptom(low_blood_pressure, "Hypotension, dizziness, or fainting when standing").
symptom(pain, "Muscle or joint pain, often related to rigidity or slow movement").
symptom(dizziness, "Vertigo, often due to orthostatic hypotension").

% 2. Medications for Treating Parkinson's Disease
medication(levodopa, "Primary drug for treating motor symptoms. Side effects: nausea, movement disorders").
medication(dopamine_agonists, "Mimics dopamine, stimulates dopamine receptors. Side effects: drowsiness, hallucinations").
medication(maoi_inhibitors, "Monoamine oxidase inhibitors to reduce motor symptoms. Side effects: headaches, insomnia").
medication(anticholinergics, "Reduces tremors and rigidity. Side effects: dry mouth, blurred vision").
medication(comt_inhibitors, "Extends the effects of levodopa. Side effects: diarrhea, abdominal pain").

% 3. Medication Interactions
interaction(levodopa, dopamine_agonists, "May enhance drug effects but risk involuntary movements").
interaction(maoi_inhibitors, levodopa, "May interact with levodopa, requiring close medical supervision").
interaction(comt_inhibitors, levodopa, "Prolongs the effect of levodopa, but watch for side effects").

% 4. Recommended Exercises for Parkinson's Patients
exercise(walking, "Regular walking at a moderate pace to improve balance and mobility").
exercise(tai_chi, "Slow, controlled exercises that improve balance and coordination").
exercise(stretching, "Daily stretches to maintain muscle and joint flexibility").
exercise(swimming, "Swimming relieves joint pressure while strengthening muscles").
exercise(cycling, "Cycling improves coordination, balance, and leg strength").
exercise(yoga, "Yoga enhances flexibility, relaxation, and reduces stress").
exercise(resistance_training, "Weight-based exercises to strengthen muscles and improve posture").


% 5. Recommended Diets
nutrition(mind_diet, "Diet combining Mediterranean and DASH aspects to protect brain health").
nutrition(mediterranean_diet, "Diet rich in olive oil, fish, fruits, vegetables, and whole grains").
nutrition(vegetables, "Consume fresh vegetables rich in fiber, vitamins, and antioxidants").
nutrition(fish, "Eat fatty fish rich in omega-3s to protect brain health").
nutrition(whole_grains, "Whole grains improve digestion and heart health").
nutrition(fiber, "Consume fibers to help prevent constipation").
nutrition(avoid_red_meat, "Reduce red meat and saturated fats to minimize inflammation").

% 6. Parkinson's Disease Risk Factors
genetic_risk(family_history, "Close family members with Parkinson's increase risk. Children and siblings have a 4% risk").
environmental_risk(pesticides, "Exposure to pesticides increases Parkinson's risk").
environmental_risk(head_injuries, "Head trauma increases the risk of Parkinson's").

% 7. Disease Progression
progression(slow, "Parkinson's disease progresses slowly, with changes over years").
progression(fast, "Rapid progression may occur in some cases, especially with factors like depression or inactivity").

% 8. Symptom Treatment Rules
treats_symptom(tremors, levodopa).
treats_symptom(rigidity, dopamine_agonists).
treats_symptom(bradykinesia, levodopa).
treats_symptom(balance_problems, exercise(tai_chi)).
treats_symptom(slow_movement, levodopa).
treats_symptom(difficulty_writing, exercise(stretching)).
treats_symptom(speech_difficulties, exercise(yoga)).
treats_symptom(facial_expressions_flattened, exercise(tai_chi)).

% 9. Dietary Advice for Medications
diet_advice(levodopa, "Avoid high-protein meals before taking levodopa to improve absorption").
diet_advice(mind_diet, "Follow the MIND diet for long-term brain health").

% 10. Rules for Evaluating Disease Progression Based on Factors
predict_progression(_) :-
    (environmental_risk(_, _); genetic_risk(_, _)),
    progression(fast),
    write("The disease progression might be fast. Monitor symptoms closely and consult your doctor regularly.").

predict_progression(_) :-
    progression(slow),
    write("The disease progression is slow. Regular monitoring is recommended.").

% 11. Questions to Ask Your Doctor
questions_to_ask_doctor :-
    write("1. How do you know I have Parkinson's disease? Do I need more tests?\n"),
    write("2. What caused my Parkinson's disease?\n"),
    write("3. What are the options for managing non-motor symptoms?\n"),
    write("4. Will I need medications to treat my symptoms?\n"),
    write("5. Is exercise important? What type of exercise should I do?\n"),
    write("6. What diet do you recommend for me?\n"),
    write("7. Are my children or siblings at risk of developing Parkinson's disease?\n"),
    write("8. How fast will my disease progress?\n"),
    write("9. Are there other people with Parkinson's disease I can talk to?\n").

% 12. Recommendations for Specific Symptoms
recommend_symptoms(Symptom) :-
    symptom(Symptom, Description),
    write("Symptom: "), write(Symptom), nl,
    write("Description: "), write(Description), nl.

% 13. Dynamic Response System
response('What are the motor symptoms of Parkinson\'s disease?', 
         "Motor symptoms include tremors, rigidity, bradykinesia, balance problems, and slow movements.").

response('What medications are available to treat Parkinson\'s disease?', 
         "Medications include levodopa, dopamine agonists, MAO-B inhibitors, anticholinergics, and COMT inhibitors.").

response('What exercises are recommended for Parkinson\'s patients?', 
         "Recommended exercises include walking, Tai Chi, stretching, swimming, yoga, and resistance training.").

response('What should I do for tremors?', 
         "Tremors can be managed with levodopa. Relaxation exercises like yoga can also help.").

response(Question, Response) :-
    symptom(Symptom, Description),
    atom_concat('Tell me about ', Symptom, Question),
    atom_concat("Symptom: ", Description, Response).

response('What questions should I ask my doctor?', 
         "You can ask questions such as: What treatments are available? How will the disease progress? What are my options for managing symptoms?").