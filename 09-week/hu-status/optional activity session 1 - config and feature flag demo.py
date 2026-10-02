"""Runnable Week 09 Session 1 example; this is not the Professional API service."""

import csv
import io
import os
import sys
import unittest
from dataclasses import dataclass, field
from typing import Mapping, TextIO


class ConfigurationError(ValueError):
    """Safe-to-display configuration error that never includes supplied values."""


class FeatureDisabledError(RuntimeError):
    """Raised when a caller attempts to use a disabled optional capability."""


@dataclass(frozen=True)
class RuntimeConfig:
    db_url: str = field(repr=False)
    db_username: str = field(repr=False)
    db_password: str = field(repr=False)
    jwt_secret: str = field(repr=False)
    cors_origins: str
    port: int
    specialty_catalog_export_enabled: bool = False


REQUIRED_VARIABLES = (
    "DB_URL",
    "DB_USERNAME",
    "DB_PASSWORD",
    "JWT_SECRET",
    "CORS_ORIGINS",
    "PORT",
)
FEATURE_FLAG = "PROFESSIONAL_SPECIALTY_CATALOG_EXPORT_ENABLED"


def load_config(environ: Mapping[str, str]) -> RuntimeConfig:
    """Validate the activity's documented example configuration."""
    values = {}
    for name in REQUIRED_VARIABLES:
        value = environ.get(name, "").strip()
        if not value:
            raise ConfigurationError(f"{name} is required")
        values[name] = value

    try:
        port = int(values["PORT"])
    except ValueError:
        raise ConfigurationError("PORT must be an integer from 1 to 65535") from None
    if not 1 <= port <= 65535:
        raise ConfigurationError("PORT must be an integer from 1 to 65535")

    flag_value = environ.get(FEATURE_FLAG, "false").strip().lower()
    if flag_value not in {"true", "false"}:
        raise ConfigurationError(f"{FEATURE_FLAG} must be true or false")

    return RuntimeConfig(
        db_url=values["DB_URL"],
        db_username=values["DB_USERNAME"],
        db_password=values["DB_PASSWORD"],
        jwt_secret=values["JWT_SECRET"],
        cors_origins=values["CORS_ORIGINS"],
        port=port,
        specialty_catalog_export_enabled=flag_value == "true",
    )


def export_specialty_catalog(specialties: list[str], config: RuntimeConfig) -> str:
    """Export specialty reference names to CSV only when the flag is enabled."""
    if not config.specialty_catalog_export_enabled:
        raise FeatureDisabledError("Specialty catalog export is disabled")

    output = io.StringIO(newline="")
    writer = csv.writer(output)
    writer.writerow(("specialty",))
    writer.writerows((specialty,) for specialty in specialties)
    return output.getvalue()


def run(environ: Mapping[str, str], output: TextIO) -> int:
    try:
        config = load_config(environ)
    except ConfigurationError as error:
        print(f"Configuration error: {error}", file=output)
        return 1

    capability = "enabled" if config.specialty_catalog_export_enabled else "disabled"
    print(f"Configuration valid; specialty catalog export is {capability}.", file=output)
    return 0


def main() -> int:
    return run(os.environ, sys.stderr)


class RuntimeConfigTests(unittest.TestCase):
    def setUp(self) -> None:
        self.valid_environment = {
            "DB_URL": "jdbc:postgresql://localhost:5432/example",
            "DB_USERNAME": "test-user",
            "DB_PASSWORD": "fake-test-password",
            "JWT_SECRET": "fake-test-jwt-secret",
            "CORS_ORIGINS": "http://localhost:4200",
            "PORT": "8080",
        }

    def test_valid_configuration_loads(self) -> None:
        config = load_config(self.valid_environment)

        self.assertEqual(config.port, 8080)
        self.assertFalse(config.specialty_catalog_export_enabled)
        self.assertNotIn("fake-test-password", repr(config))
        self.assertNotIn("fake-test-jwt-secret", repr(config))

    def test_missing_required_variable_fails_without_value(self) -> None:
        environment = dict(self.valid_environment)
        del environment["JWT_SECRET"]

        with self.assertRaisesRegex(ConfigurationError, "JWT_SECRET is required"):
            load_config(environment)

    def test_startup_reports_missing_variable_without_secret_values(self) -> None:
        environment = dict(self.valid_environment)
        environment["DB_PASSWORD"] = "fake-startup-password"
        del environment["DB_URL"]
        output = io.StringIO()

        self.assertEqual(run(environment, output), 1)
        self.assertIn("DB_URL is required", output.getvalue())
        self.assertNotIn("fake-startup-password", output.getvalue())

    def test_invalid_port_fails_without_echoing_value_or_secrets(self) -> None:
        environment = dict(self.valid_environment)
        environment["PORT"] = "not-a-port"
        output = io.StringIO()

        self.assertEqual(run(environment, output), 1)
        self.assertIn("PORT must be an integer", output.getvalue())
        self.assertNotIn("not-a-port", output.getvalue())
        self.assertNotIn("fake-test-password", output.getvalue())
        self.assertNotIn("fake-test-jwt-secret", output.getvalue())

    def test_feature_flag_off_blocks_export(self) -> None:
        config = load_config(self.valid_environment)

        with self.assertRaises(FeatureDisabledError):
            export_specialty_catalog(["Cardiology"], config)

    def test_feature_flag_on_exports_specialty_catalog(self) -> None:
        environment = dict(self.valid_environment)
        environment[FEATURE_FLAG] = "true"
        config = load_config(environment)

        self.assertEqual(
            export_specialty_catalog(["Cardiology"], config),
            "specialty\r\nCardiology\r\n",
        )

    def test_invalid_feature_flag_fails_closed(self) -> None:
        environment = dict(self.valid_environment)
        environment[FEATURE_FLAG] = "sometimes"

        with self.assertRaisesRegex(ConfigurationError, f"{FEATURE_FLAG} must be true or false"):
            load_config(environment)


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--validate":
        sys.exit(main())
    unittest.main()
