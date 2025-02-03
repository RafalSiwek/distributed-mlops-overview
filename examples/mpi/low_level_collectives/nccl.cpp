#include <mpi.h>
#include <nccl.h>
#include <cuda_runtime.h>
#include <iostream>

#define NUM_ELEMENTS 1024

int main(int argc, char* argv[]) {
    MPI_Init(&argc, &argv);
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // Generate a unique NCCL ID on rank 0 and broadcast it to all other ranks
    ncclUniqueId id;
    if (rank == 0) ncclGetUniqueId(&id);
    MPI_Bcast(&id, sizeof(id), MPI_BYTE, 0, MPI_COMM_WORLD);

    // Initialize NCCL communicator for all ranks
    ncclComm_t comm;
    ncclCommInitRank(&comm, size, id, rank);

    // Allocate GPU memory for send and receive buffers
    float *sendbuf, *recvbuf;
    cudaMalloc(&sendbuf, NUM_ELEMENTS * sizeof(float));
    cudaMalloc(&recvbuf, NUM_ELEMENTS * sizeof(float));
    
    // Initialize send buffer with rank value
    cudaMemcpy(sendbuf, &rank, sizeof(float), cudaMemcpyHostToDevice);

    // Perform AllReduce operation using NCCL (sum reduction across all ranks)
    ncclAllReduce(sendbuf, recvbuf, NUM_ELEMENTS, ncclFloat, ncclSum, comm, 0);
    
    // Copy result back to host and print it
    float result;
    cudaMemcpy(&result, recvbuf, sizeof(float), cudaMemcpyDeviceToHost);
    std::cout << "Rank " << rank << " received AllReduce result: " << result << std::endl;

    // Cleanup resources
    ncclCommDestroy(comm);
    cudaFree(sendbuf);
    cudaFree(recvbuf);
    MPI_Finalize();
    return 0;
}
