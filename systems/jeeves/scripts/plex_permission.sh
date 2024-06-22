#!/bin/bash

plex_dir="/zfs/storage/plex/"

chown docker-service:users -R "$plex_dir"
find "$plex_dir" -type f -exec chmod 664 {} \;
find "$plex_dir" -type d -exec chmod 775 {} \;
