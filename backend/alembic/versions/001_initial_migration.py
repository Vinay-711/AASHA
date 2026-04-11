"""initial schema

Revision ID: 001_initial_migration
Revises: 
Create Date: 2026-04-10 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '001_initial_migration'
down_revision = None
branch_labels = None
depends_on = None

def upgrade() -> None:
    # ------------------------------------------------------------------
    # 1. users
    # ------------------------------------------------------------------
    op.create_table('users',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('phone', sa.String(length=15), nullable=False),
        sa.Column('email', sa.String(length=255), nullable=True),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('hashed_password', sa.String(length=255), nullable=True),
        sa.Column('is_active', sa.Boolean(), server_default='true', nullable=True),
        sa.Column('is_verified', sa.Boolean(), server_default='false', nullable=True),
        sa.Column('user_type', sa.Enum('elderly', 'family', 'guardian', 'admin', name='user_types_enum'), server_default='elderly', nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.Column('last_login', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_users_phone', 'users', ['phone'], unique=True)
    op.create_index('ix_users_email', 'users', ['email'], unique=True)
    op.create_index('ix_users_user_type', 'users', ['user_type'], unique=False)

    # ------------------------------------------------------------------
    # 2. emergency_contacts
    # ------------------------------------------------------------------
    op.create_table('emergency_contacts',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('phone', sa.String(length=15), nullable=False),
        sa.Column('relationship', sa.String(length=50), nullable=False),
        sa.Column('priority', sa.Integer(), nullable=False),
        sa.Column('is_verified', sa.Boolean(), server_default='false', nullable=True),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_emergency_contacts_user_id', 'emergency_contacts', ['user_id'], unique=False)

    # ------------------------------------------------------------------
    # 3. medications
    # ------------------------------------------------------------------
    op.create_table('medications',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('generic_name', sa.String(length=100), nullable=True),
        sa.Column('dosage', sa.String(length=50), nullable=False),
        sa.Column('frequency', sa.String(length=50), nullable=False),
        sa.Column('timing', postgresql.JSON(astext_type=sa.Text()), nullable=False),
        sa.Column('start_date', sa.Date(), nullable=False),
        sa.Column('end_date', sa.Date(), nullable=True),
        sa.Column('instructions', sa.Text(), nullable=True),
        sa.Column('color_code', sa.String(length=7), nullable=True),
        sa.Column('shape', sa.String(length=20), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_medications_user_id', 'medications', ['user_id'], unique=False)

    # ------------------------------------------------------------------
    # 4. medication_logs
    # ------------------------------------------------------------------
    op.create_table('medication_logs',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('medication_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('taken_at', sa.DateTime(), nullable=False),
        sa.Column('scheduled_for', sa.DateTime(), nullable=False),
        sa.Column('status', sa.Enum('taken', 'missed', 'skipped', name='log_status_enum'), nullable=False),
        sa.Column('location', postgresql.JSON(astext_type=sa.Text()), nullable=True),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.ForeignKeyConstraint(['medication_id'], ['medications.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_medication_logs_medication_id', 'medication_logs', ['medication_id'], unique=False)
    op.create_index('ix_medication_logs_user_id', 'medication_logs', ['user_id'], unique=False)

    # ------------------------------------------------------------------
    # 5. pharmacies
    # ------------------------------------------------------------------
    op.create_table('pharmacies',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('name', sa.String(length=200), nullable=False),
        sa.Column('address', sa.Text(), nullable=False),
        sa.Column('phone', sa.String(length=15), nullable=True),
        sa.Column('email', sa.String(length=255), nullable=True),
        sa.Column('location_lat', sa.Float(), nullable=False),
        sa.Column('location_lng', sa.Float(), nullable=False),
        sa.Column('is_verified', sa.Boolean(), server_default='false', nullable=True),
        sa.Column('is_partner', sa.Boolean(), server_default='false', nullable=True),
        sa.Column('operating_hours', postgresql.JSON(astext_type=sa.Text()), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_pharmacies_location_lat', 'pharmacies', ['location_lat'], unique=False)
    op.create_index('ix_pharmacies_location_lng', 'pharmacies', ['location_lng'], unique=False)

    # ------------------------------------------------------------------
    # 6. medicine_availability
    # ------------------------------------------------------------------
    op.create_table('medicine_availability',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('pharmacy_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('medicine_name', sa.String(length=100), nullable=False),
        sa.Column('generic_name', sa.String(length=100), nullable=True),
        sa.Column('is_available', sa.Boolean(), nullable=False),
        sa.Column('quantity', sa.String(length=50), nullable=True),
        sa.Column('expiry_date', sa.Date(), nullable=True),
        sa.Column('price', sa.Float(), nullable=True),
        sa.Column('verified_by', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('verified_at', sa.DateTime(), nullable=True),
        sa.Column('confidence_score', sa.Float(), server_default='0.0', nullable=True),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.ForeignKeyConstraint(['pharmacy_id'], ['pharmacies.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['verified_by'], ['users.id'], ondelete='SET NULL'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_medicine_availability_pharmacy_id', 'medicine_availability', ['pharmacy_id'], unique=False)
    op.create_index('ix_medicine_availability_medicine_name', 'medicine_availability', ['medicine_name'], unique=False)
    op.create_index('idx_pharmacy_medicine', 'medicine_availability', ['pharmacy_id', 'medicine_name'], unique=False)
    op.create_index('idx_medicine_available', 'medicine_availability', ['medicine_name', 'is_available'], unique=False)

    # ------------------------------------------------------------------
    # 7. guardian_profiles
    # ------------------------------------------------------------------
    op.create_table('guardian_profiles',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('certification_id', sa.String(length=100), nullable=True),
        sa.Column('specialty', sa.String(length=100), nullable=True),
        sa.Column('experience_years', sa.Integer(), nullable=True),
        sa.Column('rating', sa.Float(), server_default='0.0', nullable=True),
        sa.Column('verification_status', sa.String(length=50), server_default='pending', nullable=True),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('user_id')
    )

    # ------------------------------------------------------------------
    # 8. alerts
    # ------------------------------------------------------------------
    op.create_table('alerts',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('alert_type', sa.Enum('sos', 'missed_meds', 'vitals_irregular', 'geo_fence', name='alert_type_enum'), nullable=False),
        sa.Column('status', sa.String(length=50), server_default='active', nullable=False),
        sa.Column('location_lat', sa.Float(), nullable=True),
        sa.Column('location_lng', sa.Float(), nullable=True),
        sa.Column('priority_level', sa.Integer(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('resolved_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_alerts_user_id', 'alerts', ['user_id'], unique=False)

    # ------------------------------------------------------------------
    # 9. alert_responders
    # ------------------------------------------------------------------
    op.create_table('alert_responders',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('alert_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('responder_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('status', sa.String(length=50), server_default='notified', nullable=False),
        sa.Column('eta_minutes', sa.Integer(), nullable=True),
        sa.Column('arrived_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['alert_id'], ['alerts.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['responder_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_alert_responders_alert_id', 'alert_responders', ['alert_id'], unique=False)
    op.create_index('ix_alert_responders_responder_id', 'alert_responders', ['responder_id'], unique=False)


def downgrade() -> None:
    # Scale destruction actively dropping linearly reversed boundaries natively!
    op.drop_index('ix_alert_responders_responder_id', table_name='alert_responders')
    op.drop_index('ix_alert_responders_alert_id', table_name='alert_responders')
    op.drop_table('alert_responders')
    
    op.drop_index('ix_alerts_user_id', table_name='alerts')
    op.drop_table('alerts')
    
    op.drop_table('guardian_profiles')
    
    op.drop_index('idx_medicine_available', table_name='medicine_availability')
    op.drop_index('idx_pharmacy_medicine', table_name='medicine_availability')
    op.drop_index('ix_medicine_availability_medicine_name', table_name='medicine_availability')
    op.drop_index('ix_medicine_availability_pharmacy_id', table_name='medicine_availability')
    op.drop_table('medicine_availability')
    
    op.drop_index('ix_pharmacies_location_lng', table_name='pharmacies')
    op.drop_index('ix_pharmacies_location_lat', table_name='pharmacies')
    op.drop_table('pharmacies')
    
    op.drop_index('ix_medication_logs_user_id', table_name='medication_logs')
    op.drop_index('ix_medication_logs_medication_id', table_name='medication_logs')
    op.drop_table('medication_logs')
    
    op.drop_index('ix_medications_user_id', table_name='medications')
    op.drop_table('medications')
    
    op.drop_index('ix_emergency_contacts_user_id', table_name='emergency_contacts')
    op.drop_table('emergency_contacts')
    
    op.drop_index('ix_users_user_type', table_name='users')
    op.drop_index('ix_users_email', table_name='users')
    op.drop_index('ix_users_phone', table_name='users')
    op.drop_table('users')
    
    # Executing deep deletion mapping generic Enum bindings out securely explicitly
    sa.Enum(name='alert_type_enum').drop(op.get_bind(), checkfirst=True)
    sa.Enum(name='log_status_enum').drop(op.get_bind(), checkfirst=True)
    sa.Enum(name='user_types_enum').drop(op.get_bind(), checkfirst=True)
