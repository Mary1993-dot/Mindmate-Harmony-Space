# MindMate with byLLM Integration
# Demonstrates LLM-powered emotional analysis and personalized responses

# Import byLLM (commented for now - requires LLM setup)
# import:py from mtllm.llms, Anthropic;

node User {
    has user_id: str;
    has name: str;
    has mood_count: int = 0;
}

node Emotion {
    has emotion_id: str;
    has name: str;
    has intensity: float;
    has timestamp: str;
    has user_input: str = "";
    has llm_interpretation: str = "";
}

node Suggestion {
    has suggestion_id: str;
    has title: str;
    has content: str;
    has sug_type: str;
    has llm_generated: bool = False;
}

# AGENT 4: LLM Analyzer - Uses byLLM for emotional analysis
walker LLMAnalyzer {
    has user_text: str;
    has analysis: dict = {};
    
    # Generative use: Interpret emotional text
    can analyze_emotion_text with `root entry {
        # In real implementation with LLM:
        # llm_response = byLLM(f"""
        # Analyze this emotional statement and identify:
        # 1. Primary emotion (happy, sad, anxious, angry, calm, etc.)
        # 2. Intensity (0.0 to 1.0)
        # 3. Potential triggers
        # 4. Suggested coping strategies
        # 
        # Statement: {self.user_text}
        # 
        # Respond in JSON format.
        # """);
        
        # Simulated LLM response for demo
        self.analysis = {
            "emotion": "anxious",
            "intensity": 0.75,
            "triggers": ["work pressure", "deadline"],
            "interpretation": "User appears anxious about work-related responsibilities",
            "suggestions": [
                "Practice deep breathing exercises",
                "Break tasks into smaller, manageable steps",
                "Take a short walk to clear your mind"
            ]
        };
        
        print("LLM Analysis Complete:");
        print(f"  Emotion: {self.analysis['emotion']}");
        print(f"  Intensity: {self.analysis['intensity']}");
        print(f"  Interpretation: {self.analysis['interpretation']}");
    }
}

# AGENT 5: Empathetic Responder - Generates personalized empathetic responses
walker EmpatheticResponder {
    has emotion: str;
    has intensity: float;
    has context: str = "";
    has response: str = "";
    
    # Generative use: Create empathetic, personalized responses
    can generate_response with `root entry {
        # In real implementation:
        # self.response = byLLM(f"""
        # You are a compassionate mental health companion. Generate an empathetic,
        # supportive response for someone experiencing the following:
        # 
        # Emotion: {self.emotion}
        # Intensity: {self.intensity}
        # Context: {self.context}
        # 
        # Be warm, validating, and offer gentle encouragement.
        # """);
        
        # Simulated responses based on emotion
        responses_map = {
            "anxious": f"I hear you're feeling anxious, and that's completely valid. Anxiety can feel overwhelming, especially at intensity {self.intensity}. Remember, you've handled difficult moments before, and you have the strength to navigate this one too. Let's take it one step at a time.",
            "sad": f"I'm here with you in this sadness. It's okay to feel down sometimes - your emotions are valid. While this feeling is intense right now ({self.intensity}), know that it won't last forever. Be gentle with yourself.",
            "happy": f"It's wonderful to see you feeling happy! Embrace this joy at {self.intensity} intensity. These positive moments are precious - take time to savor them fully.",
            "stressed": f"Stress at {self.intensity} can feel like a heavy weight. I want you to know that it's okay to feel overwhelmed. You're doing your best, and that's enough. Let's find ways to lighten that load together."
        };
        
        self.response = responses_map.get(self.emotion, "I'm here to support you through whatever you're feeling. You're not alone in this.");
        
        print(f"\nEmpathetic Response:\n{self.response}\n");
    }
}

# AGENT 6: Pattern Classifier - Uses LLM to classify emotional patterns
walker PatternClassifier {
    has emotion_history: list;
    has classification: dict = {};
    
    # Analytical use: Classify and score emotional patterns
    can classify_patterns with `root entry {
        # In real implementation:
        # llm_response = byLLM(f"""
        # Analyze these emotion entries and classify the emotional pattern:
        # {self.emotion_history}
        # 
        # Classify into categories:
        # - stable_positive: Consistently positive emotions
        # - stable_negative: Consistently negative emotions  
        # - volatile: Frequent mood swings
        # - improving: Trend towards positive
        # - declining: Trend towards negative
        # 
        # Also provide a confidence score (0.0 to 1.0) and brief explanation.
        # Respond in JSON format.
        # """);
        
        # Simulated classification
        positive_count = sum(1 for e in self.emotion_history if e in ["happy", "calm", "content"]);
        negative_count = sum(1 for e in self.emotion_history if e in ["sad", "anxious", "angry"]);
        
        if positive_count > negative_count * 2 {
            pattern = "stable_positive";
            explanation = "Emotional state shows consistent positivity with occasional challenges.";
        } elif negative_count > positive_count * 2 {
            pattern = "stable_negative";
            explanation = "Emotional state reflects ongoing difficulties. Consider seeking additional support.";
        } else {
            pattern = "balanced";
            explanation = "Emotional state shows natural variation with both positive and challenging moments.";
        }
        
        self.classification = {
            "pattern": pattern,
            "confidence": 0.85,
            "explanation": explanation,
            "positive_count": positive_count,
            "negative_count": negative_count,
            "total_entries": len(self.emotion_history)
        };
        
        print("Pattern Classification:");
        print(f"  Pattern: {self.classification['pattern']}");
        print(f"  Confidence: {self.classification['confidence']}");
        print(f"  Explanation: {self.classification['explanation']}");
    }
}

# Demo walker showing byLLM integration
walker ByLLMDemo {
    can run_demo with User entry {
        print("\n" + "="*70);
        print("  MindMate byLLM Integration Demo");
        print("="*70);
        
        # Demo 1: Analyze emotional text
        print("\n[1] LLM-Powered Emotional Analysis");
        print("-" * 50);
        print('User input: "I have so much work to do and the deadline is tomorrow"');
        analyzer = LLMAnalyzer(user_text="I have so much work to do and the deadline is tomorrow");
        root spawn analyzer;
        
        # Demo 2: Generate empathetic response
        print("\n[2] Empathetic Response Generation");
        print("-" * 50);
        responder = EmpatheticResponder(
            emotion="anxious",
            intensity=0.8,
            context="Work deadline approaching"
        );
        root spawn responder;
        
        # Demo 3: Classify emotional patterns
        print("\n[3] Pattern Classification");
        print("-" * 50);
        emotion_history = ["anxious", "stressed", "calm", "happy", "anxious", "sad", "happy", "content"];
        print(f"Analyzing pattern from {len(emotion_history)} entries...");
        classifier = PatternClassifier(emotion_history=emotion_history);
        root spawn classifier;
        
        print("\n" + "="*70);
        print("  byLLM Demo Complete!");
        print("="*70);
        print("\nNote: This demo uses simulated LLM responses.");
        print("In production, connect to Anthropic, OpenAI, or other LLM providers.");
        print("="*70 + "\n");
    }
}

with entry {
    user = User(
        user_id="user_001",
        name="Demo User",
        mood_count=0
    );
    root ++> user;
    
    demo = ByLLMDemo();
    user spawn demo;
}
