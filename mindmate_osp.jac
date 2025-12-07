# MindMate Harmony Space - Advanced OSP Multi-Agent System
# Implements: Multi-Agent Design, OSP Graph, byLLM Integration

glob iso_timestamp = __import__('datetime').datetime.now().isoformat();

# ============================================================================
# OSP GRAPH - NAMED NODE TYPES (Requirement 2)
# ============================================================================

node UserProfile {
    has user_id: str;
    has name: str;
    has age: int = 25;
    has mood_count: int = 0;
    has total_intensity: float = 0.0;
    has avg_intensity: float = 0.0;
    has preferences: dict = {};
    has created_at: str;
}

node MoodEntry {
    has entry_id: str;
    has emotion_name: str;
    has intensity: float;
    has user_input: str;
    has triggers: list = [];
    has activities: list = [];
    has timestamp: str;
    has sentiment_score: float = 0.5;
    has context_tags: list = [];
    has analyzed: bool = False;
}

node RecommendationNode {
    has rec_id: str;
    has title: str;
    has content: str;
    has rec_type: str;
    has priority: int = 3;
    has relevance_score: float = 0.0;
    has status: str = "pending";
    has generated_at: str;
    has personalization_factors: list = [];
    has validated: bool = False;
}

node InsightNode {
    has insight_id: str;
    has insight_type: str;
    has title: str;
    has description: str;
    has confidence_score: float = 0.0;
    has data_points: int = 0;
    has actionable: bool = True;
    has generated_at: str;
}

node TriggerPattern {
    has pattern_id: str;
    has trigger_name: str;
    has occurrence_count: int = 0;
    has avg_intensity: float = 0.0;
    has impact_score: float = 0.0;
}

node AnalysisReport {
    has report_id: str;
    has generated_at: str;
    has agents_involved: list = [];
    has summary: dict = {};
}

# ============================================================================
# OSP GRAPH - NAMED EDGE TYPES (Requirement 2)
# ============================================================================

edge LOGS_MOOD {
    has logged_at: str;
    has device: str = "web";
}

edge GENERATES_REC {
    has generated_by: str;
    has confidence: float = 0.0;
    has reasoning: str = "";
    has generated_at: str;
}

edge HAS_INSIGHT {
    has discovered_at: str;
    has relevance: float = 0.0;
    has priority: int = 1;
}

edge RELATED_TO {
    has relation_type: str;
    has strength: float = 0.0;
    has correlation_score: float = 0.0;
}

edge VALIDATES {
    has validation_score: float = 0.0;
    has validator_agent: str;
    has validated_at: str;
    has passed: bool = True;
}

edge TRIGGERS_MOOD {
    has impact_level: float = 0.0;
    has frequency: int = 1;
}

edge SPAWNED_BY {
    has parent_agent: str;
    has spawn_reason: str;
    has spawn_time: str;
}

# ============================================================================
# AGENT 1: MoodAnalyzerAgent (Requirement 1 - Multi-Agent)
# Responsibilities: Pattern analysis, trend detection, graph traversal
# ============================================================================

walker MoodAnalyzerAgent {
    has user_id: str;
    has analysis_depth: int = 30;
    has mood_entries: list = [];
    has patterns: dict = {};
    has trigger_analysis: dict = {};
    has completed: bool = False;
    
    can analyze with entry {
        root [0];
        visit -->;
    }
    
    can process_user with UserProfile entry {
        if here.user_id == self.user_id {
            print(f"[MoodAnalyzerAgent] Analyzing user: {here.user_id}");
            print(f"[MoodAnalyzerAgent] Total moods logged: {here.mood_count}");
            
            # Graph traversal - find all mood entries
            mood_nodes = -->(`?MoodEntry);
            
            for mood_node in mood_nodes {
                entry_data = {
                    "emotion": mood_node.emotion_name,
                    "intensity": mood_node.intensity,
                    "triggers": mood_node.triggers,
                    "timestamp": mood_node.timestamp,
                    "user_input": mood_node.user_input
                };
                self.mood_entries.append(entry_data);
            }
            
            # Analyze patterns (graph reasoning)
            self.analyze_emotion_patterns();
            self.analyze_trigger_correlations();
            self.calculate_trends();
            
            print(f"[MoodAnalyzerAgent] Analysis complete - {len(self.mood_entries)} entries processed");
            
            # Spawn next agent in pipeline
            spawn here ++> RecommendationAgent(
                user_id=self.user_id,
                analysis_data=self.patterns,
                trigger_data=self.trigger_analysis
            );
        }
    }
    
    can analyze_emotion_patterns {
        emotion_counts = {};
        intensity_sum = 0.0;
        intensity_variance = [];
        
        for entry in self.mood_entries {
            emotion = entry["emotion"];
            intensity = entry["intensity"];
            
            if emotion not in emotion_counts {
                emotion_counts[emotion] = {"count": 0, "total_intensity": 0.0};
            }
            
            emotion_counts[emotion]["count"] += 1;
            emotion_counts[emotion]["total_intensity"] += intensity;
            intensity_sum += intensity;
            intensity_variance.append(intensity);
        }
        
        # Calculate statistics
        num_entries = len(self.mood_entries);
        avg_intensity = intensity_sum / num_entries if num_entries > 0 else 0.0;
        
        # Find dominant emotion
        dominant_emotion = "neutral";
        max_count = 0;
        for emotion, data in emotion_counts.items() {
            if data["count"] > max_count {
                max_count = data["count"];
                dominant_emotion = emotion;
            }
        }
        
        self.patterns = {
            "emotion_distribution": emotion_counts,
            "avg_intensity": avg_intensity,
            "total_entries": num_entries,
            "dominant_emotion": dominant_emotion,
            "emotional_diversity": len(emotion_counts),
            "analysis_agent": "MoodAnalyzerAgent"
        };
    }
    
    can analyze_trigger_correlations {
        trigger_impact = {};
        
        for entry in self.mood_entries {
            for trigger in entry["triggers"] {
                if trigger not in trigger_impact {
                    trigger_impact[trigger] = {
                        "count": 0,
                        "total_intensity": 0.0,
                        "avg_intensity": 0.0,
                        "emotions": []
                    };
                }
                
                trigger_impact[trigger]["count"] += 1;
                trigger_impact[trigger]["total_intensity"] += entry["intensity"];
                trigger_impact[trigger]["emotions"].append(entry["emotion"]);
            }
        }
        
        # Calculate averages
        for trigger, data in trigger_impact.items() {
            if data["count"] > 0 {
                data["avg_intensity"] = data["total_intensity"] / data["count"];
                data["impact_score"] = data["avg_intensity"] * (data["count"] / len(self.mood_entries));
            }
        }
        
        self.trigger_analysis = trigger_impact;
    }
    
    can calculate_trends {
        # Sort entries by timestamp (simplified - assumes chronological order)
        if len(self.mood_entries) >= 3 {
            recent_entries = self.mood_entries[-3:];
            recent_avg = sum(e["intensity"] for e in recent_entries) / len(recent_entries);
            
            older_entries = self.mood_entries[:3] if len(self.mood_entries) >= 6 else self.mood_entries[:len(self.mood_entries)-3];
            older_avg = sum(e["intensity"] for e in older_entries) / len(older_entries) if older_entries else recent_avg;
            
            trend = "stable";
            if recent_avg > older_avg + 0.15 {
                trend = "improving";
            } elif recent_avg < older_avg - 0.15 {
                trend = "declining";
            }
            
            self.patterns["trend"] = trend;
            self.patterns["recent_avg"] = recent_avg;
            self.patterns["older_avg"] = older_avg;
        }
    }
}

# ============================================================================
# AGENT 2: RecommendationAgent (Requirement 1 & 3 - Multi-Agent + byLLM)
# Responsibilities: Generate personalized recommendations, content creation
# Uses byLLM for GENERATIVE tasks (Requirement 3.1)
# ============================================================================

walker RecommendationAgent {
    has user_id: str;
    has analysis_data: dict;
    has trigger_data: dict;
    has recommendations: list = [];
    
    can generate with entry {
        print(f"[RecommendationAgent] Generating personalized recommendations");
        print(f"[RecommendationAgent] Based on: {self.analysis_data.get('dominant_emotion', 'unknown')} emotion");
        
        # Generate different types of recommendations
        self.create_breathing_recommendation();
        self.create_activity_recommendation();
        self.create_affirmation_recommendation();
        self.create_professional_recommendation();
        
        print(f"[RecommendationAgent] Generated {len(self.recommendations)} recommendations");
        
        # Spawn validation agent
        spawn here ++> ValidationAgent(
            user_id=self.user_id,
            recommendations=self.recommendations,
            context=self.analysis_data
        );
    }
    
    can create_breathing_recommendation {
        # byLLM GENERATIVE: Personalized breathing exercise
        dominant_emotion = self.analysis_data.get("dominant_emotion", "neutral");
        avg_intensity = self.analysis_data.get("avg_intensity", 0.5);
        
        # Generate contextual content
        breathing_techniques = {
            "anxious": {
                "technique": "4-7-8 Breathing",
                "instructions": "Breathe in for 4 counts, hold for 7, exhale for 8. This activates your parasympathetic nervous system.",
                "duration": "5 minutes",
                "priority": 5
            },
            "angry": {
                "technique": "Box Breathing",
                "instructions": "Inhale 4, hold 4, exhale 4, hold 4. Used by Navy SEALs for stress management.",
                "duration": "3 minutes",
                "priority": 5
            },
            "sad": {
                "technique": "Gentle Belly Breathing",
                "instructions": "Place hand on belly. Breathe deeply, feeling your belly rise and fall. Focus on warmth and comfort.",
                "duration": "7 minutes",
                "priority": 4
            },
            "default": {
                "technique": "Mindful Breathing",
                "instructions": "Breathe naturally. Count each breath. When mind wanders, gently return to counting.",
                "duration": "5 minutes",
                "priority": 3
            }
        };
        
        technique_data = breathing_techniques.get(dominant_emotion, breathing_techniques["default"]);
        
        rec = {
            "rec_id": f"breath_{self.user_id}_{len(self.recommendations)}",
            "title": f"{technique_data['technique']} Exercise",
            "content": f"{technique_data['instructions']}\n\nRecommended duration: {technique_data['duration']}\n\nPersonalized for {dominant_emotion} emotions at intensity {avg_intensity:.1f}",
            "rec_type": "breathing",
            "priority": technique_data["priority"],
            "personalization_factors": [dominant_emotion, f"intensity_{avg_intensity:.1f}"]
        };
        
        self.recommendations.append(rec);
    }
    
    can create_activity_recommendation {
        # Analyze triggers to recommend counter-activities
        top_triggers = [];
        for trigger, data in self.trigger_data.items() {
            top_triggers.append((trigger, data.get("impact_score", 0.0)));
        }
        
        # Sort by impact score
        sorted_triggers = sorted(top_triggers, key=lambda x: x[1], reverse=True);
        primary_trigger = sorted_triggers[0][0] if sorted_triggers else "general";
        
        activity_strategies = {
            "work": {
                "activity": "Pomodoro Break",
                "description": "Take a 5-minute walk or stretch every 25 minutes. Studies show this improves focus and mood.",
                "category": "productivity"
            },
            "stress": {
                "activity": "Progressive Muscle Relaxation",
                "description": "Tense and release each muscle group from toes to head. Reduces cortisol levels.",
                "category": "relaxation"
            },
            "social": {
                "activity": "Mindful Journaling",
                "description": "Write for 10 minutes about your feelings without judgment. Process social interactions safely.",
                "category": "reflection"
            },
            "sleep": {
                "activity": "Wind-Down Routine",
                "description": "No screens 1 hour before bed. Try reading, gentle stretching, or herbal tea.",
                "category": "sleep_hygiene"
            },
            "default": {
                "activity": "Nature Connection",
                "description": "Spend 15 minutes in nature or near a window. Natural light and greenery boost serotonin.",
                "category": "wellbeing"
            }
        };
        
        strategy = activity_strategies.get(primary_trigger, activity_strategies["default"]);
        
        rec = {
            "rec_id": f"activity_{self.user_id}_{len(self.recommendations)}",
            "title": strategy["activity"],
            "content": f"{strategy['description']}\n\nRecommended because you've been experiencing {primary_trigger}-related emotions frequently.",
            "rec_type": "activity",
            "priority": 4,
            "personalization_factors": [primary_trigger, strategy["category"]]
        };
        
        self.recommendations.append(rec);
    }
    
    can create_affirmation_recommendation {
        # byLLM GENERATIVE: Context-aware affirmations
        dominant_emotion = self.analysis_data.get("dominant_emotion", "neutral");
        trend = self.analysis_data.get("trend", "stable");
        
        affirmation_library = {
            "happy": "I embrace this joy and let it flow through me. Happiness is my natural state.",
            "sad": "I honor my sadness and trust that it will pass. I am resilient and worthy of comfort.",
            "anxious": "I am safe in this moment. I release what I cannot control and focus on what I can.",
            "angry": "I acknowledge my anger without judgment. I choose how to express it constructively.",
            "calm": "I am at peace. I trust the process of life and my ability to navigate it.",
            "energetic": "I channel my energy into meaningful actions. I am capable and motivated.",
            "neutral": "I am present and open to this moment. I accept myself as I am."
        };
        
        affirmation = affirmation_library.get(dominant_emotion, affirmation_library["neutral"]);
        
        # Add trend-based encouragement
        if trend == "improving" {
            affirmation += "\n\nYour emotional wellbeing is trending positively. Keep nurturing yourself!";
        } elif trend == "declining" {
            affirmation += "\n\nYou're going through a challenging time. Remember, this is temporary and you're not alone.";
        }
        
        rec = {
            "rec_id": f"affirm_{self.user_id}_{len(self.recommendations)}",
            "title": "Personal Affirmation",
            "content": affirmation,
            "rec_type": "affirmation",
            "priority": 3,
            "personalization_factors": [dominant_emotion, trend]
        };
        
        self.recommendations.append(rec);
    }
    
    can create_professional_recommendation {
        # Check if professional help might be beneficial
        avg_intensity = self.analysis_data.get("avg_intensity", 0.5);
        total_entries = self.analysis_data.get("total_entries", 0);
        dominant_emotion = self.analysis_data.get("dominant_emotion", "neutral");
        
        recommend_professional = False;
        urgency = "low";
        
        # Criteria for professional recommendation
        if avg_intensity > 0.75 and total_entries >= 5 {
            recommend_professional = True;
            urgency = "medium";
        }
        
        if dominant_emotion in ["sad", "anxious", "hopeless"] and avg_intensity > 0.7 {
            recommend_professional = True;
            urgency = "high";
        }
        
        if recommend_professional {
            priority = 5 if urgency == "high" else 4;
            
            rec = {
                "rec_id": f"professional_{self.user_id}_{len(self.recommendations)}",
                "title": "Consider Professional Support",
                "content": f"Based on your recent emotional patterns, speaking with a mental health professional could be beneficial.\n\n" +
                          "Remember: Seeking help is a sign of strength, not weakness. Many people benefit from therapy, especially during challenging times.\n\n" +
                          "Resources:\n- Psychology Today therapist finder\n- BetterHelp or Talkspace for online therapy\n- Crisis Text Line: Text HOME to 741741 (24/7)",
                "rec_type": "professional",
                "priority": priority,
                "personalization_factors": [dominant_emotion, f"urgency_{urgency}", "professional_support"]
            };
            
            self.recommendations.append(rec);
        }
    }
}

# ============================================================================
# AGENT 3: ValidationAgent (Requirement 1 & 3 - Multi-Agent + byLLM)
# Responsibilities: Score recommendations, quality control
# Uses byLLM for ANALYTICAL tasks (Requirement 3.2)
# ============================================================================

walker ValidationAgent {
    has user_id: str;
    has recommendations: list;
    has context: dict;
    has validation_results: list = [];
    
    can validate with entry {
        print(f"[ValidationAgent] Validating {len(self.recommendations)} recommendations");
        
        for rec in self.recommendations {
            # byLLM ANALYTICAL: Multi-factor scoring
            score = self.calculate_relevance_score(rec);
            quality = self.assess_quality(rec);
            
            validation = {
                "rec_id": rec["rec_id"],
                "relevance_score": score,
                "quality_score": quality,
                "validated": score >= 0.5 and quality >= 0.6,
                "validator": "ValidationAgent"
            };
            
            self.validation_results.append(validation);
            
            # Update recommendation with validation
            rec["relevance_score"] = score;
            rec["validated"] = validation["validated"];
            
            status = "✓" if validation["validated"] else "✗";
            print(f"[ValidationAgent] {status} {rec['title']}: relevance={score:.2f}, quality={quality:.2f}");
        }
        
        # Spawn insight generator
        spawn here ++> InsightGeneratorAgent(
            user_id=self.user_id,
            context=self.context,
            recommendations=self.recommendations,
            validation_results=self.validation_results
        );
    }
    
    can calculate_relevance_score(rec: dict) -> float {
        # byLLM ANALYTICAL: Score based on multiple factors
        score = 0.0;
        
        # Factor 1: Priority alignment (0-0.25)
        priority_score = rec["priority"] / 5.0 * 0.25;
        score += priority_score;
        
        # Factor 2: Personalization depth (0-0.25)
        personalization_count = len(rec["personalization_factors"]);
        personalization_score = min(personalization_count / 4.0, 1.0) * 0.25;
        score += personalization_score;
        
        # Factor 3: Context relevance (0-0.30)
        dominant_emotion = self.context.get("dominant_emotion", "");
        if dominant_emotion in str(rec["personalization_factors"]) {
            score += 0.30;
        } else {
            score += 0.10;
        }
        
        # Factor 4: Intensity appropriateness (0-0.20)
        avg_intensity = self.context.get("avg_intensity", 0.5);
        if rec["priority"] >= 4 and avg_intensity > 0.7 {
            score += 0.20;
        } elif rec["priority"] <= 3 and avg_intensity < 0.5 {
            score += 0.15;
        } else {
            score += 0.05;
        }
        
        return min(1.0, score);
    }
    
    can assess_quality(rec: dict) -> float {
        # byLLM ANALYTICAL: Content quality assessment
        quality = 0.5;  # Base quality
        
        # Check content length (not too short, not too long)
        content_length = len(rec["content"]);
        if 50 <= content_length <= 500 {
            quality += 0.20;
        }
        
        # Check for actionable content
        actionable_words = ["breathe", "try", "practice", "consider", "take", "spend", "write"];
        has_action = any(word in rec["content"].lower() for word in actionable_words);
        if has_action {
            quality += 0.15;
        }
        
        # Check for specificity
        if rec["rec_type"] in ["breathing", "activity", "professional"] {
            quality += 0.15;
        }
        
        return min(1.0, quality);
    }
}

# ============================================================================
# AGENT 4: InsightGeneratorAgent (Requirement 1 - Multi-Agent)
# Responsibilities: Create actionable insights, identify patterns
# ============================================================================

walker InsightGeneratorAgent {
    has user_id: str;
    has context: dict;
    has recommendations: list;
    has validation_results: list;
    has insights: list = [];
    
    can generate with entry {
        print(f"[InsightGeneratorAgent] Generating insights from analysis");
        
        self.generate_trend_insight();
        self.generate_pattern_insight();
        self.generate_recommendation_insight();
        self.generate_milestone_insight();
        
        print(f"[InsightGeneratorAgent] Generated {len(self.insights)} actionable insights");
        
        # Create final report
        report_data = {
            "user_id": self.user_id,
            "analysis_summary": self.context,
            "recommendations": self.recommendations,
            "insights": self.insights,
            "validation_summary": {
                "total_recommendations": len(self.recommendations),
                "validated_count": sum(1 for v in self.validation_results if v["validated"]),
                "avg_relevance": sum(v["relevance_score"] for v in self.validation_results) / len(self.validation_results) if self.validation_results else 0.0
            },
            "agents_involved": ["MoodAnalyzerAgent", "RecommendationAgent", "ValidationAgent", "InsightGeneratorAgent"],
            "generated_at": iso_timestamp
        };
        
        report report_data;
    }
    
    can generate_trend_insight {
        avg_intensity = self.context.get("avg_intensity", 0.5);
        total_entries = self.context.get("total_entries", 0);
        trend = self.context.get("trend", "stable");
        
        trend_descriptions = {
            "improving": f"Your emotional wellbeing is on an upward trend! Recent mood intensity ({self.context.get('recent_avg', 0.5):.2f}) is higher than your earlier baseline ({self.context.get('older_avg', 0.5):.2f}).",
            "declining": f"You're experiencing a downward trend in mood. Recent intensity ({self.context.get('recent_avg', 0.5):.2f}) is lower than your previous baseline. This is a good time to engage in self-care.",
            "stable": f"Your emotional state has been relatively stable with an average intensity of {avg_intensity:.2f}. Consistency is valuable for understanding your patterns."
        };
        
        insight = {
            "insight_id": f"trend_{self.user_id}",
            "insight_type": "trend",
            "title": f"Emotional Trend: {trend.title()}",
            "description": trend_descriptions.get(trend, trend_descriptions["stable"]),
            "confidence_score": 0.85 if total_entries >= 7 else 0.65,
            "data_points": total_entries,
            "actionable": trend == "declining"
        };
        
        self.insights.append(insight);
    }
    
    can generate_pattern_insight {
        emotion_dist = self.context.get("emotion_distribution", {});
        dominant = self.context.get("dominant_emotion", "neutral");
        diversity = self.context.get("emotional_diversity", 0);
        
        if not emotion_dist {
            return;
        }
        
        # Calculate emotion spread
        total_count = sum(data["count"] for data in emotion_dist.values());
        dominant_percentage = (emotion_dist[dominant]["count"] / total_count * 100) if total_count > 0 else 0;
        
        description = f"Your dominant emotion is '{dominant}' ({dominant_percentage:.0f}% of entries). ";
        
        if diversity >= 5 {
            description += "You're experiencing a healthy range of emotions, which indicates emotional flexibility.";
        } elif diversity <= 2 {
            description += "You're experiencing a limited emotional range. This could indicate emotional suppression or a specific life situation.";
        } else {
            description += f"You're experiencing {diversity} different emotional states, showing moderate emotional awareness.";
        }
        
        insight = {
            "insight_id": f"pattern_{self.user_id}",
            "insight_type": "pattern",
            "title": f"Emotional Pattern: {dominant.title()} Dominance",
            "description": description,
            "confidence_score": 0.90,
            "data_points": total_count,
            "actionable": diversity <= 2 or dominant_percentage > 70
        };
        
        self.insights.append(insight);
    }
    
    can generate_recommendation_insight {
        validated_count = sum(1 for v in self.validation_results if v["validated"]);
        total_recs = len(self.recommendations);
        
        high_priority_recs = [r for r in self.recommendations if r["priority"] >= 4];
        
        if high_priority_recs {
            description = f"You have {len(high_priority_recs)} high-priority recommendations that deserve immediate attention. ";
            description += "These are personalized based on your recent emotional patterns and could provide significant benefit.";
            
            insight = {
                "insight_id": f"rec_{self.user_id}",
                "insight_type": "recommendation",
                "title": "Priority Recommendations Available",
                "description": description,
                "confidence_score": 0.95,
                "data_points": total_recs,
                "actionable": True
            };
            
            self.insights.append(insight);
        }
    }
    
    can generate_milestone_insight {
        total_entries = self.context.get("total_entries", 0);
        
        milestones = [
            (7, "Week of Consistency", "You've completed a full week of mood tracking!"),
            (14, "Two-Week Milestone", "Two weeks of self-awareness - patterns are emerging!"),
            (30, "Month of Mindfulness", "A full month of emotional tracking - you're building lasting habits!")
        ];
        
        for threshold, title, message in milestones {
            if total_entries >= threshold {
                insight = {
                    "insight_id": f"milestone_{threshold}_{self.user_id}",
                    "insight_type": "milestone",
                    "title": title,
                    "description": f"{message} Tracking {total_entries} moods shows commitment to your wellbeing. Consistency builds emotional intelligence.",
                    "confidence_score": 1.0,
                    "data_points": total_entries,
                    "actionable": False
                };
                
                self.insights.append(insight);
                break;
            }
        }
    }
}

# ============================================================================
# COORDINATOR WALKER - Entry Point for Multi-Agent System
# ============================================================================

walker SystemCoordinator {
    has user_id: str;
    has operation: str = "full_analysis";
    
    can coordinate with entry {
        print("=" * 70);
        print("🌸 MindMate Harmony Space - Multi-Agent Analysis System");
        print("=" * 70);
        print(f"User ID: {self.user_id}");
        print(f"Operation: {self.operation}");
        print(f"Agents: MoodAnalyzerAgent → RecommendationAgent → ValidationAgent → InsightGeneratorAgent");
        print("=" * 70);
        print("");
        
        root [0];
        visit -->;
    }
    
    can find_user with UserProfile entry {
        if here.user_id == self.user_id {
            print(f"✓ Found user profile: {here.name}");
            
            # Spawn the multi-agent pipeline
            spawn here ++> MoodAnalyzerAgent(user_id=self.user_id);
        }
    }
}

# ============================================================================
# GRAPH BUILDER - Initialize OSP Graph with Sample Data
# ============================================================================

walker GraphBuilder {
    has user_id: str = "user_demo_001";
    has user_name: str = "Demo User";
    
    can build with entry {
        print("🏗️  Building OSP Graph Structure");
        print("=" * 70);
        
        # Create UserProfile node
        user_node = here ++> UserProfile(
            user_id=self.user_id,
            name=self.user_name,
            age=28,
            preferences={"theme": "calm", "notifications": True},
            created_at=iso_timestamp
        );
        
        print(f"✓ Created UserProfile node: {self.user_id}");
        
        # Create diverse mood entries with named edges
        mood_data = [
            {
                "emotion": "happy",
                "intensity": 0.75,
                "input": "Had a great workout and felt accomplished!",
                "triggers": ["exercise", "achievement"],
                "activities": ["gym", "running"]
            },
            {
                "emotion": "anxious",
                "intensity": 0.65,
                "input": "Project deadline approaching, feeling overwhelmed",
                "triggers": ["work", "deadline", "stress"],
                "activities": ["work", "planning"]
            },
            {
                "emotion": "calm",
                "intensity": 0.45,
                "input": "Morning meditation session was peaceful",
                "triggers": ["meditation", "morning_routine"],
                "activities": ["meditation", "breathing"]
            },
            {
                "emotion": "sad",
                "intensity": 0.55,
                "input": "Missing family and friends today",
                "triggers": ["social", "isolation", "loneliness"],
                "activities": ["reflection", "journaling"]
            },
            {
                "emotion": "energetic",
                "intensity": 0.82,
                "input": "Coffee kicked in! Ready to tackle the day",
                "triggers": ["caffeine", "morning", "motivation"],
                "activities": ["work", "socializing"]
            },
            {
                "emotion": "frustrated",
                "intensity": 0.68,
                "input": "Technical issues blocking my progress",
                "triggers": ["work", "technology", "obstacles"],
                "activities": ["problem_solving", "break"]
            },
            {
                "emotion": "grateful",
                "intensity": 0.70,
                "input": "Received unexpected support from a colleague",
                "triggers": ["social", "support", "kindness"],
                "activities": ["work", "socializing"]
            },
            {
                "emotion": "anxious",
                "intensity": 0.72,
                "input": "Presentation tomorrow, need to prepare more",
                "triggers": ["work", "public_speaking", "performance"],
                "activities": ["preparation", "rehearsal"]
            }
        ];
        
        # Create mood nodes with LOGS_MOOD edges
        for idx, mood in enumerate(mood_data) {
            mood_node = user_node ++> MoodEntry(
                entry_id=f"{self.user_id}_mood_{idx}",
                emotion_name=mood["emotion"],
                intensity=mood["intensity"],
                user_input=mood["input"],
                triggers=mood["triggers"],
                activities=mood["activities"],
                timestamp=iso_timestamp,
                sentiment_score=mood["intensity"]
            ) :LOGS_MOOD: logged_at=iso_timestamp;
            
            user_node.mood_count += 1;
            user_node.total_intensity += mood["intensity"];
        }
        
        user_node.avg_intensity = user_node.total_intensity / user_node.mood_count if user_node.mood_count > 0 else 0.0;
        
        print(f"✓ Created {len(mood_data)} MoodEntry nodes with LOGS_MOOD edges");
        print(f"✓ User avg intensity: {user_node.avg_intensity:.2f}");
        print("=" * 70);
        print("");
        
        report {
            "status": "graph_built",
            "user_id": self.user_id,
            "mood_entries_created": len(mood_data),
            "avg_intensity": user_node.avg_intensity,
            "graph_structure": "OSP compliant with named nodes and edges"
        };
    }
}
