"""Week 10 Session 1 saga/outbox demo; not production TeleMed IA service code."""

from __future__ import annotations

import json
import sqlite3
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Callable


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


@dataclass(frozen=True)
class Event:
    event_id: str
    event_type: str
    payload: dict[str, str]


class SimulatedBroker:
    """Small synchronous broker substitute used only by this executable demo."""

    def __init__(self) -> None:
        self.subscribers: dict[str, list[Callable[[Event], None]]] = {}
        self.messages: list[Event] = []

    def subscribe(self, event_type: str, handler: Callable[[Event], None]) -> None:
        self.subscribers.setdefault(event_type, []).append(handler)

    def publish(self, event: Event) -> None:
        """Accept a message independently of its later consumer delivery."""
        self.messages.append(event)

    def deliver(self) -> None:
        """Deliver accepted messages; consumer failures do not undo broker acceptance."""
        while self.messages:
            event = self.messages.pop(0)
            for handler in self.subscribers.get(event.event_type, []):
                handler(event)

class AppointmentService:
    def __init__(self, database: Path) -> None:
        self.database = database
        with self.connect() as db:
            db.executescript("""
                CREATE TABLE appointments (
                    appointment_id TEXT PRIMARY KEY,
                    patient_id TEXT NOT NULL,
                    professional_id TEXT NOT NULL,
                    status TEXT NOT NULL
                );
                CREATE TABLE outbox_events (
                    event_id TEXT PRIMARY KEY,
                    event_type TEXT NOT NULL,
                    payload TEXT NOT NULL,
                    status TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    published_at TEXT
                );
            """)

    def connect(self) -> sqlite3.Connection:
        return sqlite3.connect(self.database)

    def create_appointment(self, appointment_id: str, patient_id: str,
                           professional_id: str) -> Event:
        event = Event(str(uuid.uuid4()), "AppointmentCreated", {
            "appointment_id": appointment_id,
            "patient_id": patient_id,
            "professional_id": professional_id,
        })
        with self.connect() as db:
            db.execute("BEGIN")
            db.execute("INSERT INTO appointments VALUES (?, ?, ?, 'CREATED')",
                       (appointment_id, patient_id, professional_id))
            db.execute("INSERT INTO outbox_events VALUES (?, ?, ?, 'PENDING', ?, NULL)",
                       (event.event_id, event.event_type, json.dumps(event.payload), now()))
        return event

    def pending_events(self) -> list[Event]:
        with self.connect() as db:
            rows = db.execute(
                "SELECT event_id, event_type, payload FROM outbox_events "
                "WHERE status = 'PENDING' ORDER BY created_at, event_id").fetchall()
        return [Event(event_id, kind, json.loads(payload))
                for event_id, kind, payload in rows]

    def publish_pending(self, broker: SimulatedBroker,
                        fail_once: bool = False) -> bool:
        """Mark published only after broker acceptance; failed rows remain pending."""
        for event in self.pending_events():
            if fail_once:
                fail_once = False
                print(f"Injected broker failure for {event.event_id}; event remains PENDING.")
                return False
            broker.publish(event)
            with self.connect() as db:
                db.execute("UPDATE outbox_events SET status='PUBLISHED', published_at=? "
                           "WHERE event_id=?", (now(), event.event_id))
        return True

    def consume_cancellation(self, event: Event) -> None:
        appointment_id = event.payload["appointment_id"]
        with self.connect() as db:
            db.execute("UPDATE appointments SET status='CANCELLED' "
                       "WHERE appointment_id=?", (appointment_id,))

    def appointment_status(self, appointment_id: str) -> str | None:
        with self.connect() as db:
            row = db.execute("SELECT status FROM appointments WHERE appointment_id=?",
                             (appointment_id,)).fetchone()
        return row[0] if row else None

    def outbox_status(self, event_id: str) -> str | None:
        with self.connect() as db:
            row = db.execute("SELECT status FROM outbox_events WHERE event_id=?",
                             (event_id,)).fetchone()
        return row[0] if row else None


class MedicalConsultationService:
    def __init__(self, database: Path) -> None:
        self.database = database
        self.fail_next = False
        with self.connect() as db:
            db.executescript("""
                CREATE TABLE consultations (
                    consultation_id TEXT PRIMARY KEY,
                    appointment_id TEXT NOT NULL UNIQUE,
                    patient_id TEXT NOT NULL,
                    professional_id TEXT NOT NULL,
                    status TEXT NOT NULL
                );
                CREATE TABLE processed_events (
                    event_id TEXT PRIMARY KEY,
                    processed_at TEXT NOT NULL
                );
            """)

    def connect(self) -> sqlite3.Connection:
        return sqlite3.connect(self.database)

    def consume_appointment_created(self, event: Event) -> None:
        with self.connect() as db:
            db.execute("BEGIN")
            if db.execute("SELECT 1 FROM processed_events WHERE event_id=?",
                          (event.event_id,)).fetchone():
                print(f"Duplicate {event.event_id} ignored by persistent idempotency check.")
                return
            if self.fail_next:
                self.fail_next = False
                raise RuntimeError("Injected consultation creation failure")
            payload = event.payload
            db.execute("INSERT INTO consultations VALUES (?, ?, ?, ?, 'IN_PROGRESS')",
                       (str(uuid.uuid4()), payload["appointment_id"],
                        payload["patient_id"], payload["professional_id"]))
            db.execute("INSERT INTO processed_events VALUES (?, ?)", (event.event_id, now()))

    def consultation_count(self, appointment_id: str) -> int:
        with self.connect() as db:
            return db.execute("SELECT COUNT(*) FROM consultations WHERE appointment_id=?",
                              (appointment_id,)).fetchone()[0]

    def processed(self, event_id: str) -> bool:
        with self.connect() as db:
            return db.execute("SELECT 1 FROM processed_events WHERE event_id=?",
                              (event_id,)).fetchone() is not None


def check(condition: bool, label: str) -> None:
    print(f"{label}: {'PASS' if condition else 'FAIL'}")
    if not condition:
        raise AssertionError(label)


def run() -> None:
    root = Path(__file__).resolve().parent
    for database_name in ("appointment.db", "medical_consultation.db"):
        (root / database_name).unlink(missing_ok=True)
    appointment = AppointmentService(root / "appointment.db")
    consultation = MedicalConsultationService(root / "medical_consultation.db")
    broker = SimulatedBroker()
    broker.subscribe("AppointmentCreated", consultation.consume_appointment_created)
    broker.subscribe("AppointmentCancelled", appointment.consume_cancellation)

    print("=== DATABASE PER SERVICE ===")
    check(appointment.database.name == "appointment.db" and
          consultation.database.name == "medical_consultation.db" and
          appointment.database != consultation.database,
          "Independent service database files")
    print("Appointment Service -> appointment.db")
    print("Medical Consultation Service -> medical_consultation.db")

    print("\n=== OUTBOX ===")
    event = appointment.create_appointment("apt-happy", "patient-1", "professional-1")
    check(appointment.outbox_status(event.event_id) == "PENDING",
          "Appointment and outbox event persisted in local transaction")

    print("\n=== SAGA - HAPPY PATH ===")
    check(appointment.publish_pending(broker), "Outbox publication succeeds")
    broker.deliver()
    happy_ok = (appointment.appointment_status("apt-happy") == "CREATED" and
                consultation.consultation_count("apt-happy") == 1 and
                consultation.processed(event.event_id))
    check(happy_ok, "Appointment, consultation, and processed event are consistent")

    print("\n=== OUTBOX FAILURE + RETRY ===")
    retry_event = appointment.create_appointment("apt-retry", "patient-2", "professional-2")
    first_attempt = appointment.publish_pending(broker, fail_once=True)
    pending_after_failure = appointment.outbox_status(retry_event.event_id) == "PENDING"
    retry_ok = appointment.publish_pending(broker)
    broker.deliver()
    check(not first_attempt and pending_after_failure and retry_ok and
          appointment.outbox_status(retry_event.event_id) == "PUBLISHED" and
          consultation.consultation_count("apt-retry") == 1,
          "Failed publication stays pending and succeeds on retry")

    print("\n=== SAGA - FAILURE + COMPENSATION ===")
    failed_event = appointment.create_appointment(
        "apt-compensate", "patient-3", "professional-3")
    consultation.fail_next = True
    try:
        appointment.publish_pending(broker)
        broker.deliver()
        consumer_failed = False
    except RuntimeError as error:
        consumer_failed = "Injected" in str(error)
        print(f"Consumer failed as injected: {error}")
    no_partial_consultation = consultation.consultation_count("apt-compensate") == 0
    no_failed_processed_mark = not consultation.processed(failed_event.event_id)
    compensation = Event(str(uuid.uuid4()), "AppointmentCancelled", {
        "appointment_id": "apt-compensate", "reason": "CONSULTATION_CREATION_FAILED"})
    broker.publish(compensation)
    broker.deliver()
    compensated = appointment.appointment_status("apt-compensate") == "CANCELLED"
    check(consumer_failed and no_partial_consultation and no_failed_processed_mark and
          compensated, "Failure rolls back consultation and compensation cancels appointment")

    print("\n=== IDEMPOTENT CONSUMER ===")
    duplicate_event = appointment.create_appointment(
        "apt-duplicate", "patient-4", "professional-4")
    # First delivery goes through the outbox and broker; then replay that same event.
    appointment.publish_pending(broker)
    broker.deliver()
    consultation.consume_appointment_created(duplicate_event)
    duplicate_ok = (consultation.consultation_count("apt-duplicate") == 1 and
                    consultation.processed(duplicate_event.event_id))
    check(duplicate_ok, "Exact duplicate event creates exactly one consultation")

    print("\n=== FINAL CONSISTENCY CHECK ===")
    check(appointment.appointment_status("apt-happy") == "CREATED" and
          consultation.consultation_count("apt-happy") == 1,
          "Happy path: appointment CREATED, consultation present")
    check(appointment.appointment_status("apt-compensate") == "CANCELLED" and
          consultation.consultation_count("apt-compensate") == 0,
          "Compensation path: appointment CANCELLED, no partial consultation")
    check(consultation.consultation_count("apt-duplicate") == 1,
          "Duplicate path: exactly one consultation")

    print("\n=== ACTIVITY RESULT ===")
    check(appointment.database != consultation.database, "Database per service")
    check(happy_ok, "Saga")
    check(compensated, "Compensation")
    check(appointment.outbox_status(event.event_id) == "PUBLISHED", "Outbox")
    check(pending_after_failure and retry_ok, "Outbox retry")
    check(duplicate_ok, "Idempotent consumer")
    check(consumer_failed, "Failure handling")
    check(no_partial_consultation and compensated, "Final consistency")


if __name__ == "__main__":
    run()
