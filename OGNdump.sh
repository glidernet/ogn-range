#!/bin/bash
sudo mysqldump --add-drop-table -q  ognrange  >/tmp/OGNrangedump.sql
gzip /tmp/OGNrangedump.sql
