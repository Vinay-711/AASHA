import sqlalchemy
from app.models.user import UUIDType
from sqlalchemy.orm import relationship

from app.core.database import Base

class Guardian(Base):
    __tablename__ = "guardians"
    id = sqlalchemy.Column(UUIDType(), primary_key=True)
    user_id = sqlalchemy.Column(UUIDType(), sqlalchemy.ForeignKey("users.id"))
    user = relationship("User")
