#!/bin/bash
mysqldump --add-drop-table -q --login-path=ognrange ognrange  >/tmp/OGNrangedump.sql
gzip /tmp/OGNrangedump.sql
