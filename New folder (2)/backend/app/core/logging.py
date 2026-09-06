import logging
import sys
import re

class RedactingFormatter(logging.Formatter):
    """Masks passwords, authorization tokens, and private patient names in logs."""
    SENSITIVE_PATTERNS = [
        (re.compile(r'password["\']?\s*[:=]\s*["\']?([^"\'\s]+)', re.IGNORECASE), r'password: "[REDACTED]"'),
        (re.compile(r'Bearer\s+([A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+/=]*)', re.IGNORECASE), r'Bearer [REDACTED_TOKEN]'),
        (re.compile(r'token["\']?\s*[:=]\s*["\']?([^"\'\s]+)', re.IGNORECASE), r'token: "[REDACTED]"'),
    ]

    def format(self, record: logging.LogRecord) -> str:
        original = super().format(record)
        redacted = original
        for pattern, replacement in self.SENSITIVE_PATTERNS:
            redacted = pattern.sub(replacement, redacted)
        return redacted

def setup_logging():
    logger = logging.getLogger("smriti")
    logger.setLevel(logging.INFO)
    
    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.INFO)
    
    formatter = RedactingFormatter(
        fmt="%(asctime)s [%(levelname)s] [%(name)s] %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )
    handler.setFormatter(formatter)
    
    if not logger.handlers:
        logger.addHandler(handler)
        
    return logger

logger = setup_logging()
