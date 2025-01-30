# Running Ray Operations Locally

This directory contains a Python script (`ray_multinode_ddp.py`) that demonstrates how to run a distributed PyTorch training job using **Ray** on your local machine. Ray simplifies distributed computing and allows you to scale your workloads seamlessly.

## Prerequisites

1. **Install Ray**:
   Install Ray using pip:
   ```bash
   pip install "ray[default]"
   ```
   For GPU support, install the additional dependencies:
   ```bash
   pip install "ray[default,gpu]"
   ```

2. **Install PyTorch**:
   Install PyTorch by following the official [PyTorch installation guide](https://pytorch.org/get-started/locally/).

## Running the Script Locally

To run the `ray_multinode_ddp.py` script locally, follow these steps:

1. **Start a Local Ray Cluster**:
   Initialize a local Ray cluster by running:
   ```bash
   ray start --head
   ```
   This will start a Ray head node on your local machine.

2. **Run the Script**:
   Execute the script using Python:
   ```bash
   python ray_multinode_ddp.py
   ```

3. **Monitor the Ray Dashboard**:
   Ray provides a dashboard to monitor the cluster and tasks. Access it at:
   ```
   http://127.0.0.1:8265
   ```

4. **Stop the Ray Cluster**:
   After completing your tasks, stop the Ray cluster:
   ```bash
   ray stop
   ```

## Script Details

The `ray_multinode_ddp.py` script uses Ray's `ray.train` API to distribute PyTorch training across multiple workers. It leverages Ray's ability to handle resource allocation and communication between nodes.

## References

- **Ray Documentation**: [https://docs.ray.io](https://docs.ray.io)
- **Ray Train API**: [https://docs.ray.io/en/latest/train/train.html](https://docs.ray.io/en/latest/train/train.html)
- **PyTorch Distributed Training**: [https://pytorch.org/tutorials/intermediate/ddp_tutorial.html](https://pytorch.org/tutorials/intermediate/ddp_tutorial.html)

## Notes

- This example is designed for local execution. For multi-node setups, refer to the [Ray Cluster documentation](https://docs.ray.io/en/latest/cluster/index.html).
- Ensure your machine has sufficient resources (CPU/GPU) to handle the distributed workload.

For further assistance, consult the [Ray documentation](https://docs.ray.io) or the [Ray community forum](https://discuss.ray.io/).