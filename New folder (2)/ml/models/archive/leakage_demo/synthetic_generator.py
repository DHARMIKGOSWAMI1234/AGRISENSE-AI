import os
import random
import numpy as np
import pandas as pd

def generate_synthetic_sessions(num_patients: int = 200, sessions_per_patient: int = 50, output_path: str = "ml/datasets/synthetic_interactions.csv"):
    """
    Generates synthetic cognitive game interaction sessions for training adaptive models.
    Simulates patient variability: consistent high performers, struggling performers, and variable performers.
    """
    np.random.seed(42)
    random.seed(42)

    data = []
    game_types = ["memory_match", "pattern", "routine_recall", "object_memory", "reminiscence"]

    for patient_idx in range(1, num_patients + 1):
        patient_id = f"PATIENT_{patient_idx:04d}"
        # Patient baseline skill level (0.2 = high need of assistance, 0.9 = high speed/accuracy)
        baseline_skill = np.random.beta(5, 3) 
        
        current_diff = 1
        for session_idx in range(1, sessions_per_patient + 1):
            game_type = random.choice(game_types)
            
            # Fatigue and noise factor
            fatigue = np.random.uniform(0.0, 0.15) if session_idx > 30 else 0.0
            effective_skill = max(0.1, min(0.99, baseline_skill - (current_diff * 0.08) - fatigue + np.random.normal(0, 0.05)))
            
            accuracy = float(np.clip(effective_skill + np.random.normal(0, 0.06), 0.1, 1.0))
            errors = int(max(0, np.round((1.0 - accuracy) * 8)))
            hints = int(np.random.choice([0, 1, 2, 3], p=[0.5, 0.3, 0.15, 0.05])) if accuracy < 0.75 else 0
            
            # Response time in milliseconds
            base_time = 2500 * current_diff
            response_time_ms = int(max(1200, base_time * (2.0 - accuracy) + np.random.normal(0, 500)))
            completion_rate = 1.0 if accuracy >= 0.4 else float(np.random.choice([0.5, 0.8, 1.0], p=[0.2, 0.3, 0.5]))
            
            # Target label: Difficulty recommendation for next round
            # 0: DECREASE (-1), 1: MAINTAIN (0), 2: INCREASE (+1)
            if completion_rate < 0.6 or accuracy < 0.55 or errors >= 4:
                target_action = 0 # DECREASE
            elif accuracy >= 0.85 and errors <= 1 and hints == 0:
                target_action = 2 # INCREASE
            else:
                target_action = 1 # MAINTAIN
                
            data.append({
                "patient_id": patient_id,
                "session_idx": session_idx,
                "game_type": game_type,
                "current_difficulty": current_diff,
                "accuracy": round(accuracy, 3),
                "error_count": errors,
                "hints_used": hints,
                "response_time_ms": response_time_ms,
                "completion_rate": round(completion_rate, 2),
                "target_action": target_action
            })
            
            # Update difficulty state for simulation
            if target_action == 0:
                current_diff = max(1, current_diff - 1)
            elif target_action == 2:
                current_diff = min(10, current_diff + 1)

    df = pd.DataFrame(data)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    df.to_csv(output_path, index=False)
    print(f"Generated {len(df)} synthetic interaction records for {num_patients} patients at: {output_path}")
    return df

if __name__ == "__main__":
    generate_synthetic_sessions()
