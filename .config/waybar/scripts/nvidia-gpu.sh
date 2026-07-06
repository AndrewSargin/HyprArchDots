#!/bin/bash

read gpu_util gpu_temp < <(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits | tr ',' ' ')
echo "{\"text\": \"<span font='20px'>󰢮</span><span rise='2000'> ${gpu_util}% ${gpu_temp}°C</span>\"}"
