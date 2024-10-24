FROM continuumio/miniconda3:4.12.0

# Set bash as default shell
ENV SHELL /bin/bash

WORKDIR /skycamp-tutorial

ADD ./requirements.txt /skycamp-tutorial/requirements.txt

# Install tutorial dependencies
RUN pip install -r requirements.txt

# Install SkyPilot + dependencies
RUN pip install git+https://github.com/skypilot-org/skypilot.git@53380e26f01452559012d57b333b17f40dd8a4d1#egg=skypilot[kubernetes,gcp,aws]

RUN apt update -y && \
    apt install rsync nano vim curl socat netcat jq -y && \
    rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH $PATH:/root/google-cloud-sdk/bin
RUN gcloud components install kubectl gke-gcloud-auth-plugin

# Exclude usage logging message
RUN mkdir -p /root/.sky && touch /root/.sky/privacy_policy

# Add files which may change frequently
COPY . /skycamp-tutorial

# Setup gcp credentials
ENV GCP_PROJECT_ID skycamp-skypilot-fastchat
ENV SKYPILOT_DEV 1
ENV GOOGLE_APPLICATION_CREDENTIALS /root/gcp-key.json
ENV HF_TOKEN_PATH /root/hf-token.txt

RUN jupyter lab --generate-config && \
    echo "c.NotebookApp.allow_origin = '*'" >> ~/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.trust_xheaders = True" >> ~/.jupyter/jupyter_notebook_config.py


# Use sky show-gpus to update the catalog, avoid random output in the notebook
CMD ["/bin/bash", "-c", \
     "echo 'export PATH=$PATH:/root/google-cloud-sdk/bin' >> /root/.bashrc; \
     cp -a /credentials/. /root/; \
     cp /credentials/config.yaml /root/.sky/config.yaml; \
     gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS; \
     gcloud config set project $GCP_PROJECT_ID; \
     sky show-gpus; \
     export HF_TOKEN=$(cat $HF_TOKEN_PATH); \
     jupyter lab --no-browser --ip '*' --allow-root --notebook-dir=/skycamp-tutorial \
         --NotebookApp.token='SkyCamp2024' --NotebookApp.base_url=$BASE_URL"]
