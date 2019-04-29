#!/bin/bash
PORT=${1:-8448}
TOKEN=${2}
echo Starting docker container, exposing port $PORT;
docker run -it -p $PORT:8888 -v $(PWD):/code qp101 bash -c "cd /code && ./start_notebook.sh $TOKEN"
