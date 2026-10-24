# FastFlowLM with Podman

This repository builds a small Ubuntu 24.04 image with the latest
FastFlowLM Linux package and runs it through Podman.

## Requirements

- Podman on an `amd64` Linux host
- For `run` and `serve`: a supported AMD Ryzen AI NPU
- For `run` and `serve`: host NPU driver, firmware, and XRT setup
- For `run` and `serve`: `/dev/accel/accel0` accessible to the user
- Podman's `crun` runtime for NPU device access

The container installs the XRT userspace package. The NPU kernel driver
must run on the host. The host memlock limit must allow unlimited locked
memory for NPU use.

## Build and run

Build or refresh the image, downloading the latest release package:

```sh
./flm build
```

List supported and downloaded models:

```sh
./flm list
./flm list --filter installed
```

Other FastFlowLM commands and options pass through to the container:

```sh
./flm pull llama3.2:1b
./flm validate
./flm help
```

Run a model interactively:

```sh
./flm run llama3.2:1b
```

Start the API server in the foreground:

```sh
./flm serve llama3.2:1b
```

The script follows the server logs and stops the container on Ctrl-C.
It also stops the container when the wrapper receives SIGTERM. The
stop waits up to five seconds before forcing the process to exit. If
the wrapper exits unexpectedly, use `podman ps` to find the container
and `podman stop <container-id>` to stop it.

FastFlowLM commands build the image if it is absent. `./flm --help`
shows wrapper usage; `./flm help` shows FastFlowLM help.
The server listens on host port 52625 at `127.0.0.1`. FastFlowLM
configuration and downloaded models persist in `~/.config/flm`.

To change the server port, pass it to FastFlowLM:

```sh
./flm serve llama3.2:1b --port 8000
```

The selected port remains bound to `127.0.0.1` on the host. The
container sets FastFlowLM's listen address to `0.0.0.0`; do not pass
`--host`.

Set `FLM_IMAGE=your-tag` when invoking the script to change the local
image tag.
