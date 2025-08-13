"""
Configuration management for Proxmox Management Tool
"""
import os
from typing import Optional
from pydantic import BaseModel, Field, validator


class ProxmoxConfigurationError(Exception):
    """Exception for configuration errors"""
    pass


class ProxmoxConfig(BaseModel):
    """Configuration model for Proxmox connection"""
    
    host: str = Field(..., description="Proxmox host address")
    port: int = Field(default=8006, description="Proxmox API port")
    verify_ssl: bool = Field(default=False, description="Whether to verify SSL certificates")
    api_token: str = Field(..., description="Proxmox API token")
    
    class Config:
        env_prefix = "PROXMOX_"
        case_sensitive = False
    
    @validator('host')
    def validate_host(cls, v: str) -> str:
        """Validate host address"""
        if not v or v.strip() == '':
            raise ProxmoxConfigurationError("Host cannot be empty")
        return v.strip()
    
    @validator('port')
    def validate_port(cls, v: int) -> int:
        """Validate port number"""
        if not 1 <= v <= 65535:
            raise ProxmoxConfigurationError(f"Port must be between 1 and 65535, got {v}")
        return v
    
    @validator('api_token')
    def validate_api_token(cls, v: str) -> str:
        """Validate API token format"""
        if not v or v.strip() == '':
            raise ProxmoxConfigurationError("API token cannot be empty")
        
        # Basic format validation for Proxmox API tokens
        if '!' not in v or '=' not in v:
            raise ProxmoxConfigurationError(
                "API token should be in format: username!tokenid=secret"
            )
        return v.strip()
    
    def get_connection_url(self) -> str:
        """Get the full connection URL"""
        return f"https://{self.host}:{self.port}/api2/json"


def load_config() -> ProxmoxConfig:
    """Load configuration from environment variables"""
    try:
        # Get environment variables
        host = os.getenv('PROXMOX_HOST', 'localhost')
        port = int(os.getenv('PROXMOX_PORT', '8006'))
        verify_ssl = os.getenv('PROXMOX_VERIFY_SSL', 'false').lower() == 'true'
        api_token = os.getenv('PROXMOX_API_TOKEN', '')
        
        return ProxmoxConfig(
            host=host,
            port=port,
            verify_ssl=verify_ssl,
            api_token=api_token
        )
    except Exception as e:
        raise ProxmoxConfigurationError(f"Failed to load configuration: {e}")


def get_config_dict() -> dict:
    """Get configuration as dictionary (backward compatibility)"""
    config = load_config()
    return {
        'host': config.host,
        'port': config.port,
        'verify_ssl': config.verify_ssl,
        'api_token': config.api_token
    }
