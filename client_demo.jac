# MindMate Client Example
# Demonstrates frontend/client interactions using Spawn()

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
}

node Suggestion {
    has suggestion_id: str;
    has title: str;
    has content: str;
    has sug_type: str;
}

# Simplified walkers for client demo
walker MoodLogger {
    has emotion_name: str;
    has intensity: float;
    has result: dict = {};

    can log_mood with User entry {
        here.mood_count += 1;
        emotion = Emotion(
            emotion_id="e_" + str(here.mood_count),
            name=self.emotion_name,
            intensity=self.intensity,
            timestamp="2025-11-23T10:00:00"
        );
        root ++> emotion;
        here ++> emotion;
        self.result = {
            "success": True,
            "emotion": emotion.name,
            "intensity": emotion.intensity,
            "message": f"Logged {emotion.name} successfully"
        };
    }
}

walker TrendAnalyzer {
    has analysis_result: dict = {};

    can analyze with User entry {
        self.analysis_result = {
            "total_entries": here.mood_count,
            "user_name": here.name,
            "status": "complete"
        };
    }
}

walker SupportiveAdvisor {
    has current_emotion: str;
    has suggestions: list = [];

    can advise with User entry {
        here.mood_count += 1;
        sug = Suggestion(
            suggestion_id="s_" + str(here.mood_count),
            title="Take a Deep Breath",
            content="Try 4-7-8 breathing for calmness",
            sug_type="breathing"
        );
        root ++> sug;
        self.suggestions.append({
            "title": sug.title,
            "content": sug.content
        });
    }
}

# CLIENT 1: Mobile App Interface
walker MobileClient {
    can simulate_mobile_app with User entry {
        print("\n" + "="*70);
        print("  MOBILE CLIENT DEMO - MindMate App");
        print("="*70);
        
        # User logs mood via emoji wheel interface
        print("\n[User Action: Taps 😰 Anxious Emoji]");
        print("  Intensity slider: 0.7");
        
        logger = MoodLogger(
            emotion_name="anxious",
            intensity=0.7
        );
        here spawn logger;
        
        if logger.result['success'] {
            print(f"  ✓ {logger.result['message']}");
            print(f"  Timestamp: {logger.result.get('timestamp', 'N/A')}");
        }
        
        # User requests insights
        print("\n[User Action: Taps 'View Insights' Button]");
        analyzer = TrendAnalyzer();
        here spawn analyzer;
        print(f"  Total mood entries: {analyzer.analysis_result['total_entries']}");
        print("  Displaying trend chart...");
        
        # User requests support
        print("\n[User Action: Taps 'Get Support' Button]");
        advisor = SupportiveAdvisor(current_emotion="anxious");
        here spawn advisor;
        print(f"  Showing {len(advisor.suggestions)} suggestions:");
        for sug in advisor.suggestions {
            print(f"    💡 {sug['title']}");
            print(f"       {sug['content']}");
        }
        
        print("\n  [Push Notification Scheduled]");
        print("  'Remember to check in with your emotions tomorrow'");
        
        print("\n" + "="*70 + "\n");
    }
}

# CLIENT 2: Web Dashboard Interface
walker WebDashboard {
    can simulate_web_dashboard with User entry {
        print("\n" + "="*70);
        print("  WEB DASHBOARD DEMO - MindMate Portal");
        print("="*70);
        
        print("\n[Dashboard Loading...]");
        print(f"  User: {here.name} ({here.user_id})");
        
        # Quick mood log widget
        print("\n[Widget: Quick Mood Log]");
        print("  User types: 'Feeling stressed about deadline'");
        
        logger = MoodLogger(
            emotion_name="stressed",
            intensity=0.8
        );
        here spawn logger;
        print(f"  ✓ Mood logged: {logger.result['emotion']}");
        
        # Analytics panel
        print("\n[Panel: Weekly Analytics]");
        analyzer = TrendAnalyzer();
        here spawn analyzer;
        total_entries = analyzer.analysis_result['total_entries'];
        print("  ┌─────────────────────────────┐");
        print(f"  │ Total Entries:         {total_entries} │");
        print("  │ Most Common: Anxious        │");
        print("  │ Trend: Improving            │");
        print("  └─────────────────────────────┘");
        
        # Recommendations sidebar
        print("\n[Sidebar: Personalized Recommendations]");
        advisor = SupportiveAdvisor(current_emotion="stressed");
        here spawn advisor;
        print("  Recommended Actions:");
        idx = 0;
        for sug in advisor.suggestions {
            idx += 1;
            print(f"    {idx}. [{sug['title']}]");
            print(f"       {sug['content']}");
        }
        
        print("\n" + "="*70 + "\n");
    }
}

# CLIENT 3: Voice Assistant Integration
walker VoiceAssistant {
    can simulate_voice_interaction with User entry {
        print("\n" + "="*70);
        print("  VOICE ASSISTANT DEMO - 'Hey MindMate'");
        print("="*70);
        
        print("\n[User]: 'Hey MindMate, I'm feeling really happy today!'");
        print("[MindMate]: 'That's wonderful! Let me log that for you.'");
        
        logger = MoodLogger(
            emotion_name="happy",
            intensity=0.9
        );
        here spawn logger;
        
        print(f"[MindMate]: '{logger.result['message']}. ");
        print("             Would you like to know your weekly summary?'");
        
        print("\n[User]: 'Yes, show me my summary'");
        print("[MindMate]: 'Analyzing your emotional patterns...'");
        
        analyzer = TrendAnalyzer();
        here spawn analyzer;
        
        print(f"[MindMate]: 'You've logged {analyzer.analysis_result['total_entries']} moods this week.");
        print("             Your emotional wellbeing is looking positive!");
        print("             Keep up the great work!'");
        
        print("\n[User]: 'Give me a daily affirmation'");
        advisor = SupportiveAdvisor(current_emotion="happy");
        here spawn advisor;
        
        if len(advisor.suggestions) > 0 {
            print(f"[MindMate]: '{advisor.suggestions[0]['content']}'");
        }
        
        print("\n" + "="*70 + "\n");
    }
}

# CLIENT 4: Wearable Integration
walker WearableDevice {
    can simulate_smartwatch with User entry {
        print("\n" + "="*70);
        print("  WEARABLE DEMO - MindMate Watch App");
        print("="*70);
        
        print("\n[Smartwatch detects elevated heart rate]");
        print("  Heart Rate: 95 BPM (elevated)");
        print("  Time: 2:30 PM");
        
        print("\n[Watch Notification]");
        print("  'We noticed your heart rate is elevated.");
        print("   Would you like to log your current mood?'");
        
        print("\n[User taps: 'Yes - I'm stressed']");
        
        logger = MoodLogger(
            emotion_name="stressed",
            intensity=0.7
        );
        here spawn logger;
        
        print(f"  ✓ {logger.result['message']}");
        
        print("\n[Watch displays breathing exercise]");
        advisor = SupportiveAdvisor(current_emotion="stressed");
        here spawn advisor;
        
        print("  ┌─────────────────────────┐");
        print("  │  🫁 Breathe with me:   │");
        print("  │                         │");
        print("  │  Inhale: ●●●●          │");
        print("  │  Hold:   ●●●●●●●       │");
        print("  │  Exhale: ●●●●●●●●      │");
        print("  └─────────────────────────┘");
        
        print("\n[Haptic feedback guides breathing]");
        print("  Vibration pattern: Inhale...Hold...Exhale...");
        
        print("\n" + "="*70 + "\n");
    }
}

# Main demo runner
walker ClientDemo {
    can run_all_clients with User entry {
        print("\n╔════════════════════════════════════════════════════════════════════╗");
        print("║     MindMate Harmony Space - Client Interface Demonstrations       ║");
        print("╚════════════════════════════════════════════════════════════════════╝");
        
        # Run all client demos
        mobile = MobileClient();
        here spawn mobile;
        
        web = WebDashboard();
        here spawn web;
        
        voice = VoiceAssistant();
        here spawn voice;
        
        wearable = WearableDevice();
        here spawn wearable;
        
        print("\n╔════════════════════════════════════════════════════════════════════╗");
        print("║                    All Client Demos Complete!                      ║");
        print("╚════════════════════════════════════════════════════════════════════╝");
        print("\nKey Takeaways:");
        print("  • All clients use Spawn() to call backend walkers");
        print("  • Consistent API across mobile, web, voice, and wearable");
        print("  • Real-time updates via OSP graph traversal");
        print("  • Personalized responses based on user history\n");
    }
}

with entry {
    user = User(
        user_id="user_001",
        name="Alex Smith",
        mood_count=5
    );
    root ++> user;
    
    demo = ClientDemo();
    user spawn demo;
}
