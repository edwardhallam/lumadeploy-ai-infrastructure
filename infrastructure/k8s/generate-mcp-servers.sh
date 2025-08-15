#!/bin/bash
# Generate multiple MCP server deployments

set -e

# Configuration
MCP_SERVER_COUNT=${1:-5}
NAMESPACE="mcp-servers"
OUTPUT_DIR="./mcp-servers-generated"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "🚀 Generating $MCP_SERVER_COUNT MCP server deployments..."

# Generate individual MCP server manifests
for i in $(seq 1 $MCP_SERVER_COUNT); do
    SERVER_NAME="mcp-server-$i"
    OUTPUT_FILE="$OUTPUT_DIR/${SERVER_NAME}.yaml"

    echo "📝 Generating $SERVER_NAME..."

    cat > "$OUTPUT_FILE" << EOF
---
# MCP Server $i Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $SERVER_NAME
  namespace: $NAMESPACE
  labels:
    app: mcp-server
    instance: $SERVER_NAME
    component: ai-infrastructure
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mcp-server
      instance: $SERVER_NAME
  template:
    metadata:
      labels:
        app: mcp-server
        instance: $SERVER_NAME
        component: ai-infrastructure
    spec:
      containers:
      - name: mcp-server
        image: node:18-alpine
        ports:
        - containerPort: 3000
          name: http
        env:
        - name: NODE_ENV
          value: "production"
        - name: MCP_SERVER_PORT
          value: "3000"
        - name: MCP_SERVER_NAME
          value: "$SERVER_NAME"
        - name: MCP_SERVER_ID
          value: "$i"
        - name: LOG_LEVEL
          value: "info"
        command: ["/bin/sh"]
        args:
          - -c
          - |
            cd /app
            npm install
            npm start
        resources:
          requests:
            cpu: 500m
            memory: 512Mi
          limits:
            cpu: 1000m
            memory: 1024Mi
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: mcp-config
          mountPath: /app
          readOnly: false
        - name: mcp-data
          mountPath: /app/data
      volumes:
      - name: mcp-config
        configMap:
          name: ${SERVER_NAME}-config
          defaultMode: 0755
      - name: mcp-data
        persistentVolumeClaim:
          claimName: ${SERVER_NAME}-data
      restartPolicy: Always
---
# MCP Server $i Service
apiVersion: v1
kind: Service
metadata:
  name: $SERVER_NAME
  namespace: $NAMESPACE
  labels:
    app: mcp-server
    instance: $SERVER_NAME
spec:
  selector:
    app: mcp-server
    instance: $SERVER_NAME
  ports:
  - name: http
    port: 80
    targetPort: 3000
    protocol: TCP
  type: ClusterIP
---
# MCP Server $i ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${SERVER_NAME}-config
  namespace: $NAMESPACE
  labels:
    app: mcp-server
    instance: $SERVER_NAME
data:
  package.json: |
    {
      "name": "$SERVER_NAME",
      "version": "1.0.0",
      "description": "MCP Server $i",
      "main": "server.js",
      "scripts": {
        "start": "node server.js",
        "dev": "nodemon server.js"
      },
      "dependencies": {
        "@modelcontextprotocol/sdk": "^0.4.0",
        "express": "^4.18.0",
        "winston": "^3.10.0",
        "cors": "^2.8.5"
      }
    }
  server.js: |
    const express = require('express');
    const cors = require('cors');
    const winston = require('winston');

    // Configure logging
    const logger = winston.createLogger({
      level: process.env.LOG_LEVEL || 'info',
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.errors({ stack: true }),
        winston.format.json()
      ),
      transports: [
        new winston.transports.Console({
          format: winston.format.combine(
            winston.format.colorize(),
            winston.format.simple()
          )
        })
      ]
    });

    const app = express();
    const port = process.env.MCP_SERVER_PORT || 3000;
    const serverName = process.env.MCP_SERVER_NAME || '$SERVER_NAME';
    const serverId = process.env.MCP_SERVER_ID || '$i';

    // Middleware
    app.use(cors());
    app.use(express.json());
    app.use(express.urlencoded({ extended: true }));

    // Request logging
    app.use((req, res, next) => {
      logger.info(\`\${req.method} \${req.path}\`, {
        ip: req.ip,
        userAgent: req.get('User-Agent')
      });
      next();
    });

    // Health check endpoints
    app.get('/health', (req, res) => {
      res.json({
        status: 'healthy',
        server: serverName,
        id: serverId,
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
      });
    });

    app.get('/ready', (req, res) => {
      res.json({
        status: 'ready',
        server: serverName,
        id: serverId,
        timestamp: new Date().toISOString()
      });
    });

    // MCP Protocol endpoints
    app.get('/mcp/info', (req, res) => {
      res.json({
        name: serverName,
        version: '1.0.0',
        protocolVersion: '2024-11-05',
        capabilities: {
          logging: {},
          prompts: {},
          resources: {},
          tools: {}
        },
        serverInfo: {
          name: serverName,
          version: '1.0.0'
        }
      });
    });

    app.post('/mcp/initialize', (req, res) => {
      logger.info('MCP Server initialized', { request: req.body });
      res.json({
        protocolVersion: '2024-11-05',
        capabilities: {
          logging: {},
          prompts: {},
          resources: {},
          tools: {}
        },
        serverInfo: {
          name: serverName,
          version: '1.0.0'
        }
      });
    });

    // Sample MCP tool
    app.post('/mcp/tools/call', (req, res) => {
      const { name, arguments: args } = req.body;

      logger.info('Tool called', { name, args });

      switch (name) {
        case 'echo':
          res.json({
            content: [
              {
                type: 'text',
                text: \`Echo from \${serverName}: \${args?.message || 'Hello!'}\`
              }
            ]
          });
          break;

        case 'server-info':
          res.json({
            content: [
              {
                type: 'text',
                text: \`Server: \${serverName} (ID: \${serverId})\\nUptime: \${process.uptime()}s\\nMemory: \${JSON.stringify(process.memoryUsage())}\`
              }
            ]
          });
          break;

        default:
          res.status(400).json({
            error: {
              code: 'UNKNOWN_TOOL',
              message: \`Unknown tool: \${name}\`
            }
          });
      }
    });

    // List available tools
    app.get('/mcp/tools/list', (req, res) => {
      res.json({
        tools: [
          {
            name: 'echo',
            description: 'Echo back a message',
            inputSchema: {
              type: 'object',
              properties: {
                message: {
                  type: 'string',
                  description: 'Message to echo back'
                }
              }
            }
          },
          {
            name: 'server-info',
            description: 'Get server information',
            inputSchema: {
              type: 'object',
              properties: {}
            }
          }
        ]
      });
    });

    // Error handling
    app.use((error, req, res, next) => {
      logger.error('Unhandled error', error);
      res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Internal server error'
        }
      });
    });

    // 404 handler
    app.use((req, res) => {
      res.status(404).json({
        error: {
          code: 'NOT_FOUND',
          message: 'Endpoint not found'
        }
      });
    });

    // Start server
    app.listen(port, '0.0.0.0', () => {
      logger.info(\`MCP Server \${serverName} listening on port \${port}\`);
    });

    // Graceful shutdown
    process.on('SIGTERM', () => {
      logger.info('SIGTERM received, shutting down gracefully');
      process.exit(0);
    });

    process.on('SIGINT', () => {
      logger.info('SIGINT received, shutting down gracefully');
      process.exit(0);
    });
---
# MCP Server $i PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${SERVER_NAME}-data
  namespace: $NAMESPACE
  labels:
    app: mcp-server
    instance: $SERVER_NAME
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: longhorn
---
# MCP Server $i Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $SERVER_NAME
  namespace: $NAMESPACE
  labels:
    app: mcp-server
    instance: $SERVER_NAME
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /\$2
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /${SERVER_NAME}(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: $SERVER_NAME
            port:
              number: 80
EOF

    echo "✅ Generated $OUTPUT_FILE"
done

# Generate combined manifest
COMBINED_FILE="$OUTPUT_DIR/all-mcp-servers.yaml"
echo "📦 Creating combined manifest: $COMBINED_FILE"

cat > "$COMBINED_FILE" << EOF
# Combined MCP Servers Manifest
# Generated $(date)
# Contains $MCP_SERVER_COUNT MCP servers

EOF

# Combine all individual files
for i in $(seq 1 $MCP_SERVER_COUNT); do
    cat "$OUTPUT_DIR/mcp-server-$i.yaml" >> "$COMBINED_FILE"
    echo "" >> "$COMBINED_FILE"
done

echo ""
echo "🎉 Generated $MCP_SERVER_COUNT MCP server deployments!"
echo "📁 Output directory: $OUTPUT_DIR"
echo "📄 Individual files: mcp-server-1.yaml to mcp-server-$MCP_SERVER_COUNT.yaml"
echo "📦 Combined file: all-mcp-servers.yaml"
echo ""
echo "🚀 To deploy all MCP servers:"
echo "   kubectl apply -f $COMBINED_FILE"
echo ""
echo "🔍 To check status:"
echo "   kubectl get pods -n $NAMESPACE"
echo "   kubectl get services -n $NAMESPACE"
echo "   kubectl get ingress -n $NAMESPACE"
