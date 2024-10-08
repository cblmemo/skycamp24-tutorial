FROM continuumio/miniconda3:4.12.0

# Set bash as default shell
ENV SHELL /bin/bash

WORKDIR /skycamp-tutorial

ADD ./requirements.txt /skycamp-tutorial/requirements.txt

# Install tutorial dependencies
RUN pip install -r requirements.txt

# Install SkyPilot + dependencies
RUN pip install git+https://github.com/skypilot-org/skypilot.git@992a44d268133551513f75f20090b813fe0d9554#egg=skypilot[gcp,kubernetes]

RUN apt update -y && \
    apt install rsync nano vim curl socat netcat -y && \
    rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH $PATH:/root/google-cloud-sdk/bin
RUN gcloud components install kubectl gke-gcloud-auth-plugin

# Copy credentials.
# UPDATE - no longer required. Instead mount the .aws and .config dirs to /credentials and it will be copied over.
# COPY src/.aws /root/.aws
# COPY src/.config/gcloud /root/.config/gcloud

# Exclude usage logging message
RUN mkdir -p /root/.sky && touch /root/.sky/privacy_policy

# Add files which may change frequently
COPY . /skycamp-tutorial
COPY ./github-key /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa && rm /skycamp-tutorial/github-key

# Setup gcp credentials
ENV GOOGLE_APPLICATION_CREDENTIALS /root/gcp-key.json
ENV GCP_PROJECT_ID skycamp-skypilot-fastchat
ENV SKYPILOT_DEV 1

RUN jupyter lab --generate-config && \
    echo "c.NotebookApp.allow_origin = '*'" >> ~/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.trust_xheaders = True" >> ~/.jupyter/jupyter_notebook_config.py


CMD ["/bin/bash", "-c", "echo 'export PATH=$PATH:/root/google-cloud-sdk/bin' >> /root/.bashrc; cp -a /credentials/. /root/;gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS;gcloud config set project $GCP_PROJECT_ID;sky show-gpus;jupyter lab --no-browser --ip '*' --allow-root --notebook-dir=/skycamp-tutorial --NotebookApp.token='SkyCamp2023' --NotebookApp.base_url=$BASE_URL"]
