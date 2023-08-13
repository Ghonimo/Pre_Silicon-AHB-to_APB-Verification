vlog top.sv
vsim -cvgperinstance -c work.ahb_apb_top
coverage save -onexit testcov.ucdb
run -all

# Save the coverage data in a Unified Coverage Database (UCDB) file.
coverage save ahb_apb_coverage.ucdb

# Generate a detailed coverage report from the UCDB file.
vcover report -details ahb_apb_coverage.ucdb

quit -sim
