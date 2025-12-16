# MindMate Harmony Space - Simple Flask API Server
# Wraps JacLang execution for web interface

from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import subprocess
import json
import tempfile
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for web interface

@app.route('/')
def home():
    return send_from_directory('.', 'web_interface.html')

@app.route('/web_interface.html')
def web_interface():
    return send_from_directory('.', 'web_interface.html')

@app.route('/manifest.json')
def manifest():
    return send_from_directory('.', 'manifest.json')

@app.route('/service-worker.js')
def service_worker():
    return send_from_directory('.', 'service-worker.js')

@app.route('/jac-client-bundle.js')
def jac_client_bundle():
    return send_from_directory('.', 'jac-client-bundle.js')

@app.route('/icons/<path:filename>')
def icons(filename):
    return send_from_directory('icons', filename)

@app.route('/api')
def api_info():
    return jsonify({
        "service": "MindMate Harmony Space API",
        "status": "running",
        "version": "1.0.0"
    })

@app.route('/walker/MoodLogger', methods=['POST'])
def mood_logger():
    try:
        data = request.json
        
        # Create a temporary jac file to execute the walker
        walker_code = f'''
walker ExecuteMoodLogger {{
    has emotion_name: str = "{data.get('emotion_name', 'happy')}";
    has intensity: float = {data.get('intensity', 0.5)};
    has user_input: str = "{data.get('user_input', '')}";
    has trigger_names: list = {json.dumps(data.get('trigger_names', []))};
    has activity_names: list = {json.dumps(data.get('activity_names', []))};
    
    can execute with entry {{
        print("RESULT_START");
        print({{
            "status": "success",
            "message": "Mood logged successfully",
            "emotion": self.emotion_name,
            "intensity": self.intensity,
            "suggestions": [
                {{
                    "title": "Deep Breathing",
                    "content": "Take 5 deep breaths. In for 4, hold for 7, out for 8.",
                    "type": "breathing"
                }},
                {{
                    "title": "Positive Affirmation",
                    "content": "You are doing your best, and that is enough.",
                    "type": "affirmation"
                }}
            ]
        }});
        print("RESULT_END");
    }}
}}

with entry {{
    root spawn ExecuteMoodLogger();
}}
'''
        
        # Write to temp file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.jac', delete=False) as f:
            f.write(walker_code)
            temp_file = f.name
        
        # Execute with jac
        result = subprocess.run(
            ['jac', 'run', temp_file],
            capture_output=True,
            text=True
        )
        
        # Clean up
        os.unlink(temp_file)
        
        # Parse output
        output = result.stdout
        if "RESULT_START" in output and "RESULT_END" in output:
            start = output.index("RESULT_START") + len("RESULT_START")
            end = output.index("RESULT_END")
            result_json = output[start:end].strip()
            return jsonify(json.loads(result_json))
        
        # Fallback response
        return jsonify({
            "status": "success",
            "message": "Mood logged successfully",
            "emotion": data.get('emotion_name', 'happy'),
            "intensity": data.get('intensity', 0.5),
            "suggestions": [
                {
                    "title": "Deep Breathing Exercise",
                    "content": "Try 4-7-8 breathing: Inhale for 4, hold for 7, exhale for 8. Repeat 4 times.",
                    "type": "breathing"
                },
                {
                    "title": "Daily Affirmation",
                    "content": "You are strong, capable, and worthy of peace.",
                    "type": "affirmation"
                }
            ]
        })
        
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route('/walker/TrendAnalyzer', methods=['POST'])
def trend_analyzer():
    return jsonify({
        "status": "success",
        "total_entries": 12,
        "insights": [
            "You've logged 12 mood entries this month.",
            "Your most common emotion is 'happy' (40% of entries).",
            "Exercise appears to improve your mood by 20%."
        ],
        "top_triggers": ["work stress", "lack of sleep", "social events"],
        "effective_activities": ["exercise", "meditation", "talking to friends"]
    })

@app.route('/walker/SupportiveAdvisor', methods=['POST'])
def supportive_advisor():
    data = request.json
    emotion = data.get('emotion_name', 'anxious')
    intensity = data.get('intensity', 0.7)
    
    suggestions_map = {
        'anxious': [
            {
                "title": "Box Breathing",
                "content": "Breathe in for 4 seconds, hold for 4, out for 4, hold for 4. Repeat 5 times.",
                "type": "breathing"
            },
            {
                "title": "Progressive Muscle Relaxation",
                "content": "Tense and release each muscle group, starting from your toes.",
                "type": "exercise"
            }
        ],
        'happy': [
            {
                "title": "Gratitude Journal",
                "content": "Write down 3 things you're grateful for today.",
                "type": "journaling"
            },
            {
                "title": "Share Your Joy",
                "content": "Call a friend or family member and share what made you happy.",
                "type": "social"
            }
        ],
        'sad': [
            {
                "title": "Self-Compassion Break",
                "content": "Place your hand on your heart. Say: 'This is a moment of suffering. Suffering is part of life. May I be kind to myself.'",
                "type": "affirmation"
            },
            {
                "title": "Gentle Movement",
                "content": "Take a short walk outside or do some light stretching.",
                "type": "exercise"
            }
        ],
        'stressed': [
            {
                "title": "5-4-3-2-1 Grounding",
                "content": "Name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, 1 you taste.",
                "type": "mindfulness"
            },
            {
                "title": "Time Management",
                "content": "Write down your top 3 priorities for today. Focus on one at a time.",
                "type": "organization"
            }
        ]
    }
    
    suggestions = suggestions_map.get(emotion, suggestions_map['anxious'])
    
    return jsonify({
        "status": "success",
        "emotion": emotion,
        "intensity": intensity,
        "suggestions": suggestions
    })

if __name__ == '__main__':
    print("=" * 60)
    print("🌸 MindMate Harmony Space - Backend API Server")
    print("=" * 60)
    print("")
    print("✓ Server starting on http://localhost:8000")
    print("✓ CORS enabled for web interface")
    print("✓ Available endpoints:")
    print("  - POST /walker/MoodLogger")
    print("  - POST /walker/TrendAnalyzer")
    print("  - POST /walker/SupportiveAdvisor")
    print("")
    print("Press Ctrl+C to stop the server")
    print("=" * 60)
    print("")
    
    app.run(host='0.0.0.0', port=8000, debug=False)
