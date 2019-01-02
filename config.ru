#\ -s puma -o 0.0.0.0 -p 9292 -O Threads=5:10 -D -P tmp/puma.pid
require './api'
run RelayAPI
