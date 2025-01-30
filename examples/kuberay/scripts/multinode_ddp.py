import ray
import ray.train as train
from ray.train.torch import TorchTrainer
from ray.air.config import ScalingConfig
import torch
import torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader
from time import perf_counter


class MyTrainDataset(Dataset):
    def __init__(self, size):
        self.size = size
        self.data = [(torch.rand(20), torch.randint(0, 2, (1,))) for _ in range(size)]

    def __len__(self):
        return self.size

    def __getitem__(self, index):
        return self.data[index]


def train_epoch(config):
    model = train.torch.prepare_model(config["model"])
    optimizer = config["optimizer"]
    train_data = train.torch.prepare_data_loader(config["data_loader"])

    for epoch in range(config["epochs"]):
        total_loss = 0.0
        if ray.train.get_context().get_world_size() > 1:
            train_data.sampler.set_epoch(epoch)
        for inputs, targets in train_data:
            # Move data to the appropriate device (CPU in this case)
            inputs, targets = inputs.to(torch.device("cpu")), targets.to(
                torch.device("cpu")
            )
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = F.cross_entropy(outputs, targets.view(-1))
            loss.backward()
            optimizer.step()

            total_loss += loss.item()

        # Save snapshots only on rank 0
        if (
            train.get_context().get_world_rank() == 0
            and epoch % config["save_every"] == 0
        ):
            torch.save(
                {
                    "model_state": model.state_dict(),
                    "epoch": epoch,
                },
                config["snapshot_path"],
            )
        # Uncomment when Logging required. See https://docs.ray.io/en/latest/train/user-guides/monitoring-logging.html
        # ray.train.report(metrics={"loss": total_loss})


def load_train_objs(dataset_size=2048):
    train_set = MyTrainDataset(dataset_size)
    model = torch.nn.Linear(20, 2)  # Binary classification
    optimizer = torch.optim.SGD(model.parameters(), lr=1e-3)
    return train_set, model, optimizer


def prepare_dataloader(dataset: Dataset, batch_size: int):
    return DataLoader(dataset, batch_size=batch_size, pin_memory=False, shuffle=True)


def main(
    save_every: int,
    total_epochs: int,
    batch_size: int,
    num_workers: int,
    snapshot_path: str = "snapshot.pt",
):
    ray.init()

    dataset, model, optimizer = load_train_objs()
    train_data = prepare_dataloader(dataset, batch_size)

    config = {
        "model": model,
        "optimizer": optimizer,
        "data_loader": train_data,
        "epochs": total_epochs,
        "save_every": save_every,
        "batch_size_per_worker": batch_size // num_workers,
        "snapshot_path": snapshot_path,
    }

    trainer = TorchTrainer(
        train_epoch,
        train_loop_config=config,
        scaling_config=ScalingConfig(num_workers=num_workers, use_gpu=False),
    )

    result = trainer.fit()

    print(f"{result}")

    ray.shutdown()


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Ray distributed training job")
    parser.add_argument(
        "total_epochs", type=int, help="Total epochs to train the model"
    )
    parser.add_argument("save_every", type=int, help="How often to save a snapshot")
    parser.add_argument(
        "--batch_size",
        default=32,
        type=int,
        help="Input batch size on each device (default: 32)",
    )
    parser.add_argument(
        "--num_workers",
        default=2,
        type=int,
        help="Number of distributed workers (default: 2)",
    )
    args = parser.parse_args()

    main(
        save_every=args.save_every,
        total_epochs=args.total_epochs,
        batch_size=args.batch_size,
        num_workers=args.num_workers,
    )
