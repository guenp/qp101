#!/bin/bash
PORT=${1:-8888}
TOKEN=${2:-quantum}
echo ##############################################
echo Starting docker container, exposing port $PORT;
echo "Open notebook here: http://localhost:${PORT}/login?token=${TOKEN}";
echo ##############################################
docker run -it -p $PORT:8888 -v ${PWD} qp101 bash -c "./start_notebook.sh $TOKEN"
