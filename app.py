from flask import Flask, request, jsonify
from flask_cors import CORS
import subprocess
from pyswip import Prolog, registerForeign
import requests
from swiplserver import PrologMQI
import pyswip
import os
os.environ['PYTHONIOENCODING'] = 'utf-8'


app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "http://localhost:5173"}})

# @app.route('/calculate-risk', methods=['POST'])
# def calculate_risk():
#     data = request.json
#     symptoms = data.get('symptoms', [])
#     factors = data.get('factors', [])

#     try:
#         # Convertir les symptômes et facteurs en format Prolog
#         symptoms_str = ', '.join([f"'{symptom}'" for symptom in symptoms])
#         factors_str = ', '.join([f"'{factor}'" for factor in factors])

#         # Affichage pour débogage
#         print(f"Symptômes : {symptoms_str}")
#         print(f"Facteurs : {factors_str}")

#         # Exécuter le fichier Prolog existant avec les symptômes et facteurs
#         result = subprocess.run(
#             ['swipl', '-s', 'risk.pl', '-g', f"diagnose_and_calculate_risk([{symptoms_str}], [{factors_str}]).", '-t', 'halt'],
#             capture_output=True,
#             text=True
#         )

#         # Vérifier si l'exécution a échoué
#         if result.returncode != 0:
#             raise Exception(f"Erreur dans l'exécution de Prolog : {result.stderr}")

#         # Affichage de la sortie de Prolog pour débogage
#         print(f"Sortie Prolog : {result.stdout}")

#         # Retourner le résultat au client
#         return jsonify({"result": result.stdout})

#     except FileNotFoundError as e:
#         # Afficher une erreur si Prolog n'est pas trouvé
#         return jsonify({"error": "Exécutable Prolog introuvable. Assurez-vous que SWI-Prolog est installé et ajouté au PATH."}), 500
#     except Exception as e:
#         # Afficher l'erreur générique avec les détails
#         print(f"Erreur lors de l'exécution : {e}")  # Log dans la console pour débogage
#         return jsonify({"error": f"Une erreur s'est produite : {str(e)}"}), 500


# Initialize the Prolog engine
prolog3 = Prolog()

# Load your Prolog knowledge base
prolog3.consult("./stage.pl")

@app.route('/diagno', methods=['POST'])
def diagnosis():
    data = request.json
    disease_name = data.get('disease_name')

    try:
        result = list(prolog3.query(f"disease({disease_name}, MovementSymptoms, NonMovementSymptoms, Causes, Medication, Advices, Stage)"))
        if result:
            return jsonify(result[0])
        else:
            return jsonify({"error": "No match found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
# # Initialize Prolog
# prolog1 = Prolog()
# try:
#     # Load the Prolog file (assuming it's in the same directory)
#     prolog1.consult('./stage.pl')

#     print("Prolog knowledge base loaded successfully.")
# except Exception as e:
#     print(f"Error loading Prolog knowledge base: {e}")


# Initialize Prolog
prolog3 = Prolog()

# Load the Prolog file
prolog3.consult("Comp.pl")

# Function to check Parkinson's stage using Prolog
def check_parkinsons_stage(symptoms):
    # Convert symptoms list to Prolog fact
    prolog.assertz(f'symptoms(person, [{", ".join(symptoms)}])')

    # Query Prolog to determine stage
    query = list(prolog3.query("stage(X, person)"))
    
    if query:
        return query[0]['X']  # Return the stage if found
    return 0  # Return 0 if no stage is found

@app.route('/api/stage', methods=['POST'])
def get_stage():
    data = request.json
    symptoms = data.get('symptoms', [])
    stage = check_parkinsons_stage(symptoms)
    return jsonify({'stage': stage})


def parse_list_from_output(key, output_lines):
    for line in output_lines:
        if key in line:
            return eval(line.split(":", 1)[-1].strip())
    return []

def parse_value_from_output(key, output_lines):
    for line in output_lines:
        if key in line:
            return line.split(":", 1)[-1].strip()
    return None
    
@app.route('/calculate-risk', methods=['POST'])
def calculate_risk():
    try:
        data = request.json
        factors = data.get('factors', [])
        symptoms = data.get('symptoms', [])

        print(f"Received data: {data}")
        print(f"Factors: {factors}")
        print(f"Symptoms: {symptoms}")

        if not factors and not symptoms:
            return jsonify({"error": "No factors or symptoms provided", "risk": 0}), 400

        prolog_factors = "[" + ",".join(f"'{factor}'" for factor in factors) + "]"
        prolog_symptoms = "[" + ",".join(f"'{symptom}'" for symptom in symptoms) + "]"

        prolog_query = f"diagnose_and_calculate_risk({prolog_symptoms}, {prolog_factors}, RisqueGlobal)."
        print(f"Prolog query: {prolog_query}")

        result = subprocess.run(
            ['swipl', '-s', 'risk.pl', '-g', prolog_query, '-t', 'halt'],
            capture_output=True,
            text=True
        )

        print("Prolog stdout:", result.stdout)
        print("Prolog stderr:", result.stderr)

        if result.returncode != 0:
            return jsonify({"error": "Prolog execution failed", "details": result.stderr, "risk": 0}), 500

        # Directly convert the Prolog output to a float
        try:
            risk_value = float(result.stdout.strip())
            print(f"Extracted Risk Score: {risk_value}")
            return jsonify({"risk": risk_value}), 200
        except ValueError:
            return jsonify({"error": "Failed to parse risk score", "risk": 0}), 500

    except Exception as e:
        print(f"An error occurred: {str(e)}")
        return jsonify({"error": str(e), "risk": 0}), 500
    
# Fonction pour convertir les termes Prolog en Python
def convert_prolog_term(term):
    if isinstance(term, list):  # Gérer les listes Prolog
        return [convert_prolog_term(item) for item in term]
    elif isinstance(term, Prolog.Atom):  # Gérer les atomes Prolog
        return str(term)
    elif isinstance(term, Prolog.Compound):
        if term.arity == 2 and term.functor == "article":
            return {"author": convert_prolog_term(term.args[0]), "title": convert_prolog_term(term.args[1])}
        else:
            return str(term) # Handle other Compound terms as strings
    else:
        return term


# Route to handle diagnosis based on symptoms
@app.route('/diagnos', methods=['POST'])
def diagnos():
    data = request.json
    symptoms = data.get("symptoms", [])

    # Format the Prolog query
    formatted_symptoms = ', '.join([f'has_symptom({symptom}, present)' for symptom in symptoms])
    query = f"diagnose([{formatted_symptoms}], Diagnosis, NonMotor, Causes, Medications, References)."

    # Run Prolog query
    try:
        process = subprocess.run(
            ['swipl', '-q', '-t', query, '-s', 'Comp.pl'],
            capture_output=True,
            text=True
        )
        if process.returncode == 0:
            result = process.stdout.strip()
            return jsonify({"status": "success", "result": result})
        else:
            return jsonify({"status": "error", "message": process.stderr}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
prolog = Prolog()
prolog.consult("./diag.pl")  # Your Prolog file

@app.route('/diag', methods=['POST'])
def diagnose_route():
    try:
        data = request.get_json()
        symptoms = data.get('symptoms', [])

        # Convert symptoms to Prolog format
        prolog_symptoms = "[" + ",".join([f"'{s}'" for s in symptoms]) + "]"

        # Query for diagnosis
        query_diagnosis = f"diagnose({prolog_symptoms}, Disease)"
        results_diagnosis = list(prolog.query(query_diagnosis))

        if results_diagnosis:
            diagnosis_data = []
            for diagnosis_result in results_diagnosis:
                disease = str(diagnosis_result["Disease"])
                if disease == 'none':  # Handle no match case
                    diagnosis_data.append({
                        "disease": "No matching diagnosis found",
                        "score": 0,
                        "advice": "No specific advice available",
                        "communication_tips": "No specific tips available",
                        "stage": "N/A"
                    })
                    continue

                # Query for match score
                query_score = f"match_score({prolog_symptoms}, '{disease}', Score)"
                results_score = list(prolog.query(query_score))
                score = float(results_score[0]["Score"]) if results_score else 0

                # Query for advice
                query_advice = f"get_advice('{disease}', Advice)"
                results_advice = list(prolog.query(query_advice))
                advice = str(results_advice[0]["Advice"]) if results_advice else "No advice found"

                # Query for communication tips
                query_tips = f"get_communication_tips('{disease}', Tips)"
                results_tips = list(prolog.query(query_tips))
                tips = str(results_tips[0]["Tips"]) if results_tips else "No tips found"

                # Query for Parkinson's stage (specific to Parkinson's disease)
                stage = "N/A"
                if disease.lower() == "parkinson's disease":
                    query_stage = f"get_parkinsons_stage({prolog_symptoms}, Stage)"
                    results_stage = list(prolog.query(query_stage))
                    stage = int(results_stage[0]["Stage"]) if results_stage else "Unknown"

                diagnosis_data.append({
                    "disease": disease,
                    "score": score,
                    "advice": advice,
                    "communication_tips": tips,
                    "stage": stage  # Include stage in the response
                })
            return jsonify(diagnosis_data)
        else:
            return jsonify({"error": "No matching diagnosis found."}), 404

    except Exception as e:
        print(e)
        return jsonify({"error": "An error occurred during diagnosis."}), 500

    

# # Initialize Prolog interpreter
# prolog0 = Prolog()

# # Load Prolog file
# prolog0.consult('./qr.pl')

# # Initialiser l'état
# state = {
#     "last_asked": 0,
#     "symptom_count": 0,
#     "responses": {}
# }

# # Route pour poser une question ou renvoyer un diagnostic
# @app.route('/ask', methods=['POST'])
# def ask_question():
#     data = request.get_json()
#     question_id = data.get('questionId', 0)
#     response = data.get('response', '')

#     if question_id != 0:
#         # Enregistrer la réponse dans Prolog
#         prolog0.query(f"record_response({question_id}, {response.lower()})")

#         # Mettre à jour la question posée et le nombre de symptômes
#         prolog0.query("next_question(QuestionText, Diagnosis, SymptomCount)")

#         # Obtenir le diagnostic depuis Prolog
#         result = list(prolog0.query("symptom_count(Count)"))
#         symptom_count = result[0]["Count"] if result else 0
#         result = list(prolog0.query(f"determine_risk({symptom_count}, Diagnosis)"))
#         diagnosis = result[0]["Diagnosis"] if result else "Diagnostic inconnu"

#         # Retourner la réponse
#         return jsonify({
#             "nextQuestion": f"Question {question_id + 1}",  # Ou charger la prochaine question
#             "diagnosis": diagnosis,
#             "symptomCount": symptom_count
#         })
#     else:
#         return jsonify({"error": "Missing questionId or response."}), 400

# # Route pour réinitialiser le questionnaire
# @app.route('/reset', methods=['POST'])
# def reset_questionnaire():
#     # Réinitialiser l'état de Prolog
#     prolog0.query("reset_questionnaire()")
#     return jsonify({"message": "Questionnaire réinitialisé avec succès."})

# Initialize Prolog engine
prolog5 = Prolog()

# Load Prolog5 rules for processing answers
prolog5.assertz("weight('slower_in_activities', 1)")
prolog5.assertz("weight('smaller_handwriting', 0.7)")
prolog5.assertz("weight('slurred_speech', 1)")
prolog5.assertz("weight('trouble_rising_from_chair', 0.5)")
prolog5.assertz("weight('shaking', 1.5)")
prolog5.assertz("weight('more_stiffness', 0.7)")
prolog5.assertz("weight('trouble_fastening_buttons', 0.5)")
prolog5.assertz("weight('shuffle_feet', 1)")
prolog5.assertz("weight('feet_stuck_to_floor', 0.8)")
prolog5.assertz("weight('no_arm_swing', 1.2)")
prolog5.assertz("weight('more_trouble_with_balance', 0.8)")
prolog5.assertz("weight('stoop_abnormal_posture', 0.7)")

answers = {}

@app.route('/answer', methods=['POST'])
def answer():
    data = request.json
    question_id = data.get('question_id')
    answer = data.get('answer')

    # Store the answer in the answers dictionary
    answers[question_id] = (answer)

    # Assert the answer in Prolog5
    prolog5.assertz(f"answered({question_id}, {answer})")
    
    return jsonify({"message": "Answer received successfully."}), 200

@app.route('/get_recommendation', methods=['POST'])
def get_recommendation():
    data = request.get_json()
    answers = data.get('answers', {})
    symptom_count = sum(1 for answer in answers.values() if answer == 'yes')
    
    if symptom_count > 6:
        recommendation = (
            "You may be at risk for Parkinson's disease. "
            "Please consult a doctor for further evaluation. Possible medications include:\n"
            "- Levodopa (Sinemet, Duopa)\n"
            "- Dopamine agonists (Pramipexole, Ropinirole)\n"
            "- MAO-B inhibitors (Rasagiline, Selegiline)"
        )
    else:
        recommendation = (
            "You appear to be at low risk for Parkinson's disease. "
            "Stay active and maintain a healthy lifestyle. If you notice changes, consult a doctor."
        )

    return jsonify({'recommendation': recommendation})


# @app.route('/reset', methods=['POST'])
# def reset():
#     return jsonify({'message': 'Questionnaire reset successfully.'})
@app.route('/reset', methods=['POST'])
def reset():
    # Clear all answers to allow starting the questionnaire from scratch
    global answers
    answers = {}  # Reset the answers dictionary

    return jsonify({"message": "Questionnaire reset. You can start over."})



def run_prolog_query1(query):
    """Run Prolog query using SWI-Prolog."""
    result = subprocess.run(['swipl', '-s', 'qr.pl', '-g', query, '-t', 'halt'],
                                        capture_output=True,
        text=True
    )
    return result.stdout.strip()

@app.route('/askk', methods=['POST'])
def ask_question():
    data = request.get_json()

    question_id = data.get('questionId', 0)
    response = data.get('response', '')

    # Enregistrer la réponse et obtenir la prochaine question
    if question_id > 0 and response:
        record_response_query = f"record_response({question_id}, {response})."
        run_prolog_query1(record_response_query)

    # Requête pour obtenir la prochaine question et le diagnostic
    next_question_query = "next_question(QuestionText, Diagnosis, SymptomCount)."
    result = run_prolog_query1(next_question_query)

    # Séparation du résultat
    result_parts = result.split(',')
    if len(result_parts) == 3:
        next_question, diagnosis, symptom_count = [part.strip() for part in result_parts]
        return jsonify({
            "nextQuestion": next_question,
            "diagnosis": diagnosis,
            "symptomCount": int(symptom_count)
        })
    else:
        return jsonify({
            "error": "Unexpected result format from Prolog",
            "result": result
        })
    
    # .........................................

# Initialize Prolog and load the knowledge base
prolog9 = Prolog()
prolog9.consult("kb.pl")  # Assurez-vous que ce fichier contient la base de connaissances Prolog

@app.route("/symptom", methods=["GET"])
def get_symptom():
    symptom = request.args.get("symptom")
    try:
        query = list(prolog9.query(f"symptom({symptom}, Description)"))
        if query:
            description = query[0]['Description']
            return jsonify({"response": f"Symptom: {symptom}, Description: {description}"})
        return jsonify({"response": "Symptom not found."}), 404
    except Exception as e:
        print(f"Error fetching symptom: {e}")
        return jsonify({"error": "An error occurred while fetching the symptom."}), 500

@app.route("/medications", methods=["GET"])
def get_medications():
    try:
        # Query Prolog for medications
        query = list(prolog9.query("medication(Name, Description)"))
        
        # Convert data to strings if needed
        medications = [
            {
                "name": str(q["Name"]),
                "description": str(q["Description"])
            }
            for q in query
        ]
        
        return jsonify({"response": medications})
    except Exception as e:
        print(f"Error fetching medications: {e}")
        return jsonify({"error": "Unable to fetch medications."}), 500

@app.route("/exercises", methods=["GET"])
def get_exercises():
    try:
        # Query Prolog for exercises
        query = list(prolog9.query("exercise(Name, Description)"))
        
        # Convert data to strings if needed
        exercises = [
            {
                "name": str(q["Name"]),
                "description": str(q["Description"])
            }
            for q in query
        ]
        
        return jsonify({"response": exercises})
    except Exception as e:
        print(f"Error fetching exercises: {e}")
        return jsonify({"error": "Unable to fetch exercises."}), 500

@app.route("/questions", methods=["GET"])
def get_doctors_questions():
    try:
        # Print questions directly from Prolog to the terminal
        prolog9.query("questions_to_ask_doctor.")
        return jsonify({"response": "Check the terminal for printed questions."})
    except Exception as e:
        print(f"Error fetching questions: {e}")
        return jsonify({"error": "Unable to fetch questions."}), 500

@app.route("/progression", methods=["GET"])
def get_all_progressions():
    try:
        # Récupère toutes les progressions disponibles dans la base de connaissances
        query = list(prolog9.query("progression(Type, Description)"))
        
        if query:
            progressions = [
                {
                    "type": q["Type"].decode("utf-8") if isinstance(q["Type"], bytes) else q["Type"],
                    "description": q["Description"].decode("utf-8") if isinstance(q["Description"], bytes) else q["Description"],
                }
                for q in query
            ]
            return jsonify({"response": progressions})
        return jsonify({"response": "No progressions found."}), 404
    except Exception as e:
        # Capture et log l'erreur pour le débogage
        print(f"Error fetching progressions: {e}")
        return jsonify({"error": "An error occurred while fetching progressions."}), 500


if __name__ == '__main__':
    app.run(debug=True, port='9000')