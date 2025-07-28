LW t0, 0(zero)
LW t1, 4(zero)
BEQ t0, t1, sub_and_save
ADD t2, t0, t1

sub_and_save:
SUB t2, t0, t1