@set "VERILATOR_ROOT="

:: Re-Store existing env vars
@if defined _CONDA_SET_VERILATOR_ROOT (
    set "VERILATOR_ROOT=%_CONDA_SET_VERILATOR_ROOT%"
    set "_CONDA_SET_VERILATOR_ROOT="
)


