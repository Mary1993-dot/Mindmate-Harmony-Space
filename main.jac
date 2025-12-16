# MindMate Harmony Space - AI Mental-Wellbeing Companion
# Simplified OSP Multi-Agent System

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
}

node Trigger {
    has trigger_id: str;
    has name: str;
    has count: int = 1;
}

node Activity {
    has activity_id: str;
    has name: str;
    has times_done: int = 1;
}

node Suggestion {
    has suggestion_id: str;
    has title: str;
    has content: str;
    has sug_type: str;
}

edge experiences {}
edge triggers_emotion {}
edge helps_with {}
edge performs {}

# AGENT 1: MoodLogger - Logs emotional states
walker MoodLogger {
    has emotion_name: str;
    has intensity: float;
    has user_input: str = "";
    has trigger_names: list = [];
    has activity_names: list = [];
    has result: dict = {};

    can log_mood with User entry {
        here.mood_count += 1;
        local_id = here.mood_count;
        
        emotion_node = Emotion(
            emotion_id="emotion_" + str(local_id),
            name=self.emotion_name,
            intensity=self.intensity,
            timestamp="2025-11-23T" + str(10 + local_id) + ":00:00",
            user_input=self.user_input
        );
        
        root ++> emotion_node;
        here ++> emotion_node;
        
        for trig_name in self.trigger_names {
            here.mood_count += 1;
            trigger_node = Trigger(
                trigger_id="trigger_" + str(here.mood_count),
                name=str(trig_name),
                count=1
            );
            root ++> trigger_node;
        }
        
        for act_name in self.activity_names {
            here.mood_count += 1;
            activity_node = Activity(
                activity_id="activity_" + str(here.mood_count),
                name=str(act_name),
                times_done=1
            );
            root ++> activity_node;
        }
        
        self.result = {
            "status": "success",
            "emotion": emotion_node.name,
            "intensity": emotion_node.intensity,
            "timestamp": emotion_node.timestamp
        };
    }
}

# AGENT 2: TrendAnalyzer - Analyzes patterns
walker TrendAnalyzer {
    has analysis_result: dict = {};

    can analyze with User entry {
        insights = [];
        insights.append(f"User {here.name} has logged {here.mood_count} mood entries.");
        
        if here.mood_count > 0 {
            insights.append("Continue tracking emotions to identify patterns.");
        } else {
            insights.append("Start logging emotions to build insights!");
        }
        
        self.analysis_result = {
            "user_id": here.user_id,
            "total_entries": here.mood_count,
            "insights": insights
        };
    }
}

# AGENT 3: SupportiveAdvisor - Generates coping strategies
walker SupportiveAdvisor {
    has current_emotion: str;
    has current_intensity: float;
    has suggestions: list = [];

    can advise with User entry {
        if self.current_intensity > 0.7 and self.current_emotion in ["anxious", "stressed"] {
            here.mood_count += 1;
            sug = Suggestion(
                suggestion_id="sug_" + str(here.mood_count),
                title="Breathing Exercise",
                content="Try 4-7-8 breathing: In for 4, hold for 7, out for 8. Repeat 4 times.",
                sug_type="breathing"
            );
            root ++> sug;
            self.suggestions.append({
                "title": sug.title,
                "content": sug.content,
                "type": sug.sug_type
            });
        }
        
        if self.current_emotion in ["sad", "lonely"] {
            here.mood_count += 1;
            sug = Suggestion(
                suggestion_id="sug_" + str(here.mood_count),
                title="Journaling Prompt",
                content="Write for 10 min: What am I feeling? What caused it? What do I need?",
                sug_type="journaling"
            );
            root ++> sug;
            self.suggestions.append({
                "title": sug.title,
                "content": sug.content,
                "type": sug.sug_type
            });
        }
        
        here.mood_count += 1;
        affirmation = Suggestion(
            suggestion_id="sug_" + str(here.mood_count),
            title="Daily Affirmation",
            content="You are doing your best, and that is enough.",
            sug_type="affirmation"
        );
        root ++> affirmation;
        self.suggestions.append({
            "title": affirmation.title,
            "content": affirmation.content,
            "type": affirmation.sug_type
        });
    }
}

walker Demo {
    can run_demo with User entry {
        print("\n" + "="*70);
        print("  MindMate Harmony Space - AI Mental-Wellbeing Companion");
        print("="*70);
        print("\nMulti-Agent System Demo\n");
        
        print("[1] Logging anxious mood");
        logger1 = MoodLogger(
            emotion_name="anxious",
            intensity=0.8,
            user_input="Anxious about work presentation",
            trigger_names=["work deadline", "public speaking"],
            activity_names=["meditation", "deep breathing"]
        );
        here spawn logger1;
        print(f"    Logged: {logger1.result['emotion']} (intensity: {logger1.result['intensity']})");
        
        print("\n[2] Logging happy mood");
        logger2 = MoodLogger(
            emotion_name="happy",
            intensity=0.9,
            user_input="Great after morning run!",
            trigger_names=["exercise"],
            activity_names=["running"]
        );
        here spawn logger2;
        print(f"    Logged: {logger2.result['emotion']} (intensity: {logger2.result['intensity']})");
        
        print("\n[3] Logging sad mood");
        logger3 = MoodLogger(
            emotion_name="sad",
            intensity=0.6,
            user_input="Feeling down tonight",
            trigger_names=["loneliness"],
            activity_names=["journaling"]
        );
        here spawn logger3;
        print(f"    Logged: {logger3.result['emotion']} (intensity: {logger3.result['intensity']})");
        
        logger4 = MoodLogger(emotion_name="stressed", intensity=0.7, user_input="Too much to do", trigger_names=["work"], activity_names=["walking"]);
        here spawn logger4;
        
        logger5 = MoodLogger(emotion_name="calm", intensity=0.8, user_input="Finally relaxed", trigger_names=["quiet"], activity_names=["meditation"]);
        here spawn logger5;
        
        print("\n[AGENT: TrendAnalyzer]");
        analyzer = TrendAnalyzer();
        here spawn analyzer;
        print(f"    Total entries: {analyzer.analysis_result['total_entries']}");
        print("    Insights:");
        for insight in analyzer.analysis_result['insights'] {
            print(f"      - {insight}");
        }
        
        print("\n[AGENT: SupportiveAdvisor]");
        print("    Current state: Anxious (0.8)\n");
        advisor = SupportiveAdvisor(
            current_emotion="anxious",
            current_intensity=0.8
        );
        here spawn advisor;
        print(f"    Generated {len(advisor.suggestions)} suggestions:");
        for sug in advisor.suggestions {
            print(f"      - {sug['title']} ({sug['type']}): {sug['content']}");
        }
        
        print("\n" + "="*70);
        print("  Demo Complete!");
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
    
    print("\nMindMate Harmony Space");
    print("Multi-Agent Mental Wellbeing Companion\n");
    print("Agents: MoodLogger, TrendAnalyzer, SupportiveAdvisor\n");
    
    demo = Demo();
    user spawn demo;
}
