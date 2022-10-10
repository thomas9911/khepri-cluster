#! /bin/bash

RELEASE_NODE="testing@localhost" nohup _build/dev/rel/kherpi_libcluster/bin/kherpi_libcluster start &
RELEASE_NODE="testing1@localhost" nohup _build/dev/rel/kherpi_libcluster/bin/kherpi_libcluster start &
RELEASE_NODE="testing2@localhost" _build/dev/rel/kherpi_libcluster/bin/kherpi_libcluster start_iex
