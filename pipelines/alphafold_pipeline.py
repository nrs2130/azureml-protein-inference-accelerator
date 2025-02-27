# alphafold_pipeline.py (excerpt)
from azureml.core import Workspace, Experiment, Environment
from azureml.pipeline.core import Pipeline, PipelineData, PublishedPipeline
from azureml.pipeline.steps import PythonScriptStep

ws = Workspace.get(name=workspace_name, subscription_id=sub_id, resource_group=rg)
# Define environment from Docker (pre-built image)
alphafold_env = Environment.from_docker_image(
    name="alphafold-env",
    image="docker.io/cford38/alphafold2_aml:latest"
)
alphafold_env.spark.environment_variables = {"TF_FORCE_UNIFIED_MEMORY": "1"}  # example env var needed by Alphafold

# Output data store for results
output = PipelineData("alphafold_output", datastore=ws.get_default_datastore())

# Define pipeline step to run AlphaFold (using a provided inference script)
step = PythonScriptStep(
    name="Run_AlphaFold_Inference",
    script_name="run_alphafold.py",  # this script runs the Alphafold code on a given input
    arguments=["--input_fasta", "data/sample.fasta", "--output_dir", output],
    compute_target="cpu-cluster",  # or a GPU cluster if available
    source_directory="pipelines",  # directory containing run_alphafold.py and any resources
    runconfig=None,
    environment=alphafold_env
)

pipeline = Pipeline(workspace=ws, steps=[step])
# Publish the pipeline in the workspace so it can be triggered via REST or UI
published_pipeline = pipeline.publish(name="AlphaFold_Pipeline", description="Protein folding inference pipeline (AlphaFold)")
print(f"Published AlphaFold pipeline ID: {published_pipeline.id}")
