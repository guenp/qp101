# Getting started with Quantum Programming #
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/guenp/qp101/master)

This repo contains some demo notebooks for getting started with programming quantum circuits.

## Installation

*Dependencies*: [Docker Desktop](https://www.docker.com/products/docker-desktop)

To build the docker image, run `docker build -t qp101 .` in the root directory.
To start Jupyter notebook in the docker container, run `./start.sh <port> <token>`, where `<port>` is your preferred port for the notebooks (default: `8448`) and `<token>` is the secret token for your notebook server (default: `quantum`).
