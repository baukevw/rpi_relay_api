#\ -s puma -o 0.0.0.0 -p 3000 -O Threads=1:1
require './api'
run RelayAPI
