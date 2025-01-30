FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

# Install common dependencies (so that this step can be cached separately)
COPY ./scripts/install_base.sh install_base.sh
RUN bash ./install_base.sh && rm install_base.sh

# Install UCX
ENV UCX_CHECKOUT_POINT="68a742fdbf31a87a9e0bfb3ba0b18e58d8323bf7"
COPY ./scripts/install_ucx.sh install_ucx.sh
RUN bash ./install_ucx.sh
RUN rm install_ucx.sh

# Install UCC
ENV UCC_CHECKOUT_POINT="658aa7fbcf40f0b5072d01a3c872bcf10e44ab54"
COPY ./scripts/install_ucc.sh install_ucc.sh
RUN bash ./install_ucc.sh
RUN rm install_ucc.sh

ENV PATH="/usr/bin:$PATH"
ENV LD_LIBRARY_PATH="usr/lib:/usr/lib/ucc:/usr/lib:/usr/lib/ucx"

# Install OMPI libs
ENV OMPI_HOME /usr
COPY ./scripts/install_ompi.sh install_ompi.sh
RUN bash ./install_ompi.sh
RUN rm install_ompi.sh

ENV LD_LIBRARY_PATH="/usr/lib:/usr/lib/openmpi:/usr/lib/ucc:/usr/lib/ucx"


CMD ["bash"]