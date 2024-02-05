## PalWorld Dedicated Server Docker Image

[![Build](https://github.com/AdamYoung1234/palworld_docker/actions/workflows/publish.yaml/badge.svg)](https://github.com/AdamYoung1234/palworld_docker/actions/workflows/publish.yaml)

### Save Files

External storage is used for server configuration and saves. Mount volume or directory to /data folder.

### systemd

Use ```container-palworld.service``` if systemd is used to manage service.

#### Note

Default port for host is 8211 change to whatever port you want to use in service file
