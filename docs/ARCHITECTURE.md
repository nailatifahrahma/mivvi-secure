# System Architecture

```text
SMS / WhatsApp notification
          |
          v
Android NotificationListenerService
(user grants Notification Access; selected source packages only)
          |
          v
Notification parser
(title / sender / visible text / timestamp / source package)
          |
          v
Local preprocessing
(case folding, spacing, common obfuscation normalization, URL extraction)
          |
          v
Feature extraction
(Aho-Corasick keywords, URL/domain parsing, shortlink lookup,
 trusted-sender lookup, urgency patterns, sensitive-data patterns)
          |
          v
Weighted Rule-Based Risk Scoring
          |
          v
Threshold classifier
(0-2 AMAN | 3-5 MENCURIGAKAN | >=6 PHISHING)
          |
          v
Android UI + local SQLite history

Rules sync: Android --GET /api/v1/rules--> FastAPI
Account auth: Android --POST/GET with bearer session--> FastAPI --SQLite--> users/sessions
```

## Wireless / mobile relationship

- SMS reaches the device through the cellular messaging service.
- WhatsApp reaches the device through an internet data connection (cellular data or Wi-Fi).
- MIVVI SECURE receives the available notification event from Android and performs deterministic feature extraction and scoring on the mobile device.
- The API distributes rule configuration and handles account authentication; it is not in the message-analysis path.

## Permissions

- `BIND_NOTIFICATION_LISTENER_SERVICE`: declared on the listener service; the user enables access manually in Android Settings.
- `INTERNET`: for rules synchronization and account authentication.
- No `READ_SMS`, `RECEIVE_SMS`, `READ_CONTACTS`, microphone, camera, or location permission is requested.

## Limitations

Notification listener access is not equivalent to direct access to an application's private message database. The detector can only analyze content surfaced in notification extras. Hidden previews, muted channels, grouped notifications, unsupported packages, and OS restrictions can result in missing content.
