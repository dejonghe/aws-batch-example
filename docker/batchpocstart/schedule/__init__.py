#!/usr/bin/env python
import argparse
from schedule.schedule import Schedule

# Sets version used in setup.py
__version__ = '0.0.0'

def main():
    """Main entry point for schedule module."""
    # Setup parser and arguments
    parser = argparse.ArgumentParser(description='Schedule batch jobs')
    parser.add_argument("-p","--profile", help="Profile.",default=None)
    parser.add_argument("-r","--region", help="Region.",default=None)
    parser.add_argument("-q","--queue", help="Queue Name.",default=None)
    parser.add_argument("-j","--job", help="Job Definition.",default=None)
    args = parser.parse_args()

    # Setup scheduler object and call run
    scheduler = Schedule(profile=args.profile,region=args.region)
    scheduler.run(queue=args.queue,jobdef=args.job)
    

if __name__ == '__main__':
    try: main()
    except: raise
