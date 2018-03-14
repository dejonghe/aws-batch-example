from centos/python-36-centos7

USER root
COPY ./ /var/app/
WORKDIR /var/app
RUN python setup.py sdist && \
    pip install dist/schedule-0.0.0.tar.gz

CMD [ "schedule", "-r", "us-east-1", "-q", "MyQueue", "-j", "'Process:1'" ]
