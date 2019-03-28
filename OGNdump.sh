#!/bin/bash
mysqldump --add-drop-table -q -u ognwriter -paksdkqre912eqwkadkad ognrange  >/tmp/OGNrangedump.sql
gzip /tmp/OGNrangedump.sql
