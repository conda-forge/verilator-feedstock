:: Store existing env vars so we can restore them later
@if defined VERILATOR_ROOT (
    set "_CONDA_SET_VERILATOR_ROOT=%VERILATOR_ROOT%
)

@set "VERILATOR_ROOT=%CONDA_PREFIX%\Library\"
