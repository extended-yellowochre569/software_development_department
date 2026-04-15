# Directory Structure

```text
/
├── CLAUDE.md                    # Master configuration
├── PRD.md                       # Product requirements (source of truth — human-editable only)
├── TODO.md                      # Living backlog (governed by @producer)
├── .claude/                     # Agent definitions, skills, hooks, rules, docs
├── .tasks/                      # Task detail files (NNN-short-title.md — one per TODO item)
├── src/                         # Application source code (api, frontend, backend, ai, networking, ui, tools)
├── design/                      # Design files (wireframes, research, design specs)
├── docs/                        # Technical documentation
│   ├── ui-spec/                 # UI Specifications
│   │   ├── assets/              # Prototype code and screenshots
│   │   └── feature-ui-spec.md   # Feature-specific UI spec
│   ├── technical/               # Architecture, decisions, API, database specs
│   │   ├── ARCHITECTURE.md      # System architecture — owned by @technical-director
│   │   ├── DECISIONS.md         # ADR log — owned by @technical-director / @cto
│   │   ├── API.md               # API reference — owned by @backend-developer
│   │   ├── DATABASE.md          # Schema documentation — owned by @data-engineer
│   │   ├── INVESTIGATIONS.md    # Investigation history — owned by @investigator
│   │   ├── VERIFICATIONS.md     # Verification reports — owned by @verifier
│   │   └── SOLUTIONS.md         # Proposed solution designs — owned by @solver
│   └── user/                    # User-facing documentation
│       └── USER_GUIDE.md        # End-user guide — owned by @tech-writer
├── tests/                       # Test suites (unit, integration, e2e, performance)
├── infra/                       # Infrastructure as code (docker, terraform, k8s)
├── scripts/                     # Build, migration, and utility scripts
├── prototypes/                  # Throwaway prototypes (isolated from src/)
└── production/                  # Production management (sprints, milestones, releases)
    ├── session-state/           # Ephemeral session state (active.md — gitignored)
    └── session-logs/            # Session audit trail (gitignored)
```
