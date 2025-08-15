"""
Custom exceptions for Proxmox Management Tool
"""

from typing import Optional


class ProxmoxError(Exception):
    """Base exception for Proxmox management errors"""

    pass


class ProxmoxConnectionError(ProxmoxError):
    """Raised when connection to Proxmox host fails"""

    pass


class ProxmoxAuthenticationError(ProxmoxError):
    """Raised when authentication to Proxmox fails"""

    pass


class ProxmoxAPIError(ProxmoxError):
    """Raised when Proxmox API returns an error"""

    def __init__(
        self,
        message: str,
        status_code: Optional[int] = None,
        response_text: Optional[str] = None,
    ):
        super().__init__(message)
        self.status_code = status_code
        self.response_text = response_text


class ProxmoxConfigurationError(ProxmoxError):
    """Raised when configuration is invalid or missing"""

    pass


class ProxmoxResourceNotFoundError(ProxmoxError):
    """Raised when a requested Proxmox resource is not found"""

    pass
