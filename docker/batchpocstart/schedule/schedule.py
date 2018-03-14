import boto3
import random
import string
from boto3.session import Session

def random_four():
    """Returns a random 4 charactors"""
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=4))


class Schedule(object):
    """Sets up an AWS boto3 client and can schedule AWS Batch Jobs that depend on one another"""
    def __init__(self,profile=None,region='us-east-1'):
        """Schedule(profile=None,region='us-east-1') Creates the AWS boto3 client"""
        session = Session(profile_name=profile,region_name=region)
        self.client = session.client('batch')

    def run(self,queue,jobdef):
        """run(queue,jobdef) Submits 5 jobs, job1, job2[a-c], and job3. The 3 job2 jobs depend on job1, and job3 depends on all job2's."""
        # Creates semi unique job names for each job
        job1Name = 'job1' + random_four()
        job2aName = 'job2a' + random_four()
        job2bName = 'job2b' + random_four()
        job2cName = 'job2c' + random_four()
        job3Name = 'job3' + random_four()

        # Submit job1 to the qeueu
        job1 = self.client.submit_job(
            jobName=job1Name,
            jobQueue=queue,
            jobDefinition=jobdef
        )
        print("Submited JobName: {}, JobId: {}, Runs After: [ ]".format(job1['jobName'],job1['jobId']))

        # Submit jobs 2a, 2b, 2c, all of which depend on job1
        job2a = self.client.submit_job(
            jobName=job2aName,
            jobQueue=queue,
            jobDefinition=jobdef,
            dependsOn=[
                { 
                    'jobId': job1['jobId'],
                    'type': 'SEQUENTIAL'
                }
            ]
        )
        print("Submited JobName: {}, JobId: {}, Runs After: [ {} ]".format(job2a['jobName'],job2a['jobId'],job1['jobName']))
        job2b = self.client.submit_job(
            jobName=job2bName,
            jobQueue=queue,
            jobDefinition=jobdef,
            dependsOn=[
                { 
                    'jobId': job1['jobId'],
                    'type': 'SEQUENTIAL'
                }
            ]
        )
        print("Submited JobName: {}, JobId: {}, Runs After: [ {} ]".format(job2b['jobName'],job2b['jobId'],job1['jobName']))
        job2c = self.client.submit_job(
            jobName=job2cName,
            jobQueue=queue,
            jobDefinition=jobdef,
            dependsOn=[
                { 
                    'jobId': job1['jobId'],
                    'type': 'SEQUENTIAL'
                }
            ]
        )
        print("Submited JobName: {}, JobId: {}, Runs After: [ {} ]".format(job2c['jobName'],job2c['jobId'],job1['jobName']))

        # Submits job3 which depends on job2a, job2b, jobc
        job3 = self.client.submit_job(
            jobName=job3Name,
            jobQueue=queue,
            jobDefinition=jobdef,
            dependsOn=[
                { 
                    'jobId': job2a['jobId'],
                    'type': 'SEQUENTIAL'
                },
                { 
                    'jobId': job2b['jobId'],
                    'type': 'SEQUENTIAL'
                },
                { 
                    'jobId': job2c['jobId'],
                    'type': 'SEQUENTIAL'
                }
            ]
        )
        print("Submited JobName: {}, JobId: {}, Runs After: [ {}, {}, {} ]".format(job3['jobName'],job3['jobId'],job2a['jobName'],job2b['jobName'],job2c['jobName']))


