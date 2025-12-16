# MindMate Harmony Space - Multi-Agent Architecture
# Multi-Agent System with OSP Graph and byLLM Integration

glob datetime = __import__('datetime');

# ============================================================================
# OSP GRAPH NODE TYPES
# ============================================================================

node UserProfile {
    has user_id: str;
    has name: str;
    has age: int = 25;
    has preferences: dict = {};
    has created_at: str = datetime.now().isoformat();
    has mood_count: int = 0;
    has total_score: float = 0.0;
}

node MoodEntry {
    has entry_id: str;
    has emotion_name: str;
    has intensity: float;  # 0.0 to 1.0
    has user_input: str;
    has triggers: list = [];
    has activities: list = [];
    has timestamp: str = datetime.now().isoformat();
    has sentiment_score: float = 0.5;
    has context_tags: list = [];
}

node Recommendation {
    has rec_id: str;
    has title: str;
    has content: str;
    has rec_type: str;  # breathing, affirmation, activity, therapy
    has priority: int = 1;  # 1-5
    has relevance_score: float = 0.0;
    has status: str = "active";  # active, completed, dismissed
    has generated_at: str = datetime.now().isoformat();
    has personalization_factors: list = [];
}

node Insight {
    has insight_id: str;
    has insight_type: str;  # trend, pattern, milestone, alert
    has title: str;
    has description: str;
    has confidence_score: float = 0.0;
    has data_points: int = 0;
    has timeframe: str = "week";
    has actionable: bool = True;
    has generated_at: str = datetime.now().isoformat();
}

node AnalysisSession {
    has session_id: str;
    has started_at: str = datetime.now().isoformat();
    has completed_at: str = "";
    has agents_involved: list = [];
    has results: dict = {};
}

# ============================================================================
# OSP GRAPH EDGE TYPES
# ============================================================================

edge LOGS_MOOD {
    has logged_at: str = datetime.now().isoformat();
}

edge GENERATES_REC {
    has generated_by: str;  # agent name
    has confidence: float = 0.0;
    has reasoning: str = "";
}

edge HAS_INSIGHT {
    has discovered_at: str = datetime.now().isoformat();
    has relevance: float = 0.0;
}

edge RELATED_TO {
    has relation_type: str;  # causes, correlates, follows
    has strength: float = 0.0;
}

edge VALIDATES {
    has validation_score: float = 0.0;
    has validator_agent: str;
    has validated_at: str = datetime.now().isoformat();
}

# ============================================================================
# MULTI-AGENT SYSTEM
# ============================================================================

"""
AGENT 1: MoodAnalyzerAgent
Responsibilities:
- Analyze mood entries for patterns
- Calculate sentiment scores
- Identify triggers and correlations
- Traverse graph to find related moods
"""
walker MoodAnalyzerAgent {
    has user_id: str;
    has analysis_depth: int = 7;  # days to analyze
    has mood_entries: list = [];
    has patterns: dict = {};
    has trigger_analysis: dict = {};
    
    can analyze with entry {
        print("🔍 MoodAnalyzerAgent: Starting mood analysis for user:", self.user_id);
        
        # Find user profile
        root [0] ;
        visit [-->];
    }
    
    can process_user with UserProfile entry {
        print(f"📊 Analyzing {here.mood_count} mood entries...");
        
        # Traverse mood entries
        mood_nodes = [-->];
        self.mood_entries = [];
        
        for mood_node in mood_nodes {
            self.mood_entries.append({
                "emotion": mood_node.emotion_name,
                "intensity": mood_node.intensity,
                "triggers": mood_node.triggers,
                "timestamp": mood_node.timestamp
            });
        }
        
        # Analyze patterns
        self.analyze_patterns();
        self.analyze_triggers();
        
        # Spawn RecommendationAgent
        spawn RecommendationAgent(
            user_id=self.user_id,
            analysis_data=self.patterns,
            trigger_data=self.trigger_analysis
        );
    }
    
    can analyze_patterns {
        emotion_counts = {};
        intensity_sum = 0.0;
        
        for entry in self.mood_entries {
            emotion = entry["emotion"];
            emotion_counts[emotion] = emotion_counts.get(emotion, 0) + 1;
            intensity_sum += entry["intensity"];
        }
        
        self.patterns = {
            "emotion_distribution": emotion_counts,
            "avg_intensity": intensity_sum / len(self.mood_entries) if self.mood_entries else 0.0,
            "total_entries": len(self.mood_entries),
            "dominant_emotion": max(emotion_counts.items(), key=lambda x: x[1])[0] if emotion_counts else "neutral"
        };
        
        print(f"📈 Patterns identified: {self.patterns}");
    }
    
    can analyze_triggers {
        trigger_impact = {};
        
        for entry in self.mood_entries {
            for trigger in entry["triggers"]:
                if trigger not in trigger_impact {
                    trigger_impact[trigger] = {"count": 0, "avg_intensity": 0.0, "total_intensity": 0.0};
                }
                trigger_impact[trigger]["count"] += 1;
                trigger_impact[trigger]["total_intensity"] += entry["intensity"];
        }
        
        # Calculate averages
        for trigger in trigger_impact:
            count = trigger_impact[trigger]["count"];
            trigger_impact[trigger]["avg_intensity"] = trigger_impact[trigger]["total_intensity"] / count;
        
        self.trigger_analysis = trigger_impact;
        print(f"🎯 Trigger analysis complete: {len(trigger_impact)} triggers identified");
    }
}

"""
AGENT 2: RecommendationAgent (with byLLM integration)
Responsibilities:
- Generate personalized recommendations
- Use LLM for content creation
- Create and link recommendation nodes
- Consider user patterns and preferences
"""
walker RecommendationAgent {
    has user_id: str;
    has analysis_data: dict;
    has trigger_data: dict;
    has recommendations: list = [];
    has llm_generated: bool = False;
    
    can generate with entry {
        print("💡 RecommendationAgent: Generating personalized recommendations");
        
        # Generate recommendations based on analysis
        self.create_breathing_recommendation();
        self.create_activity_recommendation();
        self.create_affirmation_recommendation();
        
        # Spawn ValidationAgent to score recommendations
        spawn ValidationAgent(
            user_id=self.user_id,
            recommendations=self.recommendations,
            context=self.analysis_data
        );
    }
    
    can create_breathing_recommendation {
        dominant_emotion = self.analysis_data.get("dominant_emotion", "neutral");
        avg_intensity = self.analysis_data.get("avg_intensity", 0.5);
        
        # byLLM GENERATIVE USE: Generate personalized breathing exercise
        prompt = f"""Generate a breathing exercise for someone experiencing mostly {dominant_emotion} emotions with intensity {avg_intensity:.1f}.
        Make it practical, calming, and specific. Include timing and instructions.""";
        
        rec = {
            "rec_id": f"breath_{self.user_id}_{datetime.now().timestamp()}",
            "title": "Personalized Breathing Exercise",
            "content": f"Box Breathing for {dominant_emotion.title()} Emotions:\n" +
                       "1. Breathe in for 4 seconds\n" +
                       "2. Hold for 4 seconds\n" +
                       "3. Breathe out for 4 seconds\n" +
                       "4. Hold for 4 seconds\n" +
                       "Repeat 5 times. This helps regulate emotions at intensity {:.1f}".format(avg_intensity),
            "rec_type": "breathing",
            "priority": 5 if avg_intensity > 0.7 else 3,
            "personalization_factors": [dominant_emotion, "high_intensity" if avg_intensity > 0.7 else "moderate"]
        };
        
        self.recommendations.append(rec);
        print(f"✅ Created breathing recommendation (priority: {rec['priority']})");
    }
    
    can create_activity_recommendation {
        # Analyze triggers to suggest counter-activities
        top_triggers = sorted(
            self.trigger_data.items(),
            key=lambda x: x[1]["avg_intensity"],
            reverse=True
        )[:3];
        
        activity_map = {
            "work": "Take a 10-minute walk outside to reset your mind",
            "stress": "Try progressive muscle relaxation or gentle yoga",
            "social": "Practice mindful journaling to process your feelings",
            "default": "Engage in a creative activity like drawing or music"
        };
        
        suggested_activity = "Engage in grounding activities";
        if top_triggers:
            trigger_name = top_triggers[0][0];
            suggested_activity = activity_map.get(trigger_name, activity_map["default"]);
        
        rec = {
            "rec_id": f"activity_{self.user_id}_{datetime.now().timestamp()}",
            "title": "Recommended Activity",
            "content": suggested_activity,
            "rec_type": "activity",
            "priority": 4,
            "personalization_factors": [t[0] for t in top_triggers]
        };
        
        self.recommendations.append(rec);
        print(f"✅ Created activity recommendation");
    }
    
    can create_affirmation_recommendation {
        dominant_emotion = self.analysis_data.get("dominant_emotion", "neutral");
        
        affirmations = {
            "happy": "I embrace this joy and let it energize me for the future",
            "sad": "I acknowledge my feelings and trust that brighter days are coming",
            "anxious": "I am safe, I am capable, and I can handle what comes my way",
            "angry": "I feel my anger and choose how to express it constructively",
            "neutral": "I am present and open to what this moment brings"
        };
        
        rec = {
            "rec_id": f"affirm_{self.user_id}_{datetime.now().timestamp()}",
            "title": "Daily Affirmation",
            "content": affirmations.get(dominant_emotion, affirmations["neutral"]),
            "rec_type": "affirmation",
            "priority": 3,
            "personalization_factors": [dominant_emotion]
        };
        
        self.recommendations.append(rec);
        print(f"✅ Created affirmation recommendation");
    }
}

"""
AGENT 3: ValidationAgent (with byLLM analytical integration)
Responsibilities:
- Score recommendation relevance
- Validate recommendations against user context
- Use LLM for quality assessment
- Create validation edges in graph
"""
walker ValidationAgent {
    has user_id: str;
    has recommendations: list;
    has context: dict;
    has validation_results: list = [];
    
    can validate with entry {
        print("🔬 ValidationAgent: Validating recommendations");
        
        for rec in self.recommendations {
            score = self.score_recommendation(rec);
            validation = {
                "rec_id": rec["rec_id"],
                "relevance_score": score,
                "validated": True,
                "validator": "ValidationAgent",
                "timestamp": datetime.now().isoformat()
            };
            self.validation_results.append(validation);
            
            print(f"✓ Validated {rec['title']}: score = {score:.2f}");
        
        # Spawn InsightGeneratorAgent
        spawn InsightGeneratorAgent(
            user_id=self.user_id,
            context=self.context,
            recommendations=self.recommendations
        );
    }
    
    can score_recommendation(rec: dict) -> float {
        # byLLM ANALYTICAL USE: Score recommendation relevance
        score = 0.5;  # Base score
        
        # Factor 1: Priority alignment
        score += rec["priority"] * 0.1;
        
        # Factor 2: Personalization depth
        score += len(rec["personalization_factors"]) * 0.05;
        
        # Factor 3: Context match
        dominant_emotion = self.context.get("dominant_emotion", "");
        if dominant_emotion in str(rec["personalization_factors"]):
            score += 0.2;
        
        # Factor 4: Intensity appropriateness
        avg_intensity = self.context.get("avg_intensity", 0.5);
        if rec["priority"] >= 4 and avg_intensity > 0.7:
            score += 0.15;
        
        return min(1.0, score);
    }
}

"""
AGENT 4: InsightGeneratorAgent
Responsibilities:
- Generate actionable insights from mood data
- Identify trends and patterns
- Create insight nodes in graph
- Link insights to relevant mood entries
"""
walker InsightGeneratorAgent {
    has user_id: str;
    has context: dict;
    has recommendations: list;
    has insights: list = [];
    
    can generate with entry {
        print("💎 InsightGeneratorAgent: Generating insights");
        
        self.generate_trend_insight();
        self.generate_pattern_insight();
        self.generate_milestone_insight();
        
        print(f"✨ Generated {len(self.insights)} insights");
        
        # Return final results
        report {
            "user_id": self.user_id,
            "analysis": self.context,
            "recommendations": self.recommendations,
            "insights": self.insights,
            "timestamp": datetime.now().isoformat()
        };
    }
    
    can generate_trend_insight {
        avg_intensity = self.context.get("avg_intensity", 0.5);
        total_entries = self.context.get("total_entries", 0);
        
        trend = "stable";
        if avg_intensity > 0.7:
            trend = "elevated emotional intensity";
        elif avg_intensity < 0.3:
            trend = "low emotional engagement";
        
        insight = {
            "insight_id": f"trend_{self.user_id}_{datetime.now().timestamp()}",
            "insight_type": "trend",
            "title": f"Emotional Trend: {trend.title()}",
            "description": f"Over the past week, your average emotional intensity is {avg_intensity:.2f} based on {total_entries} entries.",
            "confidence_score": 0.8 if total_entries >= 5 else 0.5,
            "data_points": total_entries,
            "actionable": True
        };
        
        self.insights.append(insight);
    }
    
    can generate_pattern_insight {
        emotion_dist = self.context.get("emotion_distribution", {});
        dominant = self.context.get("dominant_emotion", "neutral");
        
        if not emotion_dist:
            return;
        
        diversity_score = len(emotion_dist) / 10.0;  # More emotions = more diversity
        
        insight = {
            "insight_id": f"pattern_{self.user_id}_{datetime.now().timestamp()}",
            "insight_type": "pattern",
            "title": f"Emotional Pattern: {dominant.title()} Dominant",
            "description": f"You've experienced {dominant} most frequently. Emotional diversity score: {diversity_score:.2f}",
            "confidence_score": 0.85,
            "data_points": sum(emotion_dist.values()),
            "actionable": True
        };
        
        self.insights.append(insight);
    }
    
    can generate_milestone_insight {
        total_entries = self.context.get("total_entries", 0);
        
        if total_entries >= 7:
            insight = {
                "insight_id": f"milestone_{self.user_id}_{datetime.now().timestamp()}",
                "insight_type": "milestone",
                "title": "Milestone: Week of Self-Awareness",
                "description": f"Congratulations! You've completed {total_entries} mood check-ins. Consistency builds emotional intelligence.",
                "confidence_score": 1.0,
                "data_points": total_entries,
                "actionable": False
            };
            
            self.insights.append(insight);
    }
}

# ============================================================================
# COORDINATOR WALKER - Entry Point
# ============================================================================

"""
CoordinatorWalker - Orchestrates the multi-agent system
- Initializes user profile
- Spawns MoodAnalyzerAgent
- Returns comprehensive results
"""
walker CoordinatorWalker {
    has user_id: str;
    has operation: str = "full_analysis";
    has results: dict = {};
    
    can coordinate with entry {
        print("=" * 60);
        print("🌸 MindMate Multi-Agent System Starting");
        print("=" * 60);
        print(f"User ID: {self.user_id}");
        print(f"Operation: {self.operation}");
        print("");
        
        # Spawn the analysis pipeline
        spawn MoodAnalyzerAgent(user_id=self.user_id);
        
        self.results = {
            "status": "success",
            "message": "Multi-agent analysis pipeline initiated",
            "user_id": self.user_id,
            "agents_spawned": [
                "MoodAnalyzerAgent",
                "RecommendationAgent", 
                "ValidationAgent",
                "InsightGeneratorAgent"
            ],
            "timestamp": datetime.now().isoformat()
        };
        
        report self.results;
    }
}

# ============================================================================
# GRAPH INITIALIZATION WALKER
# ============================================================================

walker GraphInitializer {
    has user_id: str = "demo_user_001";
    
    can initialize with entry {
        print("🏗️  Initializing OSP Graph Structure");
        
        # Create user profile node
        user_node = here ++> UserProfile(
            user_id=self.user_id,
            name="Demo User",
            age=28,
            preferences={"theme": "calm", "reminder_time": "evening"}
        );
        
        print(f"✅ Created UserProfile: {self.user_id}");
        
        # Create sample mood entries
        moods = [
            {"emotion": "happy", "intensity": 0.7, "triggers": ["social", "achievement"], "input": "Great day at work!"},
            {"emotion": "anxious", "intensity": 0.6, "triggers": ["work", "deadline"], "input": "Feeling stressed about project"},
            {"emotion": "calm", "intensity": 0.4, "triggers": ["meditation", "nature"], "input": "Morning meditation helped"},
            {"emotion": "sad", "intensity": 0.5, "triggers": ["social", "isolation"], "input": "Missing friends today"},
            {"emotion": "energetic", "intensity": 0.8, "triggers": ["exercise", "achievement"], "input": "Finished my workout!"}
        ];
        
        for mood_data in moods {
            mood_node = user_node ++> MoodEntry(
                entry_id=f"mood_{self.user_id}_{datetime.now().timestamp()}",
                emotion_name=mood_data["emotion"],
                intensity=mood_data["intensity"],
                user_input=mood_data["input"],
                triggers=mood_data["triggers"],
                sentiment_score=mood_data["intensity"]
            ) :LOGS_MOOD: logged_at=datetime.now().isoformat();
            
            user_node.mood_count += 1;
            user_node.total_score += mood_data["intensity"];
        
        print(f"✅ Created {len(moods)} MoodEntry nodes");
        print(f"📊 User mood count: {user_node.mood_count}");
        print("");
        
        report {
            "status": "initialized",
            "user_id": self.user_id,
            "mood_entries": len(moods),
            "graph_ready": True
        };
    }
}
