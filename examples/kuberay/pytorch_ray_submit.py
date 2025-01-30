from ray.job_submission import JobSubmissionClient
import os

address = "http://127.0.0.1:8266"

client = JobSubmissionClient(address)

with open(
    f"{'/'.join(os.path.realpath(__file__).split('/')[:-1])}/scripts/multinode_ddp.py",
    "r",
) as f:
    multinode_code = f.read()

kick_off_pytorch_benchmark = (
    # Clone ray. If ray is already present, don't clone again.
    f"cat <<EOF > multinode.py\n{multinode_code}\nEOF\n"
    # Run the benchmark.
    "python multinode.py 500 500 --num_workers 2"
)


submission_id = client.submit_job(
    entrypoint=kick_off_pytorch_benchmark,
)

print("Use the following command to follow this Job's logs:")
print(f"ray job logs '{submission_id}' --follow --address {address}")
