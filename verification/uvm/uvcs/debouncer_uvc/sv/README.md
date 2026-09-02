# DEBOUNCER_UVC

## Setup

> **Note:** The `Makefile` expects a git project to setup the environment variables

> **Note:** Before running the setup, make sure to place your own `setup_synopsys_eda.sh` file in the `scripts/setup/` directory.

> **Note:** This setup only needs to be executed once. Afterward, simply navigate to `work/uvm` and source your setup file.

From the root directory run the following:

### For bash

```bash
export GIT_ROOT="$(git rev-parse --show-toplevel)"
export UVM_WORK="$GIT_ROOT/work/uvm"
export UVM_SCRIPTS = "$GIT_ROOT/verification/uvm/scripts"
mkdir -p "$UVM_WORK" && cd "$UVM_WORK"
ln -sf $UVM_SCRIPTS/makefiles/Makefile.vcs Makefile
ln -sf $UVM_SCRIPTS/setup/setup_synopsys_eda.sh
source setup_synopsys_eda.sh
make
```

### For tcsh

```bash
setenv GIT_ROOT `git rev-parse --show-toplevel`
setenv UVM_WORK $GIT_ROOT/work/uvm
setenv UVM_SCRIPTS $GIT_ROOT/verification/uvm/scripts
mkdir -p $UVM_WORK && cd $UVM_WORK
ln -sf $UVM_SCRIPTS/makefiles/Makefile.vcs Makefile
ln -sf $UVM_SCRIPTS/setup/setup_synopsys_eda.tcsh
source setup_synopsys_eda.tcsh
make
```


> NOTE: This UVM verification framework was generated using the [pyuvcgen](https://github.com/uvmcollab/pyuvcgen) tool to gene
