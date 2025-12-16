# MindMate Harmony Space - Simple Flask API Server
# Wraps JacLang execution for web interface

from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import subprocess
import json
import tempfile
import os
from datetime import datetime
from collections import Counter

app = Flask(__name__)
CORS(app)  # Enable CORS for web interface

# Data storage file
DATA_FILE = 'mood_logs.json'

# Helper functions for data persistence
def load_mood_logs():
    """Load mood logs from JSON file"""
    if os.path.exists(DATA_FILE):
        try:
            with open(DATA_FILE, 'r') as f:
                return json.load(f)
        except:
            return []
    return []

def save_mood_logs(logs):
    """Save mood logs to JSON file"""
    with open(DATA_FILE, 'w') as f:
        json.dump(logs, f, indent=2)

def analyze_moods(logs):
    """Analyze mood logs and return insights"""
    if not logs:
        return {
            "total_entries": 0,
            "most_common": "N/A",
            "trend": "Start logging moods to see trends",
            "top_triggers": [],
            "top_activities": []
        }
    
    # Count emotions
    emotions = [log['emotion_name'] for log in logs]
    emotion_counts = Counter(emotions)
    most_common = emotion_counts.most_common(1)[0][0] if emotion_counts else "N/A"
    
    # Collect triggers and activities
    all_triggers = []
    all_activities = []
    for log in logs:
        all_triggers.extend(log.get('trigger_names', []))
        all_activities.extend(log.get('activity_names', []))
    
    trigger_counts = Counter(all_triggers)
    activity_counts = Counter(all_activities)
    
    # Determine trend
    if len(logs) >= 3:
        recent = logs[-3:]
        avg_intensity = sum(log['intensity'] for log in recent) / len(recent)
        if avg_intensity > 0.7:
            trend = "Your recent moods show higher intensity - consider self-care activities"
        elif avg_intensity < 0.3:
            trend = "Your mood intensity is lower - you're managing well!"
        else:
            trend = "Your moods are balanced - keep up the good work!"
    else:
        trend = "Keep logging to see patterns emerge"
    
    return {
        "total_entries": len(logs),
        "most_common": most_common,
        "trend": trend,
        "top_triggers": [t[0] for t in trigger_counts.most_common(3)],
        "top_activities": [a[0] for a in activity_counts.most_common(3)]
    }

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
        
        # Create mood log entry
        mood_entry = {
            "timestamp": datetime.now().isoformat(),
            "emotion_name": data.get('emotion_name', 'happy'),
            "intensity": data.get('intensity', 0.5),
            "user_input": data.get('user_input', ''),
            "trigger_names": data.get('trigger_names', []),
            "activity_names": data.get('activity_names', [])
        }
        
        # Load existing logs and append new entry
        logs = load_mood_logs()
        logs.append(mood_entry)
        save_mood_logs(logs)
        
        # Get suggestions based on emotion
        emotion = mood_entry['emotion_name']
        suggestions = get_suggestions_for_emotion(emotion, mood_entry['intensity'])
        
        return jsonify({
            "status": "success",
            "message": "Mood logged successfully",
            "emotion": emotion,
            "intensity": mood_entry['intensity'],
            "suggestions": suggestions,
            "total_logs": len(logs)
        })
        
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

def get_suggestions_for_emotion(emotion, intensity):
    """Get personalized suggestions based on emotion and intensity"""
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
        ],
        'calm': [
            {
                "title": "Mindful Meditation",
                "content": "Sit quietly for 5 minutes, focusing on your breath.",
                "type": "meditation"
            },
            {
                "title": "Creative Expression",
                "content": "Draw, write, or engage in any creative activity you enjoy.",
                "type": "creative"
            }
        ],
        'angry': [
            {
                "title": "Physical Release",
                "content": "Go for a brisk walk or do some physical exercise to release tension.",
                "type": "exercise"
            },
            {
                "title": "Cooling Breath",
                "content": "Take deep breaths and count to 10 slowly before responding.",
                "type": "breathing"
            }
        ],
        'excited': [
            {
                "title": "Channel Your Energy",
                "content": "Use this positive energy to tackle a task you've been putting off.",
                "type": "productivity"
            },
            {
                "title": "Celebrate Mindfully",
                "content": "Take a moment to savor this feeling and appreciate what led to it.",
                "type": "mindfulness"
            }
        ],
        'tired': [
            {
                "title": "Power Nap",
                "content": "Take a 15-20 minute nap to recharge your energy.",
                "type": "rest"
            },
            {
                "title": "Gentle Stretching",
                "content": "Do some light stretches to wake up your body.",
                "type": "exercise"
            }
        ]
    }
    
    return suggestions_map.get(emotion, suggestions_map['anxious'])

@app.route('/walker/TrendAnalyzer', methods=['POST'])
def trend_analyzer():
    try:
        # Load and analyze mood logs
        logs = load_mood_logs()
        analysis = analyze_moods(logs)
        
        return jsonify({
            "status": "success",
            "analysis_result": analysis
        })
        
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route('/walker/SupportiveAdvisor', methods=['POST'])
def supportive_advisor():
    try:
        data = request.json
        emotion = data.get('emotion_name', 'anxious')
        intensity = data.get('intensity', 0.7)
        
        suggestions = get_suggestions_for_emotion(emotion, intensity)
        
        return jsonify({
            "status": "success",
            "emotion": emotion,
            "intensity": intensity,
            "suggestions": suggestions
        })
        
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route('/data/export', methods=['GET'])
def export_data():
    """Export all mood logs as JSON"""
    try:
        logs = load_mood_logs()
        return jsonify({
            "status": "success",
            "data": logs,
            "total_entries": len(logs),
            "export_date": datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route('/data/import', methods=['POST'])
def import_data():
    """Import mood logs from JSON"""
    try:
        data = request.json
        imported_logs = data.get('data', [])
        
        if not isinstance(imported_logs, list):
            return jsonify({
                "status": "error",
                "message": "Invalid data format. Expected a list of mood entries."
            }), 400
        
        # Option to append or replace
        replace = data.get('replace', False)
        
        if replace:
            save_mood_logs(imported_logs)
            message = f"Replaced all data with {len(imported_logs)} imported entries"
        else:
            existing_logs = load_mood_logs()
            existing_logs.extend(imported_logs)
            save_mood_logs(existing_logs)
            message = f"Added {len(imported_logs)} entries to existing {len(existing_logs) - len(imported_logs)} entries"
        
        return jsonify({
            "status": "success",
            "message": message,
            "total_entries": len(load_mood_logs())
        })
        
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route('/data/delete', methods=['POST'])
def delete_data():
    """Delete mood entries"""
    try:
        data = request.json
        action = data.get('action', 'all')
        
        if action == 'all':
            # Delete all entries
            save_mood_logs([])
            return jsonify({
                "status": "success",
                "message": "All mood entries deleted",
                "total_entries": 0
            })
        elif action == 'single':
            # Delete specific entry by index
            index = data.get('index')
            if index is None:
                return jsonify({
                    "status": "error",
                    "message": "Index required for single deletion"
                }), 400
            
            logs = load_mood_logs()
            if 0 <= index < len(logs):
                deleted_entry = logs.pop(index)
                save_mood_logs(logs)
                return jsonify({
                    "status": "success",
                    "message": f"Deleted entry from {deleted_entry.get('timestamp', 'unknown time')}",
                    "total_entries": len(logs)
                })
            else:
                return jsonify({
                    "status": "error",
                    "message": "Invalid index"
                }), 400
        elif action == 'range':
            # Delete entries in date range
            start_date = data.get('start_date')
            end_date = data.get('end_date')
            
            logs = load_mood_logs()
            original_count = len(logs)
            
            if start_date and end_date:
                logs = [log for log in logs 
                       if not (start_date <= log.get('timestamp', '') <= end_date)]
            
            save_mood_logs(logs)
            deleted_count = original_count - len(logs)
            
            return jsonify({
                "status": "success",
                "message": f"Deleted {deleted_count} entries",
                "total_entries": len(logs)
            })
        else:
            return jsonify({
                "status": "error",
                "message": "Invalid action. Use 'all', 'single', or 'range'"
            }), 400
            
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route('/data/stats', methods=['GET'])
def data_stats():
    """Get statistics about stored data"""
    try:
        logs = load_mood_logs()
        
        if not logs:
            return jsonify({
                "status": "success",
                "total_entries": 0,
                "first_entry": None,
                "last_entry": None,
                "file_exists": os.path.exists(DATA_FILE)
            })
        
        return jsonify({
            "status": "success",
            "total_entries": len(logs),
            "first_entry": logs[0].get('timestamp'),
            "last_entry": logs[-1].get('timestamp'),
            "file_size_kb": os.path.getsize(DATA_FILE) / 1024 if os.path.exists(DATA_FILE) else 0
        })
        
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

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
    print("  - GET  /data/export")
    print("  - POST /data/import")
    print("  - POST /data/delete")
    print("  - GET  /data/stats")
    print("")
    print("Press Ctrl+C to stop the server")
    print("=" * 60)
    print("")
    
    app.run(host='0.0.0.0', port=8000, debug=False)
