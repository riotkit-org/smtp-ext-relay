import argparse
import sys

from .postfix import main


ap = argparse.ArgumentParser()
ap.add_argument("--env-prefix", help="Environment variables name prefix", default="USER_")

parsed = vars(ap.parse_args())
sys.exit(0 if main(parsed['env_prefix']) else 1)
