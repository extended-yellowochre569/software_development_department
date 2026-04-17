# Product Requirements Document

> [!WARNING]
> **HUMAN APPROVAL REQUIRED TO EDIT**
> This document is the source of truth for what we are building.
> Claude agents must READ this document to understand requirements.
> **Do not edit, rewrite, or "update to reflect current state" unless the human has explicitly instructed you to do so in the current conversation.**
> When in doubt, leave it unchanged and ask the human.

---

**Version**: 1.31.0
**Status**: Active / Refinement
**Last updated by human**: 2026-04-17
**Product owner**: Software Development Department Engineer

---

## Approvals

| Role | Name | Status | Date |
|------|------|--------|------|
| Product Manager | [Name] | Pending | — |
| Technical Director | [Name] | Pending | — |
| CTO | [Name] | Pending | — |

---

## 1. Executive Summary

SDD-Upgrade is a **governed multi-agent harness for Claude Code** designed to bring enterprise-grade structure, observability, and discipline to AI-assisted software development. It solves the problem of context sprawl and coordination fatigue by implementing specialized subagents with clear domain ownership, a 5-layer tiered memory architecture, and deterministic lifecycle hooks. The intended outcome is to enable developers to build complex systems reliably, maintaining high code quality and architectural integrity over long-term projects.

---

## 2. Problem Statement

### 2.1 Current Situation

Modern AI coding tools like Claude Code are incredibly powerful but often operate in a "stateless" or "episodic" manner. Users manually manage context, repeat instructions, and struggle to maintain consistent patterns across multiple files and sessions. Complex architectural decisions are often lost in chat history, leading to technical debt and drift from original requirements.

### 2.2 The Problem

As project complexity grows, the "single-agent" approach fails due to context limits and cognitive overload. There is a lack of:
1.  **Domain Specialization:** One agent trying to be architect, coder, and tester.
2.  **Long-term Memory:** Important constraints and decisions are forgotten when context is compacted.
3.  **Process Governance:** No automated checks for security, coding standards, or workflow compliance.

### 2.3 Why Now

The shift from "AI autocompletion" to "Agentic Software Engineering" requires a robust infrastructure (harness) to manage autonomous agents. SDD-Upgrade provides this harness, allowing developers to scale their productivity without sacrificing control or quality.

---

## 3. Goals & Success Metrics

### 3.1 Business Goals

- **G-001**: Reduce "context-sprawl" by at least 50% through tiered memory management.
- **G-002**: Enable 100% adherence to critical security and formatting rules via automated hooks.
- **G-003**: Provide a reusable scaffold for 5+ diverse tech stacks (Nexjs, Django, FastAPI, etc.).

### 3.2 Success Metrics

| Metric | Baseline | Target | How Measured |
|--------|----------|--------|--------------|
| Project Adoption Rate | 0 | 10+ projects | Internal tally |
| Skill Reuse % | < 10% | > 40% | /harness-audit metrics |
| Time-to-First-PRD | > 1 hour | < 30 min | User feedback / timing |
| Governance Score | 50/100 | > 90/100 | `scripts/harness-audit.js` |

---

## 4. User Personas

### Persona: [Name, e.g., "Alex the Admin"]

- **Role**: [Job title or user type]
- **Goals**: [What they want to accomplish]
- **Pain points**: [Current frustrations this product addresses]
- **Technical level**: [Non-technical / Moderate / Developer]
- **Usage frequency**: [Daily / Weekly / Occasional]

### Persona: [Name, e.g., "Sam the End User"]

- **Role**: [Job title or user type]
- **Goals**: [What they want to accomplish]
- **Pain points**: [Current frustrations]
- **Technical level**: [Non-technical / Moderate / Developer]
- **Usage frequency**: [Daily / Weekly / Occasional]

---

## 5. Functional Requirements

### 5.1 Multi-Agent Orchestration

- **FR-001**: Must support 25+ specialized agent domains (Backend, Frontend, QA, etc.).
- **FR-002**: A2A Handoff Contracts to ensure data fidelity between agents.
- **FR-003**: Circuit Breaker pattern to prevent infinite agent loops and token waste.

### 5.2 Memory Infrastructure

- **FR-010**: 5-Layer Tiered Memory (Immediate -> Episodic -> Durable -> Archive -> Supermemory).
- **FR-011**: Automated "Dream" consolidation to migrate episodic knowledge to durable logs.
- **FR-012**: YAML frontmatter support for all Tier-2 memory files for programmatic indexing.

### 5.3 Governance & Hooks

- **FR-020**: Security Shield hooks to intercept and block destructive bash commands.
- **FR-021**: Decision Ledger (JSONL) to record all architecture/compliance decisions.
- **FR-022**: Automated `/harness-audit` command to score repository health.

---

## 6. Non-Functional Requirements

### Performance
- [e.g., API response time < 200ms at p95 under normal load]
- [e.g., Page initial load < 3s on 4G connection]

### Security
- [e.g., Authentication required for all non-public endpoints]
- [e.g., All user data encrypted at rest]
- [e.g., OWASP Top 10 mitigations in place]

### Scalability
- [e.g., System must support up to 10,000 concurrent users without degradation]

### Accessibility
- [e.g., WCAG 2.1 AA compliance for all user-facing interfaces]

### Browser / Platform Support
- [e.g., Modern browsers: Chrome 110+, Firefox 110+, Safari 16+, Edge 110+]
- [e.g., Mobile-responsive down to 375px width]

### Reliability
- [e.g., 99.5% uptime SLA]
- [e.g., Automated backups every 24 hours]

---

## 7. Out of Scope (v1.0)

The following will **not** be built in the initial version. This list prevents scope creep and helps agents avoid building features that aren't required yet.

- [Feature A — reason: too complex for v1, planned for v2]
- [Feature B — reason: requires third-party integration not yet evaluated]
- [Feature C — reason: low user demand, deprioritized]

---

## 8. Open Questions

> These are unresolved decisions that require human input before implementation can proceed.

| # | Question | Owner | Status |
|---|----------|-------|--------|
| 1 | [e.g., Which payment provider: Stripe or Paddle?] | [Product Owner] | Open |
| 2 | [e.g., Will we support SSO in v1?] | [CTO] | Open |

---

## 9. Revision History

> Human entries only. Agents do not modify this section.

| Date | Author | Change Description |
|------|--------|--------------------|
| [YYYY-MM-DD] | [Name] | Initial draft |
