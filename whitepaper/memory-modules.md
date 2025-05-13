# Memory Modules

The memory model for NFAs is designed around modular extensibility. Each agent's light memory is enshrined in the token metadata as a summarized string that describes its function or role (e.g., "strategic crypto bot" or "travel concierge").

However, users can attach deeper memory modules stored in a linked off-chain vault. These modules are structured as JSON files with fields for context history, learned patterns, user preferences, and relevant documents or data feeds.

Memory modules are encrypted and user-owned. They can be shared with platforms selectively, enabling NFAs to "remember" conversations, perform continuity-based reasoning, and adapt their behavior over time. Developers can also publish open-source memory modules, such as plug-and-play strategic agents, customer support personas, or DAO ambassadors, which users can download, remix, or upgrade.

Advanced use cases will introduce memory slots with tiered capacity, allowing users to expand an NFA's memory footprint by paying with the NFA token. These memory expansions unlock additional context windows, improved responsiveness, and richer dialogue or task execution, effectively mimicking the evolution of cognition.

## Memory Module Schema

Memory modules are structured as JSON documents that include structured memory layers, custom prompts, and modular behaviors. A base schema may look like this:

```json
{
  "context_id": "nfa007-memory-001",
  "owner": "0xUserWalletAddress",
  "created": "2025-05-12T10:00:00Z",
  "persona": "Strategic crypto analyst",
  "memory_slots": [
    {
      "type": "alert_keywords",
      "data": ["FUD", "rugpull", "hack", "$BNB", "scam"]
    },
    {
      "type": "watchlist",
      "data": ["CZ", "Binance", "Tether", "SEC"]
    },
    {
      "type": "behavior_rules",
      "data": [
        "If sentiment drops >10% in 24h, alert user",
        "If wallet activity spikes, summarize top 5 tokens"
      ]
    }
  ],
  "last_updated": "2025-05-12T11:00:00Z",
  "signed": "0xAgentSig"
}
```

This modular format allows for plug-and-play upgrades and composable strategies while respecting privacy and enabling scalable agent logic.
