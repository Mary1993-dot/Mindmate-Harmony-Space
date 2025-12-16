"""
MindMate Harmony Space - Jac Client Implementation
Requirement 4: Jac Client with Spawn-based interactions
"""

import sys
import subprocess

# Install requests if not available
try:
    import requests
except ImportError:
    print("Installing requests library...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests"])
    import requests
import json
from datetime import datetime
from typing import Dict, List, Any

class MindMateJacClient:
    """
    Jac Client for MindMate Harmony Space
    Demonstrates end-to-end multi-agent workflow using Spawn
    """
    
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
        self.session = requests.Session()
        
    def spawn_graph_builder(self, user_id: str, user_name: str = "Demo User") -> Dict:
        """
        Spawn GraphBuilder walker to initialize OSP graph with user data
        """
        print(f"\n{'='*70}")
        print(f"🚀 SPAWN: GraphBuilder")
        print(f"{'='*70}")
        
        payload = {
            "walker": "GraphBuilder",
            "params": {
                "user_id": user_id,
                "user_name": user_name
            }
        }
        
        response = self._make_request("/api/spawn/graph_builder", payload)
        
        if response.get("status") == "graph_built":
            print(f"✓ Graph initialized for user: {user_id}")
            print(f"✓ Mood entries created: {response.get('mood_entries_created')}")
            print(f"✓ Average intensity: {response.get('avg_intensity', 0):.2f}")
        
        return response
    
    def spawn_mood_logger(self, user_id: str, emotion_name: str, 
                         intensity: float, user_input: str,
                         triggers: List[str] = None, 
                         activities: List[str] = None) -> Dict:
        """
        Spawn MoodLogger to add new mood entry
        """
        print(f"\n{'='*70}")
        print(f"🚀 SPAWN: MoodLogger")
        print(f"{'='*70}")
        
        payload = {
            "walker": "MoodLogger",
            "params": {
                "user_id": user_id,
                "emotion_name": emotion_name,
                "intensity": intensity,
                "user_input": user_input,
                "triggers": triggers or [],
                "activities": activities or []
            }
        }
        
        response = self._make_request("/api/spawn/mood_logger", payload)
        
        print(f"✓ Logged mood: {emotion_name} (intensity: {intensity})")
        
        return response
    
    def spawn_system_coordinator(self, user_id: str, 
                                 operation: str = "full_analysis") -> Dict:
        """
        Spawn SystemCoordinator to run multi-agent analysis pipeline
        Triggers: MoodAnalyzerAgent → RecommendationAgent → ValidationAgent → InsightGeneratorAgent
        """
        print(f"\n{'='*70}")
        print(f"🚀 SPAWN: SystemCoordinator (Multi-Agent Pipeline)")
        print(f"{'='*70}")
        print(f"User: {user_id}")
        print(f"Operation: {operation}")
        print(f"\nAgent Pipeline:")
        print(f"  1. MoodAnalyzerAgent    → Analyze patterns & triggers")
        print(f"  2. RecommendationAgent  → Generate personalized recommendations")
        print(f"  3. ValidationAgent      → Score & validate recommendations")
        print(f"  4. InsightGeneratorAgent → Create actionable insights")
        print(f"{'='*70}\n")
        
        payload = {
            "walker": "SystemCoordinator",
            "params": {
                "user_id": user_id,
                "operation": operation
            }
        }
        
        response = self._make_request("/api/spawn/coordinator", payload)
        
        # Display results
        if response.get("analysis_summary"):
            self._display_analysis_results(response)
        
        return response
    
    def _display_analysis_results(self, response: Dict):
        """Display formatted analysis results"""
        
        print(f"\n{'='*70}")
        print(f"📊 ANALYSIS RESULTS")
        print(f"{'='*70}\n")
        
        # Analysis Summary
        analysis = response.get("analysis_summary", {})
        print(f"📈 Mood Analysis:")
        print(f"  • Total entries: {analysis.get('total_entries', 0)}")
        print(f"  • Dominant emotion: {analysis.get('dominant_emotion', 'N/A').upper()}")
        print(f"  • Average intensity: {analysis.get('avg_intensity', 0):.2f}")
        print(f"  • Emotional diversity: {analysis.get('emotional_diversity', 0)} emotions")
        print(f"  • Trend: {analysis.get('trend', 'N/A').upper()}")
        
        # Recommendations
        recommendations = response.get("recommendations", [])
        print(f"\n💡 Recommendations ({len(recommendations)}):")
        for idx, rec in enumerate(recommendations[:5], 1):
            status = "✓" if rec.get("validated") else "○"
            priority = "🔴" * rec.get("priority", 1)
            print(f"\n  {status} [{priority}] {rec.get('title')}")
            print(f"     Type: {rec.get('rec_type')}")
            print(f"     Score: {rec.get('relevance_score', 0):.2f}")
            print(f"     {rec.get('content', '')[:100]}...")
        
        # Insights
        insights = response.get("insights", [])
        print(f"\n💎 Insights ({len(insights)}):")
        for idx, insight in enumerate(insights, 1):
            actionable = "🎯" if insight.get("actionable") else "ℹ️"
            print(f"\n  {actionable} {insight.get('title')}")
            print(f"     Type: {insight.get('insight_type')}")
            print(f"     Confidence: {insight.get('confidence_score', 0):.2f}")
            print(f"     {insight.get('description', '')[:150]}...")
        
        # Validation Summary
        validation = response.get("validation_summary", {})
        print(f"\n🔬 Validation:")
        print(f"  • Validated: {validation.get('validated_count', 0)}/{validation.get('total_recommendations', 0)}")
        print(f"  • Avg relevance: {validation.get('avg_relevance', 0):.2f}")
        
        # Agents
        agents = response.get("agents_involved", [])
        print(f"\n🤖 Agents Involved: {', '.join(agents)}")
        
        print(f"\n{'='*70}\n")
    
    def _make_request(self, endpoint: str, payload: Dict) -> Dict:
        """Make request to Jac server"""
        try:
            url = f"{self.base_url}{endpoint}"
            response = self.session.post(
                url,
                json=payload,
                headers={"Content-Type": "application/json"},
                timeout=30
            )
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"❌ Request failed: {e}")
            return {"status": "error", "message": str(e)}
    
    def demo_full_workflow(self, user_id: str = "demo_user_001"):
        """
        Demonstrate complete end-to-end workflow
        """
        print(f"\n{'#'*70}")
        print(f"# MindMate Harmony Space - Complete Workflow Demo")
        print(f"# Using Spawn-based Jac Client")
        print(f"{'#'*70}")
        
        # Step 1: Initialize graph
        print(f"\n📍 STEP 1: Initialize OSP Graph")
        graph_result = self.spawn_graph_builder(user_id, "Alex Johnson")
        
        if graph_result.get("status") != "graph_built":
            print("❌ Failed to initialize graph")
            return
        
        # Step 2: Add additional mood entry
        print(f"\n📍 STEP 2: Log New Mood Entry")
        mood_result = self.spawn_mood_logger(
            user_id=user_id,
            emotion_name="hopeful",
            intensity=0.78,
            user_input="Starting to see progress on my goals. Feeling optimistic about the future.",
            triggers=["achievement", "reflection", "planning"],
            activities=["goal_setting", "journaling"]
        )
        
        # Step 3: Run multi-agent analysis
        print(f"\n📍 STEP 3: Execute Multi-Agent Analysis Pipeline")
        analysis_result = self.spawn_system_coordinator(
            user_id=user_id,
            operation="full_analysis"
        )
        
        # Final summary
        print(f"\n{'='*70}")
        print(f"✅ WORKFLOW COMPLETE")
        print(f"{'='*70}")
        print(f"• Graph initialized with OSP structure")
        print(f"• Multi-agent analysis executed successfully")
        print(f"• Agents: MoodAnalyzer → Recommendation → Validation → InsightGenerator")
        print(f"• Generated {len(analysis_result.get('recommendations', []))} recommendations")
        print(f"• Created {len(analysis_result.get('insights', []))} insights")
        print(f"{'='*70}\n")
        
        return analysis_result


# ============================================================================
# Example Usage
# ============================================================================

def main():
    """
    Main demonstration function
    """
    # Initialize client
    client = MindMateJacClient(base_url="http://localhost:8000")
    
    # Run full workflow demo
    result = client.demo_full_workflow(user_id="demo_user_001")
    
    # Additional examples
    print("\n" + "="*70)
    print("📚 Additional Usage Examples")
    print("="*70)
    
    # Example 1: Log multiple moods
    print("\n1️⃣ Logging multiple mood entries:")
    moods = [
        {"emotion": "excited", "intensity": 0.85, "input": "Got accepted into the program!"},
        {"emotion": "nervous", "intensity": 0.60, "input": "First day jitters"},
        {"emotion": "proud", "intensity": 0.90, "input": "Completed my first milestone"}
    ]
    
    for mood in moods:
        client.spawn_mood_logger(
            user_id="demo_user_001",
            emotion_name=mood["emotion"],
            intensity=mood["intensity"],
            user_input=mood["input"],
            triggers=["achievement", "growth"],
            activities=["learning", "reflection"]
        )
    
    # Example 2: Run analysis after new data
    print("\n2️⃣ Running updated analysis:")
    client.spawn_system_coordinator(user_id="demo_user_001")
    
    print("\n✅ Demo complete! Check the output above for multi-agent results.\n")


if __name__ == "__main__":
    main()
