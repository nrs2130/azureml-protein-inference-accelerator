# Pipelines Overview

This folder contains **Azure Machine Learning pipeline definitions** and supporting code for **protein structure prediction** models such as **AlphaFold** and **RoseTTAFold**. These pipelines enable you to run inference (protein folding) on Azure ML compute resources, either via **batch** or **interactive** submission.

## Contents

pipelines/ ├── alphafold_pipeline.py ├── rosettafold_pipeline.py ├── environments/ │ ├── alphafold_env.dockerfile │ └── rosettafold_env.dockerfile ├── sample_inference.py ├── data/ │ └── sample.fasta └── README.md <-- (this file)


### Key Files

1. **alphafold_pipeline.py**  
   - Defines a pipeline for running [AlphaFold](https://github.com/deepmind/alphafold) inference on Azure ML.  
   - Contains a pipeline step (or multiple steps) that references a Docker environment with AlphaFold dependencies.  
   - Publishes a pipeline named “AlphaFold_Pipeline” in the Azure ML workspace.

2. **rosettafold_pipeline.py**  
   - Similar to above but for [RoseTTAFold](https://github.com/RosettaCommons/RoseTTAFold).  
   - Once published, it appears in your workspace as “RoseTTAFold_Pipeline”.

3. **environments/**  
   - **alphafold_env.dockerfile**: Dockerfile describing how to build an environment for AlphaFold (installing dependencies like `openmm`, `tensorflow`, `colabfold`, etc.).  
   - **rosettafold_env.dockerfile**: Dockerfile for RoseTTAFold environment.  
   - *Alternatively*, if you prefer pre-built images, you can reference them directly in your pipeline code (e.g., `Environment.from_docker_image(image="<my-registry>/alphafold:latest")`).

4. **sample_inference.py**  
   - A simple Python script that **submits a pipeline run** to your Azure ML workspace. By default, it points to the AlphaFold pipeline, providing a sample input FASTA.  
   - Useful for quick validation of your deployment.

5. **data/**  
   - Stores sample input files, such as `sample.fasta` for a simple protein chain.  
   - You can place additional test data here or reference your own files from other locations.

---

## Pipeline Registration

When you **deploy** this solution (either via GitHub Actions or `scripts/deploy_cli.sh`), the system runs [`scripts/register_pipelines.py`](../scripts/register_pipelines.py). That registration script:

1. **Imports** `alphafold_pipeline.py` and `rosettafold_pipeline.py`.  
2. **Builds** or references Docker environments (from the Dockerfiles in `environments/`) for AlphaFold and RoseTTAFold.  
3. **Publishes** each pipeline to the Azure ML workspace with names “AlphaFold_Pipeline” and “RoseTTAFold_Pipeline”.

You can also **manually** register or update pipelines by running:
```bash
cd pipelines
python ../scripts/register_pipelines.py --workspace <WS_NAME> --resource-group <RG_NAME> --subscription <SUB_ID>
