#\ -s puma -o 0.0.0.0 -p 9292 -O Threads=1:1 -D
require './api'
run RelayAPI
