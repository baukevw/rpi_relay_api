#\ -s puma -o 0.0.0.0 -p 9292 -O Threads=1:1 --pidfile tmp/pids/puma.pid -d
require './api'
run RelayAPI
