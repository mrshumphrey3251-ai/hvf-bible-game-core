
## 6. Generational Continuity & The Alpha-Omega Loop
To resolve the human lifespan limitation across a multi-millennia timeline, the engine utilizes two advanced continuity mechanics:
* **The Bloodline Handoff:** Upon character death (combat, disease, or old age), player control seamlessly transfers to their designated living heir. The survival of the family tree is the true metric of success. If the bloodline is severed entirely, the player respawns as a new entity in the current era.
* **The Alpha-Omega Loop:** When the World Clock reaches the eschatological events of Revelation, the current historical epoch concludes. The timeline executes a seamless loop back to Genesis. Meta-progression (Era Mastery, Legacy Traits) carries over into the next cycle, ensuring continuous, infinite gameplay without a hard termination state.

## 7. The Creator's Dilemma & The Stochastic Chaos Engine
To ensure the game remains unpredictable and un-gameable even for the Chief Architect, deterministic decision-making is strictly prohibited. 
* **Dynamic Probability Outcomes:** Every player choice triggers a hidden, weighted probability roll (Stochastic Chaos Engine). 
* A single decision (e.g., "Fight the raiders") holds multiple potential outcomes (e.g., Flawless Victory, Grievous Wound, Permadeath). The engine resolves the reality at runtime based on hidden dice rolls combined with dynamic modifiers (like NPC loyalty or player health). The creator will never know the absolute outcome of a decision beforehand.

## 9. Hybrid Online/Offline Architecture & Anti-Tamper Protocol
The engine will operate as a Hybrid Live-Service application to maximize market penetration.
* **Offline Mode:** Fully functional using the local Python server bridge.
* **Online Mode:** Enables cloud syncing, global metrics, and remote updates.
* **Unhackable State Sovereignty (SHA-256):** To prevent local memory injection or save-file tampering during Offline Mode, all local game states are sealed using cryptographic hashing. If a player modifies their local file to cheat, the hash invalidates, and the master server will permanently reject the corrupted timeline upon reconnection.

## 10. Dual-Frontend Rendering Strategy (The Omni-Client)
Because the Python backend is completely decoupled, it is engine-agnostic. We will execute a Dual-Frontend deployment:
* **Tier 1 (AAA Live-Service):** Unreal Engine 5. Deployed for high-end platforms, leveraging heavy graphical assets and cloud-sync capabilities.
* **Tier 2 (Sovereign Offline):** Godot 4. Deployed for lightweight laptops, mobile, and strict offline grid-down scenarios.
* **The Omni-Bridge:** Both frontends will communicate with the exact same Python offline backend using a universal JSON API handshake. The core logic remains centralized, immutable, and unhackable regardless of the visual client used.
