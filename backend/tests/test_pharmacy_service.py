"""Pharmacy regressions against real SQLAlchemy records; imports must succeed."""
import math
from datetime import datetime
from unittest.mock import MagicMock

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import Session

from app.core.database import Base
from app.models.pharmacy import Pharmacy, MedicineAvailability
from app.models.user import User
from app.services.pharmacy_service import PharmacyService, SERVICE_CACHE


@pytest.fixture
def db_session():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    SERVICE_CACHE.clear()
    with Session(engine) as session:
        yield session
    SERVICE_CACHE.clear()
    engine.dispose()


@pytest.fixture
def inventory(db_session):
    user = User(name="Test Contributor", phone="test-contributor")
    pharmacy = Pharmacy(name="Test Pharmacy", address="Test address",
                        location_lat=28.6, location_lng=77.2)
    db_session.add_all([user, pharmacy])
    db_session.flush()
    medicine = MedicineAvailability(pharmacy_id=pharmacy.id,
                                    medicine_name="Cardivas 25mg",
                                    is_available=True, verified_by=user.id,
                                    verified_at=datetime.utcnow())
    db_session.add(medicine)
    db_session.commit()
    return user, pharmacy, medicine


@pytest.mark.parametrize("coords,expected", [
    ((51.5074, -0.1278, 48.8566, 2.3522), 343.3),
    ((40.7128, -74.006, 34.0522, -118.2437), 3935.7),
    ((28.6, 77.2, 28.6, 77.2), 0),
])
def test_distance(db_session, coords, expected):
    assert math.isclose(PharmacyService(db_session)._haversine_distance(*coords),
                        expected, rel_tol=0.001, abs_tol=0.001)


@pytest.mark.asyncio
async def test_verification_does_not_overwrite_similarly_named_medicine(db_session, inventory):
    user, pharmacy, original = inventory
    await PharmacyService(db_session).verify_availability(
        user.id, pharmacy.id, "Cardivas", "out_of_stock")
    db_session.refresh(original)
    assert original.is_available is True
    assert db_session.query(MedicineAvailability).count() == 2
    new = db_session.query(MedicineAvailability).filter_by(medicine_name="Cardivas").one()
    assert new.is_available is False


@pytest.mark.asyncio
async def test_percent_and_underscore_are_literal_in_write_names(db_session, inventory):
    user, pharmacy, original = inventory
    service = PharmacyService(db_session)
    for name in ("%", "_"):
        await service.verify_availability(user.id, pharmacy.id, name, "out_of_stock")
    db_session.refresh(original)
    assert original.is_available is True
    assert db_session.query(MedicineAvailability).count() == 3


@pytest.mark.asyncio
async def test_exact_match_is_case_insensitive_and_trimmed(db_session, inventory):
    user, pharmacy, original = inventory
    result = await PharmacyService(db_session).verify_availability(
        user.id, pharmacy.id, "  CARDIVAS 25MG  ", " OUT_OF_STOCK ")
    db_session.refresh(original)
    assert original.is_available is False
    assert db_session.query(MedicineAvailability).count() == 1
    assert result.success is True


@pytest.mark.asyncio
async def test_verification_does_not_change_another_pharmacy(db_session, inventory):
    user, pharmacy, original = inventory
    other = Pharmacy(name="Other Pharmacy", address="Other address", location_lat=28.6, location_lng=77.2)
    db_session.add(other)
    db_session.commit()
    await PharmacyService(db_session).verify_availability(
        user.id, other.id, original.medicine_name, "out_of_stock")
    db_session.refresh(original)
    assert original.is_available is True
    assert db_session.query(MedicineAvailability).count() == 2


@pytest.mark.asyncio
async def test_partial_search_is_fresh_after_verification(db_session, inventory):
    user, pharmacy, medicine = inventory
    service = PharmacyService(db_session)
    before = await service.search_medicine_availability("Card", 28.6, 77.2, in_stock_only=True)
    assert len(before) == 1
    await service.verify_availability(user.id, pharmacy.id, medicine.medicine_name, "out_of_stock")
    after = await service.search_medicine_availability("Card", 28.6, 77.2, in_stock_only=True)
    assert after == []


@pytest.mark.asyncio
@pytest.mark.parametrize("name,status", [("", "in_stock"), ("  ", "in_stock"),
    ("x" * 101, "in_stock"), ("Cardivas", "unknown"), ("Cardivas", "")])
async def test_invalid_input_makes_no_database_write(db_session, inventory, name, status):
    user, pharmacy, original = inventory
    with pytest.raises(ValueError):
        await PharmacyService(db_session).verify_availability(user.id, pharmacy.id, name, status)
    assert db_session.query(MedicineAvailability).count() == 1
    db_session.refresh(original)
    assert original.is_available is True


@pytest.mark.asyncio
async def test_failed_commit_rolls_back_and_preserves_cache():
    db = MagicMock()
    db.query.return_value.filter.return_value.first.return_value = None
    db.commit.side_effect = RuntimeError("write failed")
    SERVICE_CACHE["existing"] = ([], datetime.utcnow())
    try:
        with pytest.raises(RuntimeError, match="write failed"):
            await PharmacyService(db).verify_availability("user", "pharmacy", "Cardivas", "in_stock")
        db.rollback.assert_called_once()
        assert "existing" in SERVICE_CACHE
    finally:
        SERVICE_CACHE.clear()
