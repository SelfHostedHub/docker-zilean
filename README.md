# Docker-Zilean

Orignial Project https://github.com/iPromKnight/zilean

Compose Example 

```
version: '3.8'

services:
  zilean:
    image: ghcr.io/selfhostedhub/zilean:latest
    ports:
      - "8181:8181"
    volumes:
      - ./data:/app/data
```
