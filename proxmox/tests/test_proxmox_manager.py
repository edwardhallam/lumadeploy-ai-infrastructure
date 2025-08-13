"""
Tests for ProxmoxManager class
"""
import pytest
from unittest.mock import Mock, patch, MagicMock
from src.main import ProxmoxManager, get_config


class TestProxmoxManager:
    """Test cases for ProxmoxManager class"""
    
    @pytest.fixture
    def mock_response(self):
        """Mock response fixture"""
        mock = Mock()
        mock.status_code = 200
        mock.json.return_value = {'data': [{'node': 'pve01', 'status': 'online'}]}
        mock.text = '{"data": [{"node": "pve01", "status": "online"}]}'
        mock.headers = {'Content-Type': 'application/json'}
        return mock
    
    @pytest.fixture
    def mock_session(self):
        """Mock session fixture"""
        with patch('src.main.requests.Session') as mock_session:
            mock_instance = Mock()
            mock_instance.headers = {}
            mock_session.return_value = mock_instance
            yield mock_instance
    
    def test_proxmox_manager_initialization(self, mock_session):
        """Test ProxmoxManager initialization"""
        with patch.object(ProxmoxManager, 'test_connection', return_value=True):
            manager = ProxmoxManager("127.0.0.1", "test-token", 8006, False)
            
            assert manager.host == "127.0.0.1"
            assert manager.api_token == "test-token"
            assert manager.port == 8006
            assert manager.verify_ssl is False
            assert manager.base_url == "https://127.0.0.1:8006/api2/json"
    
    def test_proxmox_manager_from_env_success(self, mock_session):
        """Test ProxmoxManager.from_env() success case"""
        with patch.dict('os.environ', {
            'PROXMOX_HOST': '127.0.0.1',
            'PROXMOX_PORT': '8006',
            'PROXMOX_VERIFY_SSL': 'false',
            'PROXMOX_API_TOKEN': 'test-token'
        }), patch.object(ProxmoxManager, 'test_connection', return_value=True):
            
            manager = ProxmoxManager.from_env()
            
            assert manager.host == "127.0.0.1"
            assert manager.port == 8006
            assert manager.verify_ssl is False
            assert manager.api_token == "test-token"
    
    def test_proxmox_manager_from_env_missing_token(self, mock_session):
        """Test ProxmoxManager.from_env() with missing token"""
        with patch.dict('os.environ', {
            'PROXMOX_HOST': '127.0.0.1',
            'PROXMOX_PORT': '8006',
            'PROXMOX_VERIFY_SSL': 'false'
        }, clear=True):
            with pytest.raises(ValueError, match="PROXMOX_API_TOKEN environment variable is required"):
                ProxmoxManager.from_env()
    
    def test_get_nodes_success(self, mock_session, mock_response):
        """Test successful get_nodes() call"""
        mock_session.get.return_value = mock_response
        
        with patch.object(ProxmoxManager, 'test_connection', return_value=True):
            manager = ProxmoxManager("127.0.0.1", "test-token")
            nodes = manager.get_nodes()
            
            assert len(nodes) == 1
            assert nodes[0]['node'] == 'pve01'
            assert nodes[0]['status'] == 'online'
    
    def test_get_nodes_failure(self, mock_session):
        """Test get_nodes() with API failure"""
        mock_response = Mock()
        mock_response.raise_for_status.side_effect = Exception("API Error")
        mock_session.get.return_value = mock_response
        
        with patch.object(ProxmoxManager, 'test_connection', return_value=True):
            manager = ProxmoxManager("127.0.0.1", "test-token")
            nodes = manager.get_nodes()
            
            assert nodes == []
    
    def test_connection_failure_initialization(self, mock_session):
        """Test ProxmoxManager initialization with connection failure"""
        with patch.object(ProxmoxManager, 'test_connection', return_value=False):
            with pytest.raises(ConnectionError, match="Failed to connect to Proxmox host: 127.0.0.1"):
                ProxmoxManager("127.0.0.1", "test-token")


class TestConfig:
    """Test cases for configuration functions"""
    
    def test_get_config_defaults(self):
        """Test get_config() with default values"""
        with patch.dict('os.environ', {}, clear=True):
            config = get_config()
            
            assert config['host'] == 'localhost'
            assert config['port'] == 8006
            assert config['verify_ssl'] is False
            assert config['api_token'] == ''
    
    def test_get_config_custom_values(self):
        """Test get_config() with custom values"""
        with patch.dict('os.environ', {
            'PROXMOX_HOST': '127.0.0.1',
            'PROXMOX_PORT': '8443',
            'PROXMOX_VERIFY_SSL': 'true',
            'PROXMOX_API_TOKEN': 'test-token'
        }):
            config = get_config()
            
            assert config['host'] == '127.0.0.1'
            assert config['port'] == 8443
            assert config['verify_ssl'] is True
            assert config['api_token'] == 'test-token'
    
    def test_get_config_port_conversion(self):
        """Test get_config() port string to int conversion"""
        with patch.dict('os.environ', {'PROXMOX_PORT': '9000'}):
            config = get_config()
            assert config['port'] == 9000
            assert isinstance(config['port'], int)
