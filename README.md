# Pre-install

1. Install Docker on server and client  
   ```curl -fsSL https://get.docker.com/ | sudo sh```

# Demo 1 - Use port 2375 without TLS

1. Execute deploy-no-tls.sh on server  
   ```bash deploy-no-tls.sh```

# Demo 2 - Use port 2376 with TLS

1. Execute generate_certs.sh on server  
   ```bash generate_certs.sh```

2. Execute generate_client_certs.sh on client  
   ```bash generate_client_certs.sh```
