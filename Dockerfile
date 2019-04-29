FROM python:3.7-slim

# install dependencies
RUN apt-get update && \
    apt-get -yq dist-upgrade && \
    apt-get install -y --reinstall build-essential && \
    apt-get install --no-install-recommends -yq git libblas-dev libffi-dev liblapack-dev && \
    rm -rf /var/lib/apt/lists/*

# install jupyter notebook, matplotlib, qutip
RUN pip install --no-cache --upgrade pip
RUN pip install notebook==5.7.8
RUN pip install cython==0.29.6 numpy==1.16.2 scipy==1.2.1
RUN pip install qutip==4.3.1

# dependencies for .NET SDK
RUN apt-get update && apt-get -y install wget && \
    apt-get update && apt-get -y install pgp && \
    apt-get update && apt-get -y install libgomp1 && \
# add vim for editing local files:
    apt-get update && apt-get -y install vim

# install .NET SDK 2.2
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg && \
    mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/ && \
    wget -q https://packages.microsoft.com/config/debian/9/prod.list && \
    mv prod.list /etc/apt/sources.list.d/microsoft-prod.list && \
    chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    chown root:root /etc/apt/sources.list.d/microsoft-prod.list && \
    apt-get -y install apt-transport-https && \
    apt-get -y update && \
    apt-get -y install dotnet-sdk-2.2

# install qvm
COPY --from=rigetti/qvm:1.7.0 /src /src

# install quantum packages
RUN pip install pybind11==2.2.4 # dependency for projectq
RUN pip install projectq==0.4.2 --no-cache-dir
RUN pip install pyquil==2.6.0
RUN pip install qiskit==0.8.0 --no-cache-dir
RUN pip install cirq==0.5.0
RUN pip install qsharp==0.5.1904.1302

# install matplotlib (cirq downgrades to 2.x)
RUN pip install matplotlib==3.0.3

# create user with a home directory
# Required for mybinder.org
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER=${NB_USER} \
    HOME=/home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}
USER ${USER}

# Make sure .net tools is in the path
ENV PATH=$PATH:${HOME}/dotnet:${HOME}/.dotnet/tools \
    DOTNET_ROOT=${HOME}/dotnet

# install IQSharp
RUN dotnet tool install -g Microsoft.Quantum.IQSharp
RUN dotnet iqsharp install --user --path-to-tool="${HOME}/.dotnet/tools/dotnet-iqsharp"

# Make sure the contents of our repo are in ${HOME}
# Required for mybinder.org
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

EXPOSE 8888
