BatchPOCStart
=============

Overview
--------

This python module and CLI entry point sumbit 5 jobs to AWS Batch in a
defined workflow. This is intended to run from the command line or
within a docker contianer.

Workflow
--------

The workflow creates 5 jobs demonstrating a fan out, fan in workflow.
All of the jobs run the same job definition, because after all, this is
just a poc.

Job Dependancies
~~~~~~~~~~~~~~~~

       __       __
      /   Job2a   \
Job1 ---- Job2b ---- Job3 
      \__ Job2c __/

1. Job1 depends on no other jobs.
2. Job2a depends on Job1
3. Job2b depends on Job1
4. Job2c depends on Job1
5. Job3 depends on job2a, job2b, job2c

Docker
------

A `Dockerfile <./Dockerfile>`__, provided, builds the python egg and
installs it with pip. The ``CMD`` of this docker image runs the
``schedule`` command to build the workflow describe above.

Further Reading
---------------

The code is documented in DocString. It's fairly short and readable.
