#!/bin/env bash

# This script is used to run the application
consul agent -bootstrap -config-file=config/consul-config.hcl -bind=127.0.0.1
