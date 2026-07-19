# Deployment & Release Engineering Guide

This guide describes the release checklist, build parameters, scaling strategies, and monitoring tools required to deploy the AI Employee Management System to production for over 100,000 active users.

---

## 1. Environment Configurations

Make sure to supply production API keys during building using `--dart-define` flags rather than committing secrets to version control.

| Variable Name | Purpose | Example Value |
| --- | --- | --- |
| `SUPABASE_URL` | Supabase Multi-tenant Database endpoint | `https://company-api.supabase.co` |
| `SUPABASE_ANON_KEY` | Anonymous API access Token | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpX...` |
| `GEMINI_API_KEY` | Gemini AI Inference model key | `AIzaSyBw...` |

---

## 2. Platform Build Instructions

### Android Release
1. Update `android/app/build.gradle` versioning parameters.
2. Build app bundle:
   ```bash
   flutter build appbundle --release --dart-define=SUPABASE_URL=https://prod.supabase.co --dart-define=SUPABASE_ANON_KEY=token
   ```

### iOS Release
1. Update Info.plist configurations.
2. Build iOS archive:
   ```bash
   flutter build ipa --release --dart-define=SUPABASE_URL=https://prod.supabase.co --dart-define=SUPABASE_ANON_KEY=token
   ```

### Web Dashboard
1. Optimize web canvas rendering.
2. Build static assets web folder:
   ```bash
   flutter build web --release --web-renderer canvaskit --dart-define=SUPABASE_URL=https://prod.supabase.co
   ```

### Desktop Builds (Windows)
1. Build executable bundle:
   ```bash
   flutter build windows --release --dart-define=SUPABASE_URL=https://prod.supabase.co
   ```

---

## 3. Scaling & Architecture Strategy (100,000+ Users)

To guarantee consistent low latency under high load, the following patterns must be implemented:
1. **Supabase Connection Pooling**: Use connection poolers (e.g., PgBouncer) to manage database connection overhead.
2. **PostgreSQL Read Replicas**: Distribute read transactions across read replicas, reserving the primary cluster for database writes.
3. **Hive Local Layer Syncinging**: Cache profiles and directories locally. Send checks-ins and task updates through the sync queue worker, avoiding direct spikes to Supabase on startup.
4. **Row-Level Security Indexes**: Ensure index maps exist on all isolated tenant tables (e.g., `idx_attendance_employee`, `idx_tasks_assigned`).

---

## 4. Monitoring & Telemetry

1. **Error Tracking**: Deploy Sentry or Firebase Crashlytics to monitor runtime exception stack traces.
2. **Latency Telemetry**: Set up API gateway metrics monitoring to observe API response times.
3. **Audit Log Streams**: Connect Supabase database transaction logs to Cloud Logging/Elasticsearch to audit administrative actions.
