# MindMate Harmony Space - Web Service Integration
# Simplified walkers for Flask REST API integration

glob datetime = __import__('datetime');

# ============================================================================
# SIMPLIFIED NODE TYPES FOR WEB SERVICE
# ============================================================================

node MoodLog {
    has emotion: str;
    has intensity: float;
    has timestamp: str;
    has user_input: str = "";
    has triggers: list = [];
    has activities: list = [];
}

node User {
    has user_id: str = "default_user";
    has mood_history: list = [];
}

# ============================================================================
# WALKER: MOOD LOGGER
# Purpose: Log mood entries via web interface
# ============================================================================

walker MoodLogger {
    has emotion_name: str;
    has intensity: float;
    has user_input: str = "";
    has trigger_names: list = [];
    has activity_names: list = [];
    
    can log_mood with `root entry {
        # Create timestamp
        timestamp = datetime.datetime.now().isoformat();
        
        # Create mood log node
        mood_node = MoodLog(
            emotion=self.emotion_name,
            intensity=self.intensity,
            user_input=self.user_input,
            triggers=self.trigger_names,
            activities=self.activity_names,
            timestamp=timestamp
        );
        
        # Connect to root
        here ++> mood_node;
        
        # Return success response
        report {
            "status": "success",
            "message": "Mood logged successfully",
            "emotion": self.emotion_name,
            "intensity": self.intensity,
            "timestamp": timestamp,
            "triggers": self.trigger_names,
            "activities": self.activity_names
        };
    }
}

# ============================================================================
# WALKER: TREND ANALYZER
# Purpose: Analyze mood patterns and trends
# ============================================================================

# walker TrendAnalyzer {
#     Temporarily commented out for debugging
# }

# ============================================================================
# WALKER: SUPPORTIVE ADVISOR
# Purpose: Generate personalized support suggestions
# ============================================================================

walker SupportiveAdvisor {
    has emotion_name: str;
    has intensity: float;
    
    can generate_suggestions with `root entry {
        suggestions = [];
        
        # Breathing exercises for high intensity
        if self.intensity > 0.7 {
            if self.emotion_name == "anxious" or self.emotion_name == "stressed" {
                suggestions.append({
                    "title": "4-7-8 Breathing Technique",
                    "content": "Breathe in for 4 counts, hold for 7, exhale for 8. Repeat 4 times. This activates your parasympathetic nervous system.",
                    "type": "breathing",
                    "priority": 5
                });
            } else {
                if self.emotion_name == "angry" {
                    suggestions.append({
                        "title": "Box Breathing",
                        "content": "Breathe in for 4, hold for 4, out for 4, hold for 4. Visualize tracing a box. Helps regulate strong emotions.",
                        "type": "breathing",
                        "priority": 5
                    });
                }
            }
        }
        
        # Activity suggestions based on emotion
        if self.emotion_name == "sad" or self.emotion_name == "lonely" {
            suggestions.append({
                "title": "Connect with Someone",
                "content": "Reach out to a friend or family member. Even a brief conversation can lift your mood. You don't have to be alone.",
                "type": "activity",
                "priority": 4
            });
        } elif self.emotion_name == "anxious" or self.emotion_name == "stressed" {
            suggestions.append({
                "title": "5-Minute Movement Break",
                "content": "Take a short walk, stretch, or do gentle yoga. Physical movement helps discharge nervous energy and calm your mind.",
                "type": "activity",
                "priority": 4
            });
        } elif self.emotion_name == "tired" or self.emotion_name == "exhausted" {
            suggestions.append({
                "title": "Restorative Rest",
                "content": "Give yourself permission to rest. Even 10 minutes of quiet time can help. Consider a power nap or simply closing your eyes.",
                "type": "activity",
                "priority": 4
            });
        } elif self.emotion_name == "confused" {
            suggestions.append({
                "title": "Journal Your Thoughts",
                "content": "Write freely for 5 minutes about what's on your mind. Externalizing thoughts can bring clarity and perspective.",
                "type": "journaling",
                "priority": 3
            });
        }
        
        # Affirmations for all emotions
        affirmation = "";
        if self.emotion_name == "happy" or self.emotion_name == "excited" or self.emotion_name == "grateful" {
            affirmation = "I celebrate this moment of joy. I deserve to feel good and share my positive energy with others.";
        } elif self.emotion_name == "sad" or self.emotion_name == "lonely" {
            affirmation = "My feelings are valid. This moment will pass. I am worthy of love and connection.";
        } elif self.emotion_name == "anxious" or self.emotion_name == "stressed" {
            affirmation = "I am safe in this moment. I can handle challenges one step at a time. I trust in my resilience.";
        } elif self.emotion_name == "angry" {
            affirmation = "I acknowledge my anger. I can express it in healthy ways. I choose how I respond.";
        } elif self.emotion_name == "calm" or self.emotion_name == "peaceful" {
            affirmation = "I embrace this sense of peace. I am grounded and centered. I carry this calm with me.";
        } else {
            affirmation = "I honor my feelings. I am doing my best. I am enough, just as I am.";
        }
        
        suggestions.append({
            "title": "Personal Affirmation",
            "content": affirmation,
            "type": "affirmation",
            "priority": 3
        });
        
        # Professional help suggestion for severe cases
        if self.intensity > 0.85 and (self.emotion_name == "sad" or self.emotion_name == "anxious" or self.emotion_name == "angry") {
            suggestions.append({
                "title": "Consider Professional Support",
                "content": "You're experiencing intense emotions. Speaking with a counselor or therapist can provide valuable support and coping strategies.",
                "type": "professional",
                "priority": 5
            });
        }
        
        # General wellness tip
        suggestions.append({
            "title": "Self-Care Reminder",
            "content": "Remember to stay hydrated, get adequate sleep, and nourish your body. Physical wellness supports emotional wellbeing.",
            "type": "wellness",
            "priority": 2
        });
        
        report {
            "status": "success",
            "emotion": self.emotion_name,
            "intensity": self.intensity,
            "suggestions": suggestions,
            "message": f"Generated {len(suggestions)} personalized suggestions"
        };
    }
}

# ============================================================================
# WALKER: DATA MANAGER
# Purpose: Manage mood data (clear, export stats)
# ============================================================================

walker DataManager {
    has operation: str = "stats";  # stats, clear
    has mood_logs: list = [];
    
    can manage_data with `root entry {
        # Simplified: Use stored mood_logs
        # Now process based on operation
        if self.operation == "stats" {
            # Return statistics
            total_entries = len(self.mood_logs);
            
            if total_entries > 0 {
                # Get date range
                earliest = "";
                latest = "";
                
                for mood in self.mood_logs {
                    if earliest == "" or mood.timestamp < earliest {
                        earliest = mood.timestamp;
                    }
                    if latest == "" or mood.timestamp > latest {
                        latest = mood.timestamp;
                    }
                }
                
                report {
                    "status": "success",
                    "total_entries": total_entries,
                    "earliest_entry": earliest,
                    "latest_entry": latest,
                    "message": f"Found {total_entries} mood entries"
                };
            } else {
                report {
                    "status": "success",
                    "total_entries": 0,
                    "message": "No mood entries found"
                };
            }
        } elif self.operation == "clear" {
            # Clear all mood logs
            cleared_count = 0;
            for mood in self.mood_logs {
                del mood;
                cleared_count = cleared_count + 1;
            }
            
            report {
                "status": "success",
                "message": f"Deleted {cleared_count} mood entries",
                "cleared_count": cleared_count
            };
        } else {
            report {
                "status": "error",
                "message": "Invalid operation. Use 'stats' or 'clear'"
            };
        }
    }
}

# ============================================================================
# WALKER: GRAPH BUILDER
# Purpose: Initialize user profile and graph structure
# ============================================================================

walker GraphBuilder {
    has user_id: str = "default_user";
    has user_name: str = "User";
    has existing_users: list = [];
    
    can build_graph with `root entry {
        # Simplified: Check existing_users list
        # Check and create if needed
        found_user = False;
        for user in self.existing_users {
            if user.user_id == self.user_id {
                found_user = True;
            }
        }
        
        if found_user {
            report {
                "status": "exists",
                "message": "User already exists",
                "user_id": self.user_id
            };
        } else {
            # Create new user node
            user_node = User(
                user_id=self.user_id,
                mood_history=[]
            );
            
            here ++> user_node;
            
            report {
                "status": "created",
                "message": "Created user profile",
                "user_id": self.user_id
            };
        }
    }
}

# ============================================================================
# ENTRY POINT FOR JAC SERVE
# ============================================================================

with entry {
    # Initialize root node
    root = here;
    
    # Create default user if not exists
    builder = spawn GraphBuilder(user_id="default_user", user_name="MindMate User") spawn root;
    
    print("✅ MindMate Web Service initialized");
    print("📊 Available Walkers:");
    print("   - MoodLogger: Log mood entries");
    print("   - TrendAnalyzer: Analyze mood patterns");
    print("   - SupportiveAdvisor: Generate support suggestions");
    print("   - DataManager: Manage mood data");
    print("   - GraphBuilder: Initialize user profiles");
}
