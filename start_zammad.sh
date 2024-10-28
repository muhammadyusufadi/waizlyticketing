#!/bin/bash

# Start background worker
script/background-worker.rb start &

# Start websocket server
script/websocket-server.rb start &

# Run Zammad server (or any additional commands to start Zammad)
bundle exec rails server
