#!/bin/bash
TOKEN=${1:-quantum}
jupyter notebook --ip 0.0.0.0 --port 8888 --NotebookApp.token=$TOKEN
