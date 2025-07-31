# t0 is counter, t1 is target loop count, t2 is value to add, t3 is out
ADDI t1, zero, 5
ADDI t2, zero, 9

loop_start:
BGE t0, t1, loop_end
ADD t3, t3, t2
ADDI t0, t0, 1
JAL ra, loop_start

loop_end:
SUB t0, t0, t1