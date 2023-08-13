
# all: clean compile run
all: clean compile run_coverage

compile:
	vlog top.sv

run_coverage:
	vsim -cvgperinstance -c ahb_apb_top -do "coverage save -onexit testcov.ucdb; run -all; exit"

run:
	vsim -c top_tb -do "run -all; quit"

clean:
	rm -rf work
	rm -rf transcript

report:
	vsim -cvgperinstance -viewcov testcov.ucdb -do "coverage report -file final_report.txt -byfile -detail -noannotate -option -cvg"
