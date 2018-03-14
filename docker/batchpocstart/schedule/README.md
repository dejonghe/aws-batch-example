Help on module schedule:

NAME
    schedule

FILE
    /home/derek/Projects/aws-batch-example/docker/batchpocstart/schedule/schedule.py

CLASSES
    __builtin__.object
        Schedule
    
    class Schedule(__builtin__.object)
     |  Sets up an AWS boto3 client and can schedule AWS Batch Jobs that depend on one another
     |  
     |  Methods defined here:
     |  
     |  __init__(self, profile=None, region='us-east-1')
     |      Schedule(profile=None,region='us-east-1') Creates the AWS boto3 client
     |  
     |  run(self, queue, jobdef)
     |      run(queue,jobdef) Submits 5 jobs, job1, job2[a-c], and job3. The 3 job2 jobs depend on job1, and job3 depends on all job2's.
     |  
     |  ----------------------------------------------------------------------
     |  Data descriptors defined here:
     |  
     |  __dict__
     |      dictionary for instance variables (if defined)
     |  
     |  __weakref__
     |      list of weak references to the object (if defined)

FUNCTIONS
    random_four()
        Returns a random 4 charactors
