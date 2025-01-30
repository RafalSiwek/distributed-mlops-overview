import torch
import torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader
from time import perf_counter


class MyTrainDataset(Dataset):
    def __init__(self, size):
        self.size = size
        self.data = [(torch.rand(20), torch.rand(1)) for _ in range(size)]

    def __len__(self):
        return self.size

    def __getitem__(self, index):
        return self.data[index]


class Trainer:
    def __init__(
        self,
        model: torch.nn.Module,
        train_data: DataLoader,
        optimizer: torch.optim.Optimizer,
        save_every: int,
    ) -> None:
        self.model = model
        self.train_data = train_data
        self.optimizer = optimizer
        self.save_every = save_every

    def _run_batch(self, source, targets):
        self.optimizer.zero_grad()
        output = self.model(source)
        loss = F.cross_entropy(output, targets)
        loss.backward()
        self.optimizer.step()

    def _run_epoch(self, epoch):
        b_sz = len(next(iter(self.train_data))[0])
        print(f"Epoch {epoch} | Batchsize: {b_sz} | Steps: {len(self.train_data)}")
        for source, targets in self.train_data:
            self._run_batch(source, targets)

    def _save_checkpoint(self, epoch):
        ckp = self.model.state_dict()
        PATH = "checkpoint.pt"
        torch.save(ckp, PATH)
        print(f"Epoch {epoch} | Training checkpoint saved at {PATH}")

    def train(self, max_epochs: int):
        for epoch in range(max_epochs):
            self._run_epoch(epoch)
            if epoch % self.save_every == 0:
                self._save_checkpoint(epoch)


def load_train_objs():
    train_set = MyTrainDataset(2048)  # load your dataset
    model = torch.nn.Linear(20, 1)  # load your model
    optimizer = torch.optim.SGD(model.parameters(), lr=1e-3)
    return train_set, model, optimizer


def prepare_dataloader(dataset: Dataset, batch_size: int):
    return DataLoader(dataset, batch_size=batch_size, shuffle=True)


def main(total_epochs, save_every, batch_size):
    dataset, model, optimizer = load_train_objs()
    train_data = prepare_dataloader(dataset, batch_size)
    trainer = Trainer(model, train_data, optimizer, save_every)
    t1_start = perf_counter()
    trainer.train(total_epochs)
    t1_stop = perf_counter()
    print(f"Training took {(t1_stop-t1_start)} s")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="simple training job")
    parser.add_argument(
        "total_epochs", type=int, help="Total epochs to train the model"
    )
    parser.add_argument("save_every", type=int, help="How often to save a snapshot")
    parser.add_argument(
        "--batch_size",
        default=32,
        type=int,
        help="Input batch size (default: 32)",
    )
    args = parser.parse_args()

    main(args.total_epochs, args.save_every, args.batch_size)
