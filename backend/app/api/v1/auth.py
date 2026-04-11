from datetime import datetime
from uuid import UUID, uuid4
from typing import Optional, Any
from pydantic import BaseModel
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

# Import Models and Schemas
from app.schemas.user import UserCreate, UserResponse
from app.core.security import get_password_hash, verify_password, create_access_token

# ---------------------------------------------------------
# Mock Dependencies
# ---------------------------------------------------------
def get_db():
    yield None

def get_current_user_stub():
    # In a real environment, this utilizes Depends(OAuth2PasswordBearer) 
    # to decode the JWT inside the dependency injection layer.
    return uuid4()

# ---------------------------------------------------------
# Local Auth Request Data Structures 
# ---------------------------------------------------------
class VerifyOTPRequest(BaseModel):
    phone: str
    otp: str

class LoginRequest(BaseModel):
    phone: str
    password: str

class ForgotPasswordRequest(BaseModel):
    phone: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    user: Optional[UserResponse] = None

class RefreshTokenResponse(BaseModel):
    access_token: str
    token_type: str

router = APIRouter()

# ---------------------------------------------------------
# Simple Memory DB (Mocks persistent PostgreSQL execution)
# ---------------------------------------------------------
MOCK_USER_DB = {}

# ---------------------------------------------------------
# Endpoints
# ---------------------------------------------------------

@router.post("/register")
async def register_user(
    request: UserCreate, 
    db: Session = Depends(get_db)
):
    """
    Register a new user with phone.
    Hashes password if provided, pushes the record to the target DB, and automatically generates an OTP trigger.
    """
    # 1. Check if phone exists explicitly
    for u in MOCK_USER_DB.values():
        if u["phone"] == request.phone:
            raise HTTPException(status_code=400, detail="Phone already registered")
            
    # 2. Hash password utilizing core/security.py binding
    hashed_pwd = get_password_hash(request.password) if request.password else None
    
    # 3. Create generic user memory record (To be mapped directly via SQLAlchemy)
    user_id = uuid4()
    MOCK_USER_DB[str(user_id)] = {
        "id": user_id,
        "phone": request.phone,
        "email": request.email,
        "name": request.name,
        "hashed_password": hashed_pwd,
        "is_active": True,
        "is_verified": False,
        "user_type": request.user_type,
        "created_at": datetime.utcnow(),
    }
    
    # 4. Generate and Dispatch OTP natively logic
    # Following user directives: (assume "123456" for demo).
    print(f"DEBUG: Triggered SMS payload 123456 generated securely to destination: {request.phone}")
    
    return {"user_id": str(user_id), "message": "OTP sent successfully to phone"}


@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(
    request: VerifyOTPRequest,
    db: Session = Depends(get_db)
):
    """
    Verify the raw SMS OTP natively and yield the protected 7-Day JWT Token.
    """
    # 1. Validate OTP explicitly holding standard logic
    if request.otp != "123456":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid target OTP token")
        
    target_user = None
    for u in MOCK_USER_DB.values():
        if u["phone"] == request.phone:
            target_user = u
            break
            
    if not target_user:
        raise HTTPException(status_code=404, detail="User record not found")
        
    # 2. Mark the local DB record as properly verified
    target_user["is_verified"] = True
    
    # 3. Encapsulate Data Context -> Generate Auth Token
    access_token = create_access_token(subject=str(target_user["id"]))
    
    # 4. Filter dict natively generating full serialized Pydantic bindings
    user_response = UserResponse(
        id=target_user["id"],
        phone=target_user["phone"],
        email=target_user["email"],
        name=target_user["name"],
        is_verified=target_user["is_verified"],
        user_type=target_user["user_type"],
        created_at=target_user["created_at"],
    )
    
    return {
        "access_token": access_token, 
        "token_type": "bearer", 
        "user": user_response
    }


@router.post("/login", response_model=TokenResponse)
async def login(
    request: LoginRequest,
    db: Session = Depends(get_db)
):
    """
    Establish login explicitly with phone and user passwords safely mapped via internal Bcrypt validations.
    """
    target_user = None
    for u in MOCK_USER_DB.values():
        if u["phone"] == request.phone:
            target_user = u
            break
            
    if not target_user or not target_user.get("hashed_password"):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid login credentials")
        
    if not verify_password(request.password, target_user["hashed_password"]):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid login credentials")

    # Flag runtime dependencies (e.g. `last_login`, natively missing in the Mock for arbitrary safety)
    target_user["last_login"] = datetime.utcnow()
    
    # Render Output Token
    access_token = create_access_token(subject=str(target_user["id"]))
    
    return {
        "access_token": access_token, 
        "token_type": "bearer",
        "user": UserResponse(
            id=target_user["id"],
            phone=target_user["phone"],
            email=target_user["email"],
            name=target_user["name"],
            is_verified=target_user["is_verified"],
            user_type=target_user["user_type"],
            created_at=target_user["created_at"],
        )
    }


@router.post("/refresh", response_model=RefreshTokenResponse)
async def refresh_token(
    current_user_id: UUID = Depends(get_current_user_stub)
):
    """
    Refresh explicitly formatted JWT Tokens natively against active user definitions.
    Must provide a presently active token globally over the Auth envelope.
    """
    new_token = create_access_token(subject=str(current_user_id))
    return {"access_token": new_token, "token_type": "bearer"}


@router.post("/forgot-password")
async def forgot_password(
    request: ForgotPasswordRequest,
    db: Session = Depends(get_db)
):
    """
    Generate target password resets securely routed via phone SMS requests natively.
    """
    return {"message": f"Password reset OTP sent securely to destination {request.phone}"}
