import sys, argparse
from azureml.core import Workspace

# Parse arguments for workspace details
parser = argparse.ArgumentParser()
parser.add_argument('--workspace', required=True)
parser.add_argument('--resource-group', required=True)
parser.add_argument('--subscription', required=False)
args = parser.parse_args()

# Get workspace handle
ws = Workspace.get(name=args.workspace, resource_group=args.resource_group, subscription_id=args.subscription)

# Import and call pipeline registration functions
import alphafold_pipeline, rosettafold_pipeline
print("Registering AlphaFold pipeline...")
alphafold_pipeline.publish_pipeline(ws)   # (Assuming our alphafold_pipeline.py has a function to publish given a Workspace)
print("Registering RoseTTAFold pipeline...")
rosettafold_pipeline.publish_pipeline(ws)
print("Pipeline registration completed.")
