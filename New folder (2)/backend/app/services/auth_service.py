from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.user import User, UserRole
from app.schemas.auth import UserRegisterRequest, UserLoginRequest, TokenResponse
from app.core.security import get_password_hash, verify_password, create_access_token, create_refresh_token

class AuthService:
    @staticmethod
    def register_user(db: Session, req: UserRegisterRequest) -> User:
        existing = db.query(User).filter(User.email == req.email).first()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="A user with this email address already exists."
            )
        user = User(
            email=req.email,
            hashed_password=get_password_hash(req.password),
            full_name=req.full_name,
            role=req.role,
            is_active=True
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def authenticate_user(db: Session, req: UserLoginRequest) -> TokenResponse:
        user = db.query(User).filter(User.email == req.email).first()
        if not user or not verify_password(req.password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password."
            )
        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="This user account has been deactivated."
            )
        
        access_token = create_access_token(subject=user.id, role=user.role)
        refresh_token = create_refresh_token(subject=user.id)
        
        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            user_id=user.id,
            role=user.role,
            full_name=user.full_name
        )
