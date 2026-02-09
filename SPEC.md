# Log-First Observability POC — Specification

## Overview

This project is a proof-of-concept **log-first observability pipeline** designed to demonstrate how meaningful signal can be extracted from high-volume, high-cardinality logs *without* relying on full tracing or metrics systems.

The focus is on:
- structured logging
- tail-based filtering
- scalable log analytics
- realistic failure and latency patterns

The system is intentionally simple, deterministic, and failure-prone to highlight observability behavior rather than application complexity.

---

## Goals

- Demonstrate how structured logs alone can provide deep observability
- Show tail-based filtering reducing log volume while preserving signal
- Enable fast, flexible log analytics using SQL
- Create realistic traffic patterns and failure modes under load
- Provide a clean, reproducible, open-source reference architecture

---

## Non-Goals

- No production-ready API
- No real database or persistence layer
- No authentication or authorization
- No OpenTelemetry or distributed tracing (by design)
- No cloud-managed services

---

## High-Level Architecture

```
Client (k6)
|
v
HTTP Server (Bun)
|
v
Structured JSON Logs
|
v
Vector (ingest, transform, tail filter)
|
v
ClickHouse (storage + analytics)

````

---

## Server Runtime

- **Runtime:** Bun
- **Protocol:** HTTP
- **Responsibility:** Generate realistic request behavior and emit structured logs

The server is intentionally framework-light to avoid “magic” observability provided by middleware.

---

## API Endpoints

### `GET /health`

**Purpose**
- High-volume, low-signal endpoint

**Behavior**
- Always returns `200 OK`
- Very low latency (<5ms)

**Observability Role**
- Primary candidate for aggressive log dropping
- Demonstrates noise reduction effectiveness

---

### `GET /items/:id`

**Purpose**
- Simulate a typical read path

**Behavior**
- Latency distribution:
  - 80% fast (5–20ms)
  - 15% medium (50–150ms)
  - 5% slow (300–800ms)
- ~1–2% error rate

**Possible Errors**
- `not_found`
- `timeout`
- `downstream_error`

---

### `POST /items`

**Purpose**
- Simulate a write path

**Behavior**
- Slightly higher baseline latency than reads
- Occasional validation failures
- Rare simulated database failures

**Additional Signals**
- Request payload size
- Simulated database latency

---

### `GET /fanout`

**Purpose**
- Simulate fan-out to multiple downstream services

**Behavior**
- 2–5 downstream calls per request
- Each downstream call has independent latency and failure probability
- Request may succeed with partial downstream failures

**Observability Role**
- Demonstrates correlation across multiple log events
- Highlights partial failures without tracing

---

## Logging Model

### Log Format
- JSON
- One log event per request
- No unstructured strings

### Required Fields
```json
{
  "timestamp": "...",
  "level": "info | warn | error",
  "event": "request.start | downstream.call | request.end | ...",
  "request_id": "...",
  "trace_id": "...",
  "route": "...",
  "method": "...",
  "status": 200,
  "latency_ms": 123,
  "latency_bucket": "fast | medium | slow",
  "error_type": null
}
````

### Logging Principles

* One log event per request
* Correlation via `request_id`
* Logs contain both context and metrics

---

## Vector Pipeline

### Responsibilities

* Ingest raw JSON logs
* Normalize and enrich fields
* Apply tail-based filtering rules
* Forward retained logs to ClickHouse

### Tail-Based Filtering Strategy

* Always retain:
  * errors
  * slow requests
* Sample:
  * normal successful requests
* Drop:
  * successful health checks
  * low-latency noise

---

## ClickHouse

### Role

* Primary log storage
* Analytics engine

### Capabilities Demonstrated

* High-cardinality queries
* Latency distribution analysis
* Error rate analysis

---

## Load Generation (k6)

### Traffic Mix

* 60% `GET /health`
* 25% `GET /items/:id`
* 10% `GET /fanout`
* 5% `POST /items`

### Purpose

* Generate realistic load
* Produce tail latency
* Trigger rare failure modes
* Stress log ingestion and filtering

---

## Open Source Intent

This project is designed to be:

* easy to run locally
* simple to extend
* opinionated but not prescriptive
* useful as a learning reference

---

