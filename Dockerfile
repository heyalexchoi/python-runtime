# This Dockerfile is derived from what was generatd by the build.sh script
# it has been simplified and cleaned up since I just want a working
# python3.7 docker image on ubuntu 18.0.4 to replace the outdated google app engine python image

# The Google App Engine base image is debian (jessie) with ca-certificates
# installed.
# Source: https://github.com/GoogleCloudPlatform/debian-docker
FROM gcr.io/gcp-runtimes/ubuntu_18_0_4:latest

ADD runtime-image/resources /resources
ADD runtime-image/scripts /scripts

# Install Python3.7, pip, and C dev libraries necessary to compile the most popular
# Python libraries.
RUN /scripts/install-apt-packages.sh
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && python3.7 ./get-pip.py && ln -s /usr/local/bin/pip /usr/bin/pip

# Setup locale. This prevents Python 3 IO encoding issues.
ENV LANG C.UTF-8
# Make stdout/stderr unbuffered. This prevents delay between output and cloud
# logging collection.
ENV PYTHONUNBUFFERED 1

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 50 && \
      update-alternatives --install /usr/local/bin/pip3 pip3 /usr/local/bin/pip3.7 50

# comment this out, and go into the image and see how to properly use pip from apt-get installation
# Upgrade pip (debian package version tends to run a few version behind) and
# install virtualenv system-wide.
RUN /usr/local/bin/pip3.7 install --upgrade -r resources/requirements.txt && \
    rm -f /opt/python3.7/bin/pip /opt/python3.7/bin/pip3 && \
    /usr/local/bin/pip3.7 install --upgrade -r resources/requirements-virtualenv.txt

# Setup the app working directory
RUN ln -s /home/vmagent/app /app
WORKDIR /app

# Port 8080 is the port used by Google App Engine for serving HTTP traffic.
EXPOSE 8080
ENV PORT 8080

# The user's Dockerfile must specify an entrypoint with ENTRYPOINT or CMD.
CMD []
