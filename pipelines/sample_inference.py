from azureml.core import Workspace, Experiment, PipelineEndpoint

ws = Workspace.get(name="your-workspace", resource_group="your-rg")
pipeline_endpoint = PipelineEndpoint.get(workspace=ws, name="AlphaFold_Pipeline")
# Submit a pipeline run with example parameters (if any)
run = pipeline_endpoint.submit(experiment_name="quick-test", arguments=[ "--input_fasta", "data/sample.fasta" ])
print("Submitted pipeline run:", run.id)
run.wait_for_completion(show_output=True)
